Pod::Spec.new do |s|
  s.name         = "GMObjC"
  s.version      = "4.0.1"
  s.summary      = "国密 SM2、SM3、SM4 的 OC 封装，基于 OpenSSL。"
  s.description  = '基于 OpenSSL 封装 SM2、SM4 加解密、SM3 摘要算法、SM2 签名验签、ECDH 密钥协商、' \
                   'ASN1 编码解码、DER 编码解码、HMAC 算法，CER证书读取等。'

  s.homepage     = "https://github.com/muzipiao/GMObjC"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "lifei" => "lifei_zdjl@126.com" }
  s.source       = { :git => "https://github.com/muzipiao/GMObjC.git", :tag => s.version.to_s }

  s.source_files        = "GMObjC/**/*.{h,m}"
  s.public_header_files = "GMObjC/**/*.h"
  s.resource_bundles    = {'GMObjC' => ['GMObjC/PrivacyInfo.xcprivacy']}

  s.requires_arc = true
  s.frameworks   = "Security"
  
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.13'

  s.dependency "GMOpenSSL", "~> 3.1.0"
end
