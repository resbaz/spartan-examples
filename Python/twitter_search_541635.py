

# Import mpi so we can run on more than one node and processor
from mpi4py import MPI
# Import csv to read files and arguments
import csv, sys, getopt
# Import regular expressions to look for topics and mentions, json to parse tweet data
import re, json, operator

# Constants
TOPIC_REGEX = '#\w+'
MENTION_REGEX = '@\w+'
MASTER_RANK = 0

def count_regex(tweet, regex):
  # We want to find the most mentioned @user in the dataset
  counts = {}
  occurences = re.findall(regex, tweet['text'])
  for occurence in occurences:
    counts[occurence] = counts.setdefault(occurence,0) + 1
  return counts

def trending_topics(tweet):
  # We want to find the most mentioned #word in the dataset
  return count_regex(tweet, TOPIC_REGEX)

def user_mentions(tweet):
  # We want to find the most mentioned @user in the dataset
  return count_regex(tweet, MENTION_REGEX)

def tweet_to_json(tweet):
  # Remove poorly formatted urls and new line / carriage returns
  tweet = re.sub('"source":"<a.*?>.*?</a>"','"source":""',tweet)
  tweet = re.sub('(\r|\n)+','',tweet)
  tweet = json.loads(tweet)
  return tweet

# Argument finding
def print_usage():
  print ('usage is: twitter_search_541635.py -i <inputfile> [opts] where opts are:')
  print ('  -[tms] <query>       flag to search topics, mentions or search')
  print ('                       by a query string respectively, -s requires')
  print ('                       a search string. (optional, default is mentions).')

def read_arguments(argv):
  # Initialise Variables
  inputfile = ''
  search_type = 'mentions'
  search_query = ''
  ## Try to read in arguments
  try:
    opts, args = getopt.getopt(argv,"hi:tms:")
  except getopt.GetoptError as error:
    print(error)
    print_usage()
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print_usage()
      sys.exit()
    elif opt in ("-i"):
       inputfile = arg
    elif opt in ("-m"):
       search_type = 'mentions'
    elif opt in ("-t"):
       search_type = 'topic'
    elif opt in ("-s"):
       search_type = 'string_search'
       search_query = arg
  # Return all the arguments
  return inputfile, search_type, search_query

# Output printers
def print_matches(matches, squery):
  print(squery, " was found ", matches.setdefault(squery,0), " times.")

def print_mentions(mentions):
  sorted_counts = sorted(mentions.items(), key=operator.itemgetter(1))
  print("The top ten users mentioned are:")
  for mention in reversed(sorted_counts[-10:]):
    user, times = mention
    print(user, ":", times)

def print_topics(topics):
  sorted_counts = sorted(topics.items(), key=operator.itemgetter(1))
  print("The top ten trending topics are:")
  for topic in reversed(sorted_counts[-10:]):
    topic, times = topic
    print(topic, ":", times)

def print_output(results, stype, squery):
  if stype in ("mentions"):
    print_mentions(results)
  elif stype in ("topic"):
    print_topics(results)
  elif stype in ("string_search"):
    print_matches(results, squery)

def process_tweet(counts, stype, squery, tweet):
  if stype in ("mentions"):
    results = user_mentions(tweet)
  elif stype in ("topic"):
    results = trending_topics(tweet)
  elif stype in ("string_search"):
    regex = '\\b' + squery + '\\b'
    results = count_regex(tweet, regex)
  
  for k,v in results.items():
    counts[k] = counts.setdefault(k,0) + v
  return counts

def process_tweets(rank, input_file, processes, stype, squery):
  with open(input_file) as f:
    rows = csv.DictReader(f)
    occurences = {}
    # Send tweets to slave processes
    try:
      for i, line in enumerate(rows):
        if i%processes == rank:
          tweet = line['value']
          try:
            tweet = tweet_to_json(tweet)
            occurences = process_tweet(occurences, stype, squery, tweet)
          except ValueError:
            print("Malformed JSON in tweet ", i)
    except csv.Error:
      print("Could not read line in csv.")
  return occurences

def marshall_tweets(comm):
  processes = comm.Get_size()
  counts = []
  #Now ask all processes except oursevles to return counts
  for i in range(processes-1):
    # Send request
    comm.send('return_data', dest=(i+1), tag=(i+1))
  for i in range(processes-1):
    # Receive data
    counts.append(comm.recv(source=(i+1), tag=MASTER_RANK))
  return counts

def master_tweet_processor(comm, input_file, stype, squery):
    # Read our tweets
    rank = comm.Get_rank()
    size = comm.Get_size()

    occurences = process_tweets(rank, input_file,
                                size, stype, squery)
    if size > 1:
      counts = marshall_tweets(comm)
      # Marshall that data
      for d in counts:
        for k,v in d.items():
          occurences[k] = occurences.setdefault(k,0) + v
      # Turn everything off
      for i in range(size-1):
        # Receive data
        comm.send('exit', dest=(i+1), tag=(i+1))

    # Print output
    print_output(occurences, stype, squery)


def slave_tweet_processor(comm,input_file, stype, squery):
  # We want to process all relevant tweets and send our counts back
  # to master when asked
  # Find my tweets
  rank = comm.Get_rank()
  size = comm.Get_size()

  counts = process_tweets(rank, input_file, size, stype, squery)
  # Now that we have our counts then wait to see when we return them.
  while True:
    in_comm = comm.recv(source=MASTER_RANK, tag=rank)
    # Check if command
    if isinstance(in_comm, str):
      if in_comm in ("return_data"):
        # Send data back
        # print("Process: ", rank, " sending back ", len(counts), " items")
        comm.send(counts, dest=MASTER_RANK, tag=MASTER_RANK)
      elif in_comm in ("exit"):
        exit(0)

def main(argv):
  # Get
  input_file, stype, squery = read_arguments(argv)
  # Work out our rank, and run either master or slave process
  comm = MPI.COMM_WORLD
  rank = comm.Get_rank()
  if rank == 0 :
    # We are master
    master_tweet_processor(comm, input_file, stype, squery)
  else:
    # We are slave
    slave_tweet_processor(comm, input_file, stype, squery)

# Run the actual program
if __name__ == "__main__":
  main(sys.argv[1:])