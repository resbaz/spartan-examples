#!/bin/sh

##########################################
#BLAME:
#achalmers@unimelb.edu.au
#This script should setup basic fsl options for batch jobs vis SLURM.
#Caution, this fsl_sub script has been built from multiple sources (Trinity, Unimelb, VPAC).
#It has seen many hands - it should be treated as experimental in the extreme - use at own risk.
#ALC 21-09-2016
##########################################


##########################################
#Set up basic cluster details
##########################################
METHOD=SLURM
ORIGINAL_PARAMS=$@

if [ "x$FSL_SLURMROOT" = "x" ] ; then
    METHOD=NONE
fi
#echo "Method=" $METHOD

##########################################
#Set queue type.
##########################################
map_qname ()
{

    # if slurm environment is detected use the compute partition, change this to suit
    if [ $METHOD = SLURM ] ; then
	queue=compute
    elif [ $1 -le 20 ] ; then
	queue=test
    else
	#queue=verylong.q
	queue=compute
    fi


    #echo "Estimated time was $1 mins: queue name is $queue"
}

##########################################
#Set up args output
##########################################
POSIXLY_CORRECT=1
export POSIXLY_CORRECT
command=`basename $0`

usage ()
{
  cat <<EOF

$command V1.1 - wrapper for job control system such as SLURM

Usage: $command [options] <command>

$command gzip *.img *.hdr
$command -q short.q gzip *.img *.hdr
$command -a darwin regscript rawdata outputdir ...

  -T <minutes>          Estimated job length in minutes, used to auto-set queue name
  -q <queuename>        Possible values for <queuename> are "verylong.q", "long.q" 
                        and "short.q". See below for details
                        Default is "long.q".
  -a <arch-name>        Architecture [e.g., darwin or lx24-amd64]
  -p <job-priority>     Lower priority [0:-1024] default = 0                 
  -M <email-address>    Who to email, default = `whoami`@fmrib.ox.ac.uk 
  -j <jid>              Place a hold on this task until job jid has completed
  -t <filename>         Specify a task file of commands to execute in parallel
  -N <jobname>          Specify jobname as it will appear on queue
  -l <logdirname>       Where to output logfiles
  -m <mailoptions>      Change the SGE mail options, see qsub for details
  -z <output>           If <output> image or file already exists, do nothing and exit
  -F                    Use flags embedded in scripts to set SGE queuing options
  -s <pename>,<threads> Submit a multi-threaded task - requires a PE (<pename>) to be
                        configured for the requested queues.
                        <threads> specifies the number of threads to run
  -v                    Verbose mode.

Queues:

There are 2 batch queues configured on the cluster, each with defined CPU
time limits.


test:This queue is for jobs which last under 30mins.
compute:   This queue is like the test queue but has no limits.

EOF

  exit 1
}

nargs=$#
if [ $nargs -eq 0 ] ; then
  usage
fi

set -- `getopt T:q:a:p:M:j:t:z:N:Fvm:l:s: $*`
result=$?
if [ $result != 0 ] ; then
  echo "What? Your arguments make no sense!"
fi

if [ $nargs -eq 0 ] || [ $result != 0 ] ; then
  usage
fi

##########################################
#Set up openmp
##########################################

omp_pe='openmp'



###########################################################################
# The following sets up the default queue name, which you may want to
# change. It also sets up the basic emailing control.
###########################################################################


queue=test
if [ "${FSL_QUEUE}" ]; then
   queue="${FSL_QUEUE}"
fi

mailto=`whoami`@spartan-m
MailOpts="a"   # Mail user on abort


###########################################################################
# In the following, you might want to change the behaviour of some
# flags so that they prepare the right arguments for the actual
# cluster queue submission program, in our case "qsub".
#
# -a sets is the cluster submission flag for controlling the required
# hardware architecture (normally not set by the calling program)
#
# -p set the priority of the job - ignore this if your cluster
# environment doesn't have priority control in this way.
#
# -j tells the cluster not to start this job until cluster job ID $jid
# has completed. You will need this feature.
#
# -t will pass on to the cluster software the name of a text file
# containing a set of commands to run in parallel; one command per
# line.
#
# -N option determines what the command will be called when you list
# running processes.
#
# -l tells the cluster what to call the standard output and standard
# -error logfiles for the submitted program.
###########################################################################


if [ -z $FSLSUBVERBOSE ] ; then
    verbose=0
else
    verbose=$FSLSUBVERBOSE;
    echo "METHOD=$METHOD : args=$@" >&2
fi

scriptmode=0


