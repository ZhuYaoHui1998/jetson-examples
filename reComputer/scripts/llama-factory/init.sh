#!/bin/bash


# check L4T_VERSION
# reference https://github.com/dusty-nv/jetson-containers/blob/master/jetson_containers/l4t_version.sh
ALLOWED_L4T_VERSIONS=("35.3.1" "35.4.1" "35.5.0")

ARCH=$(uname -i)
if [ $ARCH = "aarch64" ]; then
    L4T_VERSION_STRING=$(head -n 1 /etc/nv_tegra_release)

    if [ -z "$L4T_VERSION_STRING" ]; then
        L4T_VERSION_STRING=$(dpkg-query --showformat='${Version}' --show nvidia-l4t-core)
        L4T_VERSION_ARRAY=(${L4T_VERSION_STRING//./ })    
        L4T_RELEASE=${L4T_VERSION_ARRAY[0]}
        L4T_REVISION=${L4T_VERSION_ARRAY[1]}
    else
        L4T_RELEASE=$(echo $L4T_VERSION_STRING | cut -f 2 -d ' ' | grep -Po '(?<=R)[^;]+')
        L4T_REVISION=$(echo $L4T_VERSION_STRING | cut -f 2 -d ',' | grep -Po '(?<=REVISION: )[^;]+')
    fi

    L4T_REVISION_MAJOR=${L4T_REVISION:0:1}
    L4T_REVISION_MINOR=${L4T_REVISION:2:1}

    L4T_VERSION="$L4T_RELEASE.$L4T_REVISION"
    echo $L4T_VERSION
elif [ $ARCH != "x86_64" ]; then
    echo "unsupported architecture:  $ARCH"
    exit 1
fi

echo "L4T_VERSION: $L4T_VERSION"
if [[ ! " ${ALLOWED_L4T_VERSIONS[@]} " =~ " ${L4T_VERSION} " ]]; then
    echo "L4T_VERSION is not in the allowed versions list. Exiting."
    exit 1
fi


BASE_PATH=/home/$USER/reComputer
mkdir -p $BASE_PATH/
JETSON_REPO_PATH="$BASE_PATH/jetson-containers"
BASE_JETSON_LAB_GIT="https://github.com/dusty-nv/jetson-containers"
if [ -d $JETSON_REPO_PATH ]; then
    echo "jetson-ai-lab existed."
else
    echo "jetson-ai-lab does not installed. start init..."
    cd $BASE_PATH/
    git clone --depth=1 $BASE_JETSON_LAB_GIT
    cd $JETSON_REPO_PATH
    bash install.sh
fi

