#! /bin/bash

readonly script_dir=$(cd `dirname $0` && pwd)

cd "${script_dir}"

readonly eth_host=`cat ganache-cli.properties | grep -E "^ethereum\.host=" | sed -E 's/ethereum\.host=//'`
readonly eth_port=`cat ganache-cli.properties | grep -E "^ethereum\.port=" | sed -E 's/ethereum\.port=//'`

sudo tcpdump -nA -s 0 -i any tcp and host ${eth_host} and port ${eth_port} and greater 100
