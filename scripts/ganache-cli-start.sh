#! /bin/bash

# TODO
#   - Check the availability of the TCP port for Linux
#   - Setup 'logrotate' for Linux

readonly verbose=0  # 1: true, 0: false - Hard coded yet
readonly dryrun=0   # 1: true, 0: false - Not Used Yet
readonly uname=`uname -s`  # OS type
readonly script_dir=$(cd `dirname $0` && pwd)

if [ -z "$BIP39_MNEMONIC" ]; then
  echo "Environmental variable of 'BIP39_MNEMONIC' should be defined to run this script."
  exit 100
fi

declare data_dir
declare log_dir
case $uname in
Linux)  #Linux
  data_dir='/var/lib/ganache-cli'
  log_dir='/var/log'
  ;;
MINGW*)  #Git Bash on Windows
  readonly run_dir=$(mkdir -p "${script_dir}/../run/ganache" && cd "${script_dir}/../run/ganache" && pwd)
  data_dir=${run_dir}/data
  log_dir=${run_dir}
  ;;
Darwin*) #Bash on macOS
  readonly run_dir=$(mkdir -p "${script_dir}/../run/ganache" && cd "${script_dir}/../run/ganache" && pwd)
  data_dir=${run_dir}/data
  log_dir=${run_dir}
  ;;
*)
  echo "The current system is Unknown of which 'uname -s' shows '$uname'."
  exit 600
esac


# check whether GNU getopt is available or not
if [ `getopt --test; echo $?` -ne 4 ]; then
  echo "The avaiable 'getopt' is not GNU getopt which supports long options."
  echo "For MacOS, install 'gnu-getopt' refering 'https://formulae.brew.sh/formula/gnu-getopt'."
  exit 410
fi

options=$(getopt -o rb --long "refresh,background" --name 'ganache-cli-start-options' -- "$@");

if [ $? -ne 0 ]; then
  command=${0##*/}
  echo "Unable to parse command line, which expect '$command [-r|--refresh] [-b|--background]'."
  echo ""
  exit 400
fi

eval set -- "$options"

declare refreshes=0   #false
declare backgrounds=0   #false
while true; do
  case "$1" in
    -r | --refresh )
      echo "refresh specified"
      refreshes=1
      shift ;;
    -b | --background )
      backgrounds=1
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

readonly eth_ver=`cat ganache-cli.properties | grep -E "^ethereum\.netVersion=" | sed -E 's/ethereum\.netVersion=//'`
readonly eth_host=`cat ganache-cli.properties | grep -E "^ethereum\.host=" | sed -E 's/ethereum\.host=//'`
readonly eth_port=`cat ganache-cli.properties | grep -E "^ethereum\.port=" | sed -E 's/ethereum\.port=//'`
readonly eth_gas_price=`cat ganache-cli.properties | grep -E "^ethereum\.gasPrice=" | sed -E 's/ethereum\.gasPrice=//'`
readonly eth_gas_limit=`cat ganache-cli.properties | grep -E "^ethereum\.gasLimit=" | sed -E 's/ethereum\.gasLimit=//'`

if [ $verbose -ne 0 ]; then
  echo "eth_ver: $eth_ver"
  echo "eth_host: $eth_host"
  echo "eth_port: $eth_port"
  echo "eth_gas_price: $eth_gas_price"
  echo "eth_gas_limit: $eth_gas_limit"
  echo "uname: $uname"
fi

case $uname in
Linux)  #Linux
  echo "The current system is 'Linux'"
  ;;
MINGW*)  #Git Bash on Windows
  echo "The curreun system is 'Windows'"
  # check whether the address is alreasy in use or not
  if [ `netstat -anp tcp | awk '$4 == "LISTENING" {print $2}' | grep -E "^($eth_host|0.0.0.0):$eth_port$" | wc -l` -gt 0 ]; then
    readonly pid=`netstat -anop tcp | awk '$4 == "LISTENING" {print $2 " " $5}' | grep -E "^($eth_host|0.0.0.0):$eth_port\s" | head -n 1 | awk '{print $2}'`
    echo "The address '$eth_host:$eth_port' is already in use by the process of which PID is $pid."
    echo "Fail to start ganache-cli."
    exit 500
  fi
  ;;
Darwin*) #Bash on macOS
  echo "The current system is 'macOS'"
  ;;
*)
  echo "The current system is Unknown of which 'uname -s' shows '$uname'."
  exit 600
esac

# Ganache CLI : https://github.com/trufflesuite/ganache-cli#using-ganache-cli
# BIP 32 : https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
# BIP 39 : https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
#
# Options
#   - gasLimit : The block gas limit (defaults to 0x6691b7)
#   - gasPrice: The price of gas in wei (defaults to 20000000000)

cmd="ganache-cli --networkId $eth_ver \
            --host '$eth_host' \
            --port $eth_port \
            --gasPrice $eth_gas_price \
            --gasLimit $eth_gas_limit \
            --mnemonic '$BIP39_MNEMONIC' \
            --defaultBalanceEther 10000 \
            --accounts 10 --secure \
            --unlock 0 --unlock 1 --unlock 2 --unlock 3 --unlock 4 \
            -k 'constantinople' \
            --blockTime 0 \
            --db '${data_dir}' >> '${log_dir}'/ganache.log 2>&1"

if [ "$uname" == "Linux" ]; then
  cmd="sudo sh -c \"$cmd\""
  # cmd="sudo sh -c -- $cmd"
fi

if [ $dryrun -ne 0 ]; then
  echo $cmd
  echo ""
  echo "This is 'DRY' run."
  echo "The right above command would be executed, if run again without 'dryrun' option."
  exit 700
fi

if [ $backgrounds -eq 0 ]; then
  echo $cmd
  eval $cmd
else
  cmd=$cmd' &'
  echo $cmd
  eval $cmd

  if [ $? -eq 0 ]; then
    sleep 3
    tail "${log_dir}"/ganache.log -n 50
    echo "The loacal Ganache has started."
    echo "The log file is located at '${log_dir}/ganache.log'."
  fi
fi


