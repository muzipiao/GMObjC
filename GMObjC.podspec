Pod::Spec.new do |spec|
  spec.name         = "GMObjC"
  spec.version      = "1.0.0"
  spec.summary      = "基于 OpenSSL 封装国密 sm2 和 sm4 加解密。"

  spec.description  = <<-DESC
  OpenSSL 1.1.1 以上版本支持国密加密，纯 C 的 Api 不方便使用，使用 OC 封装。
                   DESC

  spec.homepage     = "https://github.com/muzipiao/GMObjC"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "lifei" => "lifei_zdjl@126.com" }

  spec.platform     = :ios, "8.0"

  spec.static_framework = true

  spec.source       = { :git => "https://github.com/muzipiao/GMObjC.git", :tag => "#{spec.version}" }


  spec.source_files  = "GMObjC/Classes/**/*.{h,m}"

  spec.framework  = "Foundation"

  spec.requires_arc = true

  spec.dependency "GMOpenSSL"

end
