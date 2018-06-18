# This will profile your application using the default CUDA counters, if 
# you would like to use different counter you can specify this by using 
# CUDA_PROFILE_CONFIG environment variable which points to a file 
# containing the counters you want to use (limited to 4 per run), you 
# can find more information regarding the counters and the config file 
# on the NVIDIA cuda documentation. 
#
# Please be aware that the profiler will only sample from 1 GPU, it has 
# the same limitations as the nVidia Visual profiler provided in the 
# CUDA toolkit.

declare CUDA_PROFILE=1
declare CUDA_PROFILE_CSV=1
declare CUDA_PROFILE_LOG=$HOSTNAME.nvidia.profiler.output

declare -x CUDA_PROFILE
declare -x CUDA_PROFILE_CSV
declare -x CUDA_PROFILE_LOG

