#!/bin/bash
#清空当前文件夹下的android目录
rm -r android
# 清空上次的编译
make clean
#你自己的NDK路径.
export NDK=/home/roo/ndk/android-ndk-r21

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

SYSROOT=$TOOLCHAIN/sysroot

#目标android版本
ANDROID_API=29
export CFLAGS="-D__ANDROID_API__=$ANDROID_API"
export CXXFLAGS="-D__ANDROID_API__=$ANDROID_API"

build_android()
{
echo "Compiling FFmpeg for $CPU"
./configure \
    --disable-x86asm \
    --prefix=$PREFIX \
    --enable-neon \
    --enable-hwaccels \
    --enable-gpl \
    --enable-postproc \
    --enable-shared \
    --disable-static \
    --enable-jni \
    --enable-mediacodec \
    --enable-decoder=h264_mediacodec \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --enable-avdevice \
    --disable-doc \
    --disable-symver \
    --cross-prefix=$CROSS_PREFIX \
    --cc=${ANDROID_CROSS_PREFIX}-clang \
    --target-os=android \
    --arch=$ARCH \
    --cpu=$CPU \
    --enable-cross-compile \
    --sysroot=$SYSROOT \
    $ADDITIONAL_CONFIGURE_FLAG
make clean
make -j8
make install
echo "The Compilation of FFmpeg for $CPU is completed"
}

#armv8-a
ARCH=arm64
CPU=armv8-a
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
ANDROID_CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android$ANDROID_API
PREFIX=$(pwd)/android/$CPU
build_android
