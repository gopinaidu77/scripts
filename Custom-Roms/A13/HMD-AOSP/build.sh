#!/bin/bash
#
# RAGHU VARMA Build Script 
# Coded by RV 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Detail Versions

path=/var/lib/jenkins/workspace/HMD-AOSP

# credentials

Telegram_Api_code=$(cat $path/cred** | grep api | cut -d "=" -f 2)
chat_id=$(cat $path/cred** | grep id | cut -d "=" -f 2)
gitpassword=$(cat $path/cred** | grep git | cut -d "=" -f 2)
gitlpassword=$(cat $path/cred** | grep lab | cut -d "=" -f 2)

# D_T_Y
CUSTOM_DATE_YEAR="$(date -u +%Y)"
CUSTOM_DATE_MONTH="$(date -u +%m)"
CUSTOM_DATE_DAY="$(date -u +%d)"
CUSTOM_DATE_HOUR="$(date -u +%H)"
CUSTOM_DATE_MINUTE="$(date -u +%M)"
CUSTOM_BUILD_DATE="$CUSTOM_DATE_YEAR""$CUSTOM_DATE_MONTH""$CUSTOM_DATE_DAY"-"$CUSTOM_DATE_HOUR""$CUSTOM_DATE_MINUTE"

L1()
{
        sudo apt-get update 
        echo -ne '\n' | sudo apt-get upgrade
        echo -ne '\n' | sudo apt-get install git ccache schedtool lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib python-networkx libxml2-utils bzip2 libbz2-dev libghc-bzlib-dev squashfs-tools pngcrush liblz4-tool optipng libc6-dev-i386 gcc-multilib libssl-dev gnupg flex lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip python-pip python-dev libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev openjdk-8-jdk imagemagick device-tree-compiler mailutils-mh expect python3-requests python-requests android-tools-fsutils sshpass
        sudo swapon --show
        sudo fallocate -l 20G /swapfile
        ls -lh /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        sudo swapon --show
        sudo cp /etc/fstab /etc/fstab.bak
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
	git config --global user.email "raghuvarma331@gmail.com"
	git config --global user.name "RaghuVarma331"
	mkdir -p ~/.ssh  &&  echo "Host *" > ~/.ssh/config && echo " StrictHostKeyChecking no" >> ~/.ssh/config
	echo "# Allow Jenkins" >> /etc/sudoers && echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
} &> /dev/null

L2()
{
    cd $path
    mkdir bin
    PATH=$path/bin:$PATH
    curl https://storage.googleapis.com/git-repo-downloads/repo > $path/bin/repo
    chmod a+x $path/bin/repo
}

L3()
{
    cd $path
    git clone https://$gitpassword@github.com/HMD-AOSP/Private_keys -b android-13.0 keys
    mkdir aosp
    cd aosp
    echo -ne '\n' | repo init -u https://$gitpassword@github.com/HMD-AOSP/android_manifest.git -b android-13.0-PV --depth=1
    repo sync
    rm -r .repo
    git clone https://$gitlpassword@gitlab.com/RaghuVarma331/proprietary_vendor_gapps -b android-13.0-PIXEL vendor/gapps --depth=1
}

L4()
{
    cd $path/aosp
    git clone https://$gitpassword@github.com/HMD-AOSP/android_device_motorola_hanoip -b android-13.0-PV device/motorola/hanoip
    git clone https://$gitpassword@github.com/Motorola-SM6150/kernel-headers -b android-13.0 kernel/motorola/kernel-headers
    git clone https://$gitlpassword@gitlab.com/RaghuVarma331/proprietary_vendor_motorola -b android-13.0-PV --depth=1 vendor/motorola
}

L5()
{
    cd $path/aosp
    New HMD-AOSP for Moto G60 build started 
    
    $(date)
    "
    export SELINUX_IGNORE_NEVERALLOWS=true
    . build/envsetup.sh && lunch aosp_hanoip-userdebug && make -j$(nproc --all) target-files-package otatools
    sign_target_files_apks -o -d $path/keys $path/aosp/out/target/product/hanoip/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip $path/aosp/out/target/product/hanoip/signed-target-files.zip
    ota_from_target_files -k $path/keys/releasekey $path/aosp/out/target/product/hanoip/signed-target-files.zip $path/aosp/out/target/product/hanoip/HMD-AOSP_hanoip-13.0-$CUSTOM_BUILD_DATE.zip
    cp -r out/target/product/*/HMD-AOSP**.zip $path
    rm -r out/target/product/*
}




echo "----------------------------------------------------"
echo "Downloading tools.."
echo "----------------------------------------------------" 
L1
echo "----------------------------------------------------"
echo "Downloading repo bin.."
echo "----------------------------------------------------" 
L2
echo "----------------------------------------------------"
echo "Downloading HMD-AOSP Source Code.."
echo "----------------------------------------------------" 
L3
echo "----------------------------------------------------"
echo "Downloading Device sources.."
echo "----------------------------------------------------" 
L4
echo "----------------------------------------------------"
echo "Started building HMD-AOSP"
echo "----------------------------------------------------" 
L5
echo "----------------------------------------------------"
echo "Successfully build completed.."
echo "----------------------------------------------------" 
