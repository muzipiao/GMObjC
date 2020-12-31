# GMOpenSSL

[![Version](https://img.shields.io/cocoapods/v/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)
[![License](https://img.shields.io/cocoapods/l/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)
[![Platform](https://img.shields.io/cocoapods/p/GMOpenSSL.svg?style=flat)](https://cocoapods.org/pods/GMOpenSSL)

cocoapods 不支持直接集成 OpenSSL，将 OpenSSL 源码编译为 framework，并发布至 cocoapods，名称为 GMOpenSSL，方便通过 cocoapods 集成。

## 版本映射

|GMOpenSSL 版本|OpenSSL 版本|支持架构|Bitcode|兼容iOS版本|
|:---:|:---:|:---:|:---:|:---:|
|2.2.0|1.1.1i|x86_64 arm64 arm64e armv7 armv7s|包含|>= iOS 8.0|
|2.2.1|1.1.1i|arm64 arm64e|包含|>= iOS 8.0|
|2.2.2|1.1.1i|x86_64 arm64 arm64e|包含|>= iOS 8.0|

## CocoaPods

CocoaPods 是最简单方便的集成方法，编辑 Podfile 文件，添加

```ruby
pod 'GMOpenSSL'
```

然后执行 `pod install` 即可，默认最新版本。

## 自定义编译 OpenSSL

如果编译的静态库不能满足需求，可以自行运行脚本编译。工程目录下有一个名称为 OpenSSL_BUILD 的文件夹，依次执行 cd 切换到当前目录下，然后执行`./build-libssl.sh`，待执行完毕再执行`./create-openssl-framework.sh`，即可看到编译完成的 openssl.framwork。

打包完成的静态库并未暴露国密的头文件，解压缩下载的 openssl 压缩包，如 openssl-1.1.1i.tar.gz，将 include/crypto/ 路径下的 sm2.h、sm3.h，sm4.h 都拖到 openssl.framework/Headers 文件夹下即可。

opensslconf.h 头文件条件编译末尾做如下修改

```c
# error Unable to determine target or target not included in OpenSSL build
```
修改为：

```c
# include <openssl/opensslconf_ios_arm64.h>
```
