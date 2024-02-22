#!/bin/bash

set -ex

REPO_NAME="linux-next-master"
TESTING_KERNEL="${REPO_NAME}.tar.gz"
DOWNLOAD_URL="https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/snapshot/linux-next-master.tar.gz"

# cleanup old kernel tree and smatch instance
if [ -d ${REPO_NAME} ]; then
    /bin/rm -rf ${REPO_NAME}
fi

if [ -d smatch ]; then
    /bin/rm -rf smatch/
fi

# download the corresponding kernel tree
wget $DOWNLOAD_URL -O ${TESTING_KERNEL}

# simply check file format
is_tgz=$(file ${TESTING_KERNEL} | grep -c "gzip compressed data")
if [ $is_tgz -eq 1 ]; then
    tar -zxf ${TESTING_KERNEL}
else
    echo "${TESTING_KERNEL} is corrupted"
    exit -1;
fi

# copy smatch into current folder (TODO: git archive to get compressed smatch)
cp -r ../smatch ${PWD}/

# build smatch
pushd smatch
make -j8
popd

pushd ${REPO_NAME}

# if allyesconfig does not work, choose to an existing config
if [ -e ../config ]; then
	cp ../config .config
	yes "" | make oldconfig
	cp .config ../config
else
	make allyesconfig
fi

# build cross-function database and test in the whole kernel
../smatch/smatch_scripts/build_kernel_data.sh
../smatch/smatch_scripts/test_kernel.sh
#../smatch/smatch_scripts/kchecker drivers/net/wireless

# copy smatch_warns.txt outside 
cp smatch_warns.txt ../
popd
