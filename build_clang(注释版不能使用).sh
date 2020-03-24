#!/bin/bash
#仅参考注释版不能使用
NDK=/home/roo/ndk/android-ndk-r21   #填写自己ndk的解压路径
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
#这里修改的是最低支持的android sdk版本（r20版本ndk中armv8a、x86_64最低支持21，armv7a、x86最低支持16）
API=29   #API 级别将默认为给定架构支持的最低级别

build_android()
{
#相当于Android中Log.i
echo "Compiling FFmpeg for $CPU"
#调用同级目录下的configure文件
./configure \
#指定输出目录
    --prefix=$PREFIX \
#各种配置项，想详细了解的可以打开configure文件找到Help options:查看
    --enable-neon \
    --disable-hwaccels \
    --disable-gpl \
    --disable-postproc \
#配置跨平台编译，同时需要disable-static
   # --disable-yasm\ #不使用汇编
    --enable-shared \
    --enable-jni \
    --disable-mediacodec \
    --disable-decoder=h264_mediacodec \
#use 
    --disable-all   
#配置跨平台编译，同时需enable-shared   
    --disable-static \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-avdevice \
    --disable-doc \
    --disable-symver \
#关键点1.指定交叉编译工具目录
    --cross-prefix=$CROSS_PREFIX \
#关键点2.指定目标平台为android
    --target-os=android \
#关键点3.指定cpu类型
    --arch=$ARCH \
#关键点4.指定cpu架构
    --cpu=$CPU \
#超级关键点5.指定c语言编译器
    --cc=$CC
    --cxx=$CXX
#关键点6.开启交叉编译
    --enable-cross-compile \
#超级关键7.配置编译环境c语言的头文件环境
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS" \
    $ADDITIONAL_CONFIGURE_FLAG
make clean
make
make install
echo "The Compilation of FFmpeg for $CPU is completed"
}

#armv8-a
ARCH=arm64
CPU=armv8-a
#r20版本的ndk中所有的编译器都在/android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/目录下（clang）
CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
#头文件环境用的不是/android-ndk-r20/sysroot,而是编译器//android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/sysroot
SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot
#交叉编译工具目录,对应关系如下(不明白的可以看下图)
# armv8a -> arm64 -> aarch64-linux-android-
# armv7a -> arm -> arm-linux-androideabi-
# x86 -> x86 -> i686-linux-android-
# x86_64 -> x86_64 -> x86_64-linux-android-
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
#输出目录
PREFIX=$(pwd)/android/$CPU
OPTIMIZE_CFLAGS="-march=$CPU"
#方法调用
build_android