while [ $1 != -- ] ; do
  case $1 in
    -z)
      if [ -e $2 -o `${FSLDIR}/bin/imtest $2` = 1 ] ; then
        exit 0
      fi
      shift;;
    -T)
      map_qname $2
      shift;;
    -q)
      queue=$2
      qconf -sql | grep ^$queue 2>&1 >/dev/null
      if [ $? -eq 1 ]; then
	  echo "Invalid queue specified!"
	  exit 127
      fi
      shift;;
    -a)
      acceptable_arch=no
      available_archs=`qhost | tail -n +4 | awk '{print $2}' | sort | uniq`
      for a in $available_archs; do
	if [ $2 = $a ] ; then
	  acceptable_arch=yes
	fi
      done
      if [ $acceptable_arch = yes ]; then
	  sge_arch="-l arch=$2"
      else
	  echo "Sorry arch of $2 is not supported on this SGE configuration!"
	  echo "Should be one of:" $available_archs
	  exit 127
      fi
      shift;;
    -p)
      sge_priority="-p $2"
      shift;;
    -M)
      mailto=$2
      shift;;
    -j)
      jid=$2
      sge_hold="-hold_jid $jid"
      shift;;
    -t)
      taskfile=$2
      #Check for taskfile, this should still work ALC (this section via edward using TRQ)                                                                        
      if [ ! -e $taskfile ] ; then
           echo "Couldn't find taskfile [${taskfile}]"
           echo "Aborting ..... "
           exit -1
      fi
      tasks=`wc -l $taskfile | awk '{print $1}'`
      sge_tasks="-t 1-$tasks"
      shift;;
    -N)
      JobName=$2;
      shift;;
    -m)
      MailOpts=$2;
      shift;;
    -l)
      LogOpts="-o $2 -e $2";
      LogDir="${2}/";
      mkdir -p $2;
      shift;;
    -F)
      scriptmode=1;
      ;;
    -v)
      verbose=1
      ;;
    -s)
      pe_string=$2;
      peName=`echo $pe_string | cut -d',' -f 1`
      peThreads=`echo $pe_string | cut -d',' -f 2`
      shift;;
  esac
  shift  # next flag
done
shift

###########################################################################
# Don't change the following (but keep scrolling down!)
###########################################################################

if [ "x$JobName" = x ] ; then 
    if [ "x$taskfile" != x ] ; then
	JobName=`basename $taskfile`
    else
	JobName=`basename $1`
    fi
fi

if [ "x$tasks" != x ] && [ ! -f "$taskfile" ] ; then
    echo $taskfile: invalid input!
    echo Should be a text file listing all the commands to run!
    exit -1
fi

if [ "x$tasks" != "x" ] && [ "x$@" != "x" ] ; then
    echo $@
    echo Spurious input after parsing command line!
    exit -1
fi

if [ "x$peName" != "x" ]; then
    # If the PE name is 'openmp' then limit the number of threads to those specified
    
    if [ "X$peName" = "X$omp_pe" ]; then
        OMP_NUM_THREADS=$peThreads
	export OMP_NUM_THREADS
    fi

fi

###########################################################################
# The following is the main call to the cluster
#If $tasks has not been set then qsub/sbatch/srun is running a single
# command, otherwise qsub/sbatch/srun is processing a text file of parallel
# commands.
###########################################################################

case $METHOD in

###########################################################################
# SLURM method (From Trinity patch - ALC)
# This is a very basic way of doing things, its just to simply fire off all
# the tasks individually to the resource manager via sbatch.
# So by this point all SLURM vars should be set.
###########################################################################

       SLURM)
               if [ $verbose -eq 1 ] ; then
                       echo "Starting Slurm submissions..." >&2
               fi
               _SRMRAND=$RANDOM
               _SRMNAME=$JobName$SRMRAND
               echo "========================" >> sbatch.log
               echo "= Starting submissions =" >> sbatch.log
               echo "========================" >> sbatch.log
               date >> sbatch.log

	while read line
	do
	        if [ "x$line" != "x" ] ; then
			sbatch -J $_SRMNAME -o "slurm-log-$_SRMNAME-%j-%N.out" -t 01:00:00 -p $queue -n 1 <> sbatch.log 2>&1
;;

###########################################################################
# Don't change the following - this runs the commands directly if a
# cluster is not being used.
###########################################################################

    NONE)
	if [ "x$tasks" = "x" ] ; then
	    if [ $verbose -eq 1 ] ; then 
		echo executing: $@ >&2
	    fi

	    /bin/sh <<EOF1 > ${LogDir}${JobName}.o$$ 2> ${LogDir}${JobName}.e$$
$@
EOF1
	    ERR=$?
	    if [ $ERR -ne 0 ] ; then
		cat ${LogDir}${JobName}.e$$ >&2
		exit $ERR
	    fi
	else
	    if [ $verbose -eq 1 ] ; then 
		echo "Running commands in: $taskfile" >&2
	    fi

	    n=1
	    while [ $n -le $tasks ] ; do
		line=`sed -n -e ''${n}'p' $taskfile`
		if [ $verbose -eq 1 ] ; then 
		    echo executing: $line >&2
		fi
		/bin/sh <<EOF2 > ${LogDir}${JobName}.o$$.$n 2> ${LogDir}${JobName}.e$$.$n
$line
EOF2
		n=`expr $n + 1`
	    done
	fi	
	echo $$
	;;

esac
