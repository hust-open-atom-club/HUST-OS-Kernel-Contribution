#!/bin/bash

set -ex


REPO_NAME="openEuler-22.03-LTS-SP2"
TESTING_KERNEL="${REPO_NAME}.zip"
DOWNLOAD_URL="https://gitee.com/openeuler/kernel/repository/archive/openEuler-22.03-LTS-SP2.zip"

if [ -d kernel-${REPO_NAME} ]; then
    /bin/rm -rf kernel-${REPO_NAME}
fi

if [ -d smatch ]; then
    /bin/rm -rf smatch/
fi

wget $DOWNLOAD_URL -O ${TESTING_KERNEL}

# simply check file format
is_zip=$(file ${TESTING_KERNEL} | grep -c "Zip archive data")
if [ $is_zip -eq 1 ]; then
    unzip ${TESTING_KERNEL}
else
    echo "${TESTING_KERNEL} is corrupted"
    exit -1;
fi

cp -r ../smatch ${PWD}/

pushd smatch
make -j8
popd

pushd kernel-${REPO_NAME}
# openeuler: allyesconfig does not work, so we choose to an existing config
if [ -e ../config ]; then
    cp ../config .config
    make oldconfig
else
    make allyesconfig
fi
# make allyesconfig
# TODO: add a logic to verify if there exists a config file
cp ../config .config
../smatch/smatch_scripts/build_kernel_data.sh
#../smatch/smatch_scripts/test_kernel.sh
#../smatch_smatch_scripts/kchecker drivers/net/wireless
popd
