#! /bin/bash

# TODO
#   - Check the availability of the TCP port for Linux
#   - Setup 'logrotate' for Linux

readonly verbose=1  # 1: true, 0: false - Hard coded yet
readonly dryrun=0   # 1: true, 0: false - Not Used Yet
readonly uname=`uname -s`  # OS type
readonly script_dir=$(cd `dirname $0` && pwd)

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
readonly eth_keys=`cat ganache-cli.properties | grep -E "^ethereum\.keys" | sed -E 's/ethereum\.keys\.[0-9]*=//'`

if [ $verbose -ne 0 ]; then
  echo "Ethereum Network ID : $eth_ver"
  echo "Ethereum Client Host Address: $eth_host"
  echo "Ethereum Client TCP Port: $eth_port"
  echo "Ethereum Gas Limit: $eth_gas_limit"
  echo "Ethereum Gas Price: $eth_gas_price"
  echo "Ethereum Private Keys for Accounts: "
  for key in $eth_keys; do echo "    $key"; done
  echo "uname: $uname"
fi

case $uname in
Linux)  #Linux
  echo "Current system is 'Linux'"
  ;;
MINGW*)  #Git Bash on Windows
  echo "Curreun system is 'Windows'"
  # check whether the address is alreasy in use or not
  if [ `netstat -anp tcp | awk '$4 == "LISTENING" {print $2}' | grep -E "^($eth_host|0.0.0.0):$eth_port$" | wc -l` -gt 0 ]; then
    readonly pid=`netstat -anop tcp | awk '$4 == "LISTENING" {print $2 " " $5}' | grep -E "^($eth_host|0.0.0.0):$eth_port\s" | head -n 1 | awk '{print $2}'`
    echo "The address '$eth_host:$eth_port' is already in use by the process of which PID is $pid."
    echo "Fail to start ganache-cli."
    exit 500
  fi
  ;;
Darwin*) #Bash on macOS
  echo "Current system is 'macOS'"
  ;;
*)
  echo "Current system is Unknown of which 'uname -s' shows '$uname'."
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
            --gasLimit $eth_gas_limit"

if [ -n "$eth_keys" ]; then
  echo ""
  echo "Private keys for Ethereum accounts are explicitly specified. They will be used."
  for key in $eth_keys;
    do cmd="${cmd} --account=\"${key},10000000000000000000000\""
  done;
else
  if [ -z "$BIP39_MNEMONIC" ]; then
    echo "'BIP39_MNEMONIC' env. variable is not defined, so implicit default mnemonic will be used."
    echo "If you want to use user defined mnemonic, define it via 'BIP39_MNEMONIC' env. variable and restart this script."
    cmd="${cmd} --deterministic"
  else
    echo "'BIP39_MNEMONIC' env. variable is defined, so it will be used."
    cmd="${cmd} --mnemonic '$BIP39_MNEMONIC'"
  fi
  cmd="${cmd} --defaultBalanceEther 10000 --accounts 10 --secure"
fi

cmd="${cmd} --unlock 0 --unlock 1 --unlock 2 --unlock 3 --unlock 4 \
            --hardfork 'petersburg' \
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
    tail "${log_dir}"/ganache.log -n 50
    echo "The loacal Ganache has started."
    echo "The log file is located at '${log_dir}/ganache.log'."
  fi
fi


