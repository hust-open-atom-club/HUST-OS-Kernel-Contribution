#!/bin/bash

set -ex

REPO_NAME="linux-master"
TESTING_KERNEL="${REPO_NAME}.tar.gz"
DOWNLOAD_URL="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-master.tar.gz"

if [ -d ${REPO_NAME} ]; then
    /bin/rm -rf linux/
fi

if [ -d smatch ]; then
    /bin/rm -rf smatch/
fi

wget $DOWNLOAD_URL -O ${TESTING_KERNEL}

# simply check file format
is_tgz=$(file ${TESTING_KERNEL} | grep -c "gzip compressed data")
if [ $is_tgz -eq 1 ]; then
    tar -zxf ${TESTING_KERNEL}
else
    echo "${TESTING_KERNEL} is corrupted"
    exit -1;
fi

cp -r ../smatch ${PWD}/

pushd smatch
make -j8
popd

pushd ${REPO_NAME}
make allyesconfig
../smatch/smatch_scripts/build_kernel_data.sh
#../smatch/smatch_scripts/test_kernel.sh
#../smatch_smatch_scripts/kchecker drivers/net/wireless
popd
