Pod::Spec.new do |s|
  s.name         = "XZYMyUtil"    #存储库名称
  s.version      = "1.0.0"      #版本号，与tag值一致
  s.summary      = "封装了AFNetWorking和YYCache缓存"  #简介
  s.description  = "1"  #描述
  s.homepage     = "https://github.com/740238622/XZYNetworking"      #项目主页，不是git地址
  s.license      = { :type => "MIT", :file => "LICENSE" }   #开源协议
  s.author       = { "xuziyou" => "740238622@qq.com" }  #作者
  s.platform     = :ios, "9.0"                  #支持的平台和版本号
  s.source       = { :git => "https://github.com/740238622/XZYNetworking.git", :tag => "1.0.0" }         #存储库的git地址，以及tag值
  s.source_files = "XZYNetworking/Classes/**/*.{h,m}" #需要托管的源代码路径
  s.requires_arc = true #是否支持ARC
  # s.dependency "Masonry", "~> 1.0.0"    #所依赖的第三方库，没有就不用写
  s.dependency "AFNetworking"
  s.dependency "YYCache"
end