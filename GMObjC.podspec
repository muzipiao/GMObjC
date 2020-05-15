Pod::Spec.new do |spec|
  spec.name         = "GMObjC"
  spec.version      = "3.1.0"
  spec.summary      = "国密 SM2、SM3、SM4 的 OC 封装，基于 OpenSSL。"

  spec.description  = <<-DESC
  基于 OpenSSL 封装 SM2、SM4 加解密、SM3 摘要算法、SM2 签名验签、ECDH 密钥协商、ASN1 编码解码，DER 编码解码等。
                   DESC

  spec.homepage     = "https://github.com/muzipiao/GMObjC"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "lifei" => "lifei_zdjl@126.com" }

  spec.platform     = :ios, "8.0"

  spec.static_framework = true

  spec.source       = { :git => "https://github.com/muzipiao/GMObjC.git", :tag => "#{spec.version}" }

  spec.source_files  = "GMObjC/**/*.{h,m}"
  
  spec.public_header_files = "GMObjC/**/*.h"

  spec.frameworks  = "Foundation", "Security"
  
  spec.dependency "GMOpenSSL"

  spec.requires_arc = true

end
