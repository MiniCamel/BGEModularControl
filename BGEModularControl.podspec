Pod::Spec.new do |s|
    s.name             = 'BGEModularControl'
    s.version          = '1.0.0'
    s.summary          = '模块分类控件封装'
    s.description      = <<-DESC
        a custom control for modular list, base UICollectionView and Masonry, support paging and cyclic scroll, support customize cell style.
    DESC
    s.homepage         = 'https://github.com/MiniCamel/BGEModularControl'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Bge' => 'tiandiwuji1223@163.com' }
    s.source           = { :git => 'https://github.com/MiniCamel/BGEModularControl.git', :tag => s.version.to_s }
    s.platform = :ios, '9.0'
    s.ios.deployment_target = '9.0'
    s.source_files = 'BGEModularControl/Classes/**/*'
    s.dependency 'Masonry'
    s.requires_arc = true
end
