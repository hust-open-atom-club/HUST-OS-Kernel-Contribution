#!/bin/bash

#set -ex

TESTING_KERNEL="kernel.tar.gz"

# Display help function
display_help() {
    echo "Usage: $0 [option...] " >&2
    echo
    echo "   -f, --file                 Provide the source code of testing kernel"
    echo "   -h, --help                 Display help message"
    echo
}

while true; do
    if [ $# -eq 0 ];then
	#echo $#
	break
    fi
    case "$1" in
        -h | --help)
            display_help
            exit 0
            ;;
        -f | --file)
	    TESTING_KERNEL=$2
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)  # No more options
            break
            ;;
    esac
done

if [ -d linux ]; then
    rm -rf linux/
fi

is_tgz=$(file ${TESTING_KERNEL} | grep -c "gzip compressed data")
if [ $is_tgz -eq 1 ];then
    tar -zxf ${TESTING_KERNEL} && mv linux-* linux
else
    unzip -qq ${TESTING_KERNEL} -d linux
fi

pushd linux
make allyesconfig
../../smatch/smatch_scripts/build_kernel_data.sh
../../smatch/smatch_scripts/test_kernel.sh
popd
