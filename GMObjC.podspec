Pod::Spec.new do |spec|
  spec.name         = "GMObjC"
  spec.version      = "2.0.0"
  spec.summary      = "国密 sm2、sm4 加解密，sm2 签名验签，sm3 摘要算法 OC 封装，基于 OpenSSL。"

  spec.description  = <<-DESC
  OpenSSL 1.1.1 以上版本支持国密加密，基于 OpenSSL 封装 sm2、sm4 加解密，sm2 签名验签，sm3 摘要算法。
                   DESC

  spec.homepage     = "https://github.com/muzipiao/GMObjC"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "lifei" => "lifei_zdjl@126.com" }

  spec.platform     = :ios, "8.0"

  spec.static_framework = true

  spec.source       = { :git => "https://github.com/muzipiao/GMObjC.git", :tag => "#{spec.version}" }


  spec.source_files  = "GMObjC/Classes/**/*.{h,m}"
  
  spec.public_header_files = "GMObjC/Classes/**/*.h"

  spec.framework  = "Foundation"

  spec.requires_arc = true

  spec.dependency "GMOpenSSL"

end
