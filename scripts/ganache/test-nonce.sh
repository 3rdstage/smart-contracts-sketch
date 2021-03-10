#! /bin/bash

readonly script_dir=$(cd `dirname $0` && pwd)
cd "${script_dir}"

readonly eth_ver=`cat ../ganache-cli.properties | grep -E "^ethereum\.netVersion=" | sed -E 's/ethereum\.netVersion=//'`
readonly eth_host=`cat ../ganache-cli.properties | grep -E "^ethereum\.host=" | sed -E 's/ethereum\.host=//'`
readonly eth_port=`cat ../ganache-cli.properties | grep -E "^ethereum\.port=" | sed -E 's/ethereum\.port=//'`
readonly eth_gas_price=`cat ../ganache-cli.properties | grep -E "^ethereum\.gasPrice=" | sed -E 's/ethereum\.gasPrice=//'`
readonly eth_gas_limit=`cat ../ganache-cli.properties | grep -E "^ethereum\.gasLimit=" | sed -E 's/ethereum\.gasLimit=//'`
readonly eth_block_time=`cat ../ganache-cli.properties | grep -E "^ethereum\.blockTime=" | sed -E 's/ethereum\.blockTime=//'`
readonly eth_keys=`cat ../ganache-cli.properties | grep -E "^ethereum\.keys" | sed -E 's/ethereum\.keys\.[0-9]*=//'`

declare cnt=1

# TODO check if `jq` is available

accounts=`curl -s -X POST \
  --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":"'${cnt++}'"}' \
  http://${eth_host}:${eth_port}/ | jq .result`
  
  
# TODO check at least 2 accounts are available
# TODO check 1st account has enough balance

acct1=`echo ${accounts} | jq -r .[0]`
acct2=`echo ${accounts} | jq -r .[1]`

echo "Sender account : $acct1"
echo "Receiver account: $acct2"

# nonce for sender(acct1) before sanding 
nc10=`curl -s -X POST \
     --data '{"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["'${acct1}'","latest"],"id":2}' \
     http://${eth_host}:${eth_port}/ | jq -r .result`

echo "Sender's nonce before transactions : $nc10"

declare n=3
for i in `eval "echo {1..$n}"`; do
  tx_hash=`curl -s -X POST \
      --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "'${acct1}'","to": "'${acct2}'","value": "0x400"}],"id":"'${cnt++}'"}' \
      http://${eth_host}:${eth_port}/ | jq -r .result`

  echo "Transacion hash : $tx_hash"
done

# nonce for sender(acct1) before sanding 
nc11=`curl -s -X POST \
     --data '{"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["'${acct1}'","latest"],"id":2}' \
     http://${eth_host}:${eth_port}/ | jq -r .result`

echo "Sender's nonce after ${n} transactions : $nc11"

