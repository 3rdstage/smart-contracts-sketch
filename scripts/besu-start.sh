#! /bin/bash

# TODO

# References
#   - Start Besu : https://besu.hyperledger.org/en/stable/HowTo/Get-Started/Starting-node/
#   - Besu CLI : https://besu.hyperledger.org/en/stable/Reference/CLI/CLI-Syntax/
#   - Besu Genesis File Syntax : https://besu.hyperledger.org/en/stable/Reference/Config-Items/
#   - https://besu.hyperledger.org/en/stable/Tutorials/Private-Network/Create-IBFT-Network/


readonly uname=`uname -s`  # OS type
readonly script_dir=$(cd `dirname $0` && pwd)

declare data_dir
declare log_dir

# Locate directories for data and logs
case $uname in
Linux)  #Linux
  data_dir='/var/lib/besu'
  log_dir='/var/log'
  ;;
MINGW*)  #Git Bash on Windows
  readonly run_dir=$(mkdir -p "${script_dir}/../run/besu" && cd "${script_dir}/../run/besu" && pwd)
  data_dir=${run_dir}/data
  log_dir=${run_dir}
  ;;
Darwin*) #Bash on macOS
  readonly run_dir=$(mkdir -p "${script_dir}/../run/besu" && cd "${script_dir}/../run/besu" && pwd)
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

options=$(getopt -o rdbv --long "refresh,dryrun,background,verbose" --name 'besu-start-options' -- "$@");

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
cmd="besu --genesis-file='${script_dir}'/besu-genesis.json \
      --miner-enabled \
      --config-file='${script_dir}/besu-config.toml' \
      --data-path='${data_dir}' >> '${log_dir}'/besu.log 2>&1"

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
    tail "${log_dir}"/besu.log -n 50
    echo "The local standalone Besu has started."
    echo "The log file is located at '${log_dir}'/besu.log'."
  fi
fi
