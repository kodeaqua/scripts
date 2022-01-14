# This script created by Kodeaqua <https://github.com/kodeaqua>
# For those who lazy to setting up environment for building android kernel
# Constants (do not change!)
export OG_PATH="$PATH"
export CONF_DIR="${HOME}/.config/${USER}"
export PROD_DIR="${HOME}/products"
export AK3_DIR="${HOME}/AnyKernel3"

# Checking needed configs
if ! [[ -d $CONF_DIR ]]; then
    mkdir -p $CONF_DIR
fi
if ! [[ -f ${CONF_DIR}/arch ]]; then
    echo "" > ${CONF_DIR}/arch
fi
if ! [[ -f ${CONF_DIR}/subarch ]]; then
    echo "" > ${CONF_DIR}/subarch
fi
if ! [[ -f ${CONF_DIR}/args ]]; then
    echo "" > ${CONF_DIR}/args
fi
if ! [[ -f ${CONF_DIR}/user ]]; then
    echo $USER > ${CONF_DIR}/user
fi
if ! [[ -f ${CONF_DIR}/host ]]; then
    cat /etc/hostname > ${CONF_DIR}/host
fi
if ! [[ -f ${CONF_DIR}/device ]]; then
    echo "" > ${CONF_DIR}/device
fi
if ! [[ -f ${CONF_DIR}/kernel ]]; then
    echo "Kernel" > ${CONF_DIR}/kernel
fi
if ! [[ -f ${CONF_DIR}/ak3 ]]; then
    echo "https://github.com/osm0sis/AnyKernel3.git" > ${CONF_DIR}/ak3
fi

# Dynamic variables (you can changes it later)
export ARCH="$(cat ${CONF_DIR}/arch)"
export SUBARCH="$(cat ${CONF_DIR}/subarch)"
export KBUILD_BUILD_USER="$(cat ${CONF_DIR}/user)"
export KBUILD_BUILD_HOST="$(cat ${CONF_DIR}/host)"
export MAKE_ARGS="$(cat ${CONF_DIR}/args)"
export DEVICE="$(cat ${CONF_DIR}/device)"
export KERNEL="$(cat ${CONF_DIR}/kernel)"

# Setting up
if [[ $ARCH == "arm64" ]]; then
    export CROSS_COMPILE="aarch64-linux-gnu-"
elif [[ $ARCH == "arm" ]]; then
    export CROSS_COMPILE="arm-linux-gnueabi-"
fi
if [[ $SUBARCH == "arm" ]]; then
    export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
fi
if [[ -f ${CONF_DIR}/compiler ]]; then
    export PATH="$(cat $CONF_DIR/compiler):$PATH"
fi
if ! [[ $(which figlet) ]];  then
    sudo apt update -y && sudo apt install figlet -y
fi
if ! [[ -d $AK3_DIR ]]; then
    git clone $(cat ${CONF_DIR}/ak3) $AK3_DIR
fi

# Begin declaring functions
function setak3()
{
    read -p "Enter the new url: " ak3
    echo $ak3 > ${CONF_DIR}/ak3
    rm -rf $AK3_DIR && git clone $ak3 $AK3_DIR
}

function setcc()
{
    read -p  "Enter the new compiler path: " compiler
    echo $compiler > ${CONF_DIR}/compiler
    export PATH="$OG_PATH" && export PATH="${compiler}:$PATH"
}

function setarch()
{
    read -p "Enter the new arch: " arch
    echo $arch > ${CONF_DIR}/arch
    read -p "Enter the new subarch: " subarch
    echo $subarch > ${CONF_DIR}/subarch
    export ARCH="$(cat ${CONF_DIR}/arch)" && export SUBARCH="$(cat ${CONF_DIR}/subarch)"
}

function setinfo()
{
    read -p "Enter the new user: " user
    echo $user > ${CONF_DIR}/user
    read -p "Enter the new host: " host
    echo $host > ${CONF_DIR}/host
    export KBUILD_BUILD_USER="$user" && export KBUILD_BUILD_HOST="$host"
}

function setargs()
{
    read -p "Enter the new args: " args
    echo $args > ${CONF_DIR}/args
    export MAKE_ARGS="$args"
}

function setdev()
{
    read -p "Enter the new device: " device
    echo $device > ${CONF_DIR}/device
    read -p "Enter the new kernel name: " kernel
    echo $kernel > ${CONF_DIR}/kernel
    export DEVICE="$device" && export KERNEL="$kernel"
}

function kbuild()
{
    TIME_START=$(date +"%s")
    make -j$(nproc --all) O=out $MAKE_ARGS
    if [[ -f $(pwd)/out/arch/${ARCH}/boot/Image ]]; then
        if [[ -f $(pwd)/out/arch/${ARCH}/boot/Image.gz-dtb ]]; then
            cp $(pwd)/out/arch/${ARCH}/boot/Image.gz-dtb $AK3_DIR
        elif [[ -f $(pwd)/out/arch/${ARCH}/boot/Image.gz ]]; then
            cp $(pwd)/out/arch/${ARCH}/boot/Image.gz $AK3_DIR
        elif [[ -f $(pwd)/out/arch/${ARCH}/boot/Image ]]; then
            cp $(pwd)/out/arch/${ARCH}/boot/Image.gz $AK3_DIR
        fi
        cd $AK3_DIR
        zip -r9 "${PROD_DIR}/${KERNEL}_${DEVICE}-$(date +"%Y%m%d-%H%M").zip" * -x .git README.md *placeholder
        cd $OLDPWD
        TIME_END=$(date +"%s") && DIFF=$(($TIME_END - $TIME_START))
        echo "============================================"
        figlet "$KERNEL"
        figlet "$DEVICE"
        echo "============================================"
        echo "Target: $PROD_DIR/${KERNEL}_${DEVICE}-$(date +"%Y%m%d-%H%M").zip"
        echo "Build completed in $(($DIFF / 60)) minute(s) and $((DIFF % 60)) seconds"
        echo "Compiled by $KBUILD_BUILD_USER at $KBUILD_BUILD_HOST using $(nproc --all) core(s)";
    else
        echo "Whooa! Build failed :("
    fi
}

function kconfig()
{
    make ${DEVICE}_defconfig O=out
}

function kclean()
{
    make clean O=out && make mrproper O=out
}
# End declaring functions
# EOL
