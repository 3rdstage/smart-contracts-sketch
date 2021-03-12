#! /bin/bash

# TODO

# References
#   - https://github.com/ethereum/go-ethereum/blob/v1.10.1/README.md 
#   - https://medium.com/coinmonks/ethereum-setting-up-a-private-blockchain-67bbb96cf4f1

readonly uname=`uname -s`  # OS type
readonly script_dir=$(cd `dirname $0` && pwd)

declare data_dir
declare log_dir

# Locate directories for data and logs
case $uname in
Linux)  #Linux
  data_dir='/var/lib/geth'
  log_dir='/var/log'
  ;;
MINGW*)  #Git Bash on Windows
  readonly run_dir=$(mkdir -p "${script_dir}/../run/geth" && cd "${script_dir}/../run/geth" && pwd)
  data_dir=${run_dir}/data
  log_dir=${run_dir}
  ;;
Darwin*) #Bash on macOS
  readonly run_dir=$(mkdir -p "${script_dir}/../run/geth" && cd "${script_dir}/../run/geth" && pwd)
  data_dir=${run_dir}/data
  log_dir=${run_dir}
  ;;
*)
  echo "The current system is Unknown of which 'uname -s' shows '$uname'."
  exit 600
esac

# Catch command-line options
# Check whether GNU getopt is available or not
if [ `getopt --test; echo $?` -ne 4 ]; then
  echo "The avaiable 'getopt' is not GNU getopt which supports long options."
  echo "For MacOS, install 'gnu-getopt' refering 'https://formulae.brew.sh/formula/gnu-getopt'."
  exit 410
fi

options=$(getopt -o rdbv --long "refresh,dryrun,background,verbose" --name 'geth-start-options' -- "$@");

if [ $? -ne 0 ]; then
  command=${0##*/}
  echo "Unable to parse command line, which expect '$command [-r|--refresh] [-d|--dryrun] [-b|--background] [-v|verbose]'."
  echo ""
  exit 400
fi

eval set -- "$options"

declare refreshes=0   #false
declare backgrounds=0   #false
declare verboses=0 
declare dryruns=0
while true; do
  case "$1" in
    -r | --refresh )
      echo "refresh specified"
      refreshes=1
      shift ;;
    -b | --background )
      backgrounds=1
      shift ;;
    -v | --verbose )
      verboses=1
      shift ;;
    -d | --dryrun )
      dryruns=1
      shift ;;
    -- ) shift; break ;;
  esac
done

if [ ! -d "${data_dir}" ]; then
  echo "Creating data directory on '${data_dir}'"
  if [ "$uname" == "Linux" ]; then
    sudo mkdir -p "${data_dir}"
  else
    mkdir -p "${data_dir}"
  fi
fi

if [ $refreshes -eq 1 ]; then
  echo "Removing all current data under '${data_dir}'"
  if [ "$uname" == "Linux" ]; then
    sudo rm -Rf "${data_dir}"
    sleep 3
    sudo mkdir -p "${data_dir}"
  else
    rm -Rf "${data_dir}"
    sleep 3
    mkdir -p "${data_dir}"
  fi
fi

cd "${script_dir}"

if [ ! -f "${data_dir}/geth/nodekey" ]; then  # not initialized
  echo ""
  echo "Creating genesys state."
  geth  --datadir "${data_dir}" init "${script_dir}/geth-genesis.json"
  echo ""
  echo "Adding a few accounts into the node."
  geth js --nodiscover --datadir "${data_dir}" "${script_dir}/geth-setup.js"
fi

echo ""
echo "Starting geth node of which log is located at '${log_dir}/geth.log'"
# available http.api = admin,db,eth,debug,miner,net,shh,txpool,personal,web3
cmd="geth --datadir '${data_dir}' --networkid 31 \
          --nodiscover --verbosity 3 \
          --http --http.addr localhost --http.port 8545 \
          --mine --miner.threads 1 \
          --miner.etherbase 0x3DC9b4063a130535913137E40Bed546Ff93b1131 \
          >> '${log_dir}'/geth.log 2>&1"

if [ $backgrounds -eq 0 ]; then
  echo ""
  echo $cmd
  eval $cmd
else
  cmd=$cmd' &'
  echo ""
  echo $cmd
  eval $cmd
  
  if [ $? -eq 0 ]; then
    sleep 3
    tail "${log_dir}"/geth.log -n 50
    echo "The local standalone geth node has started."
    echo "The log file is located at '${log_dir}'/geth.log'."
  fi
fi
