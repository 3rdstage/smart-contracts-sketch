#! /bin/bash

readonly base_dir=$(cd `dirname $0` && cd .. && pwd)

# echo ${base_dir}
cd ${base_dir}

# ./node_modules/.bin/remixd --shared-folder ./ --remix-ide https://remix.ethereum.org
npx remixd --shared-folder "${base_dir}" --remix-ide https://remix.ethereum.org
