Pod::Spec.new do |s|
  s.name         = "GMObjC"
  s.version      = "3.3.8"
  s.summary      = "国密 SM2、SM3、SM4 的 OC 封装，基于 OpenSSL。"
  s.description  = '基于 OpenSSL 封装 SM2、SM4 加解密、SM3 摘要算法、SM2 签名验签、ECDH 密钥协商、' \
                   'ASN1 编码解码、DER 编码解码，HMAC 算法等。'

  s.homepage     = "https://github.com/muzipiao/GMObjC"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "lifei" => "lifei_zdjl@126.com" }
  s.source = { :git => "https://github.com/muzipiao/GMObjC.git", :tag => s.version.to_s }

  s.source_files        = "GMObjC/**/*.{h,m}"
  s.public_header_files = "GMObjC/**/*.h"
  s.resource_bundles = {'GMObjC' => ['GMObjC/PrivacyInfo.xcprivacy']}
  s.ios.deployment_target = '9.0'

  s.requires_arc     = true
  s.static_framework = true
  s.frameworks       = "Security"
  s.dependency "GMOpenSSL"
end
