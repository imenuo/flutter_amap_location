#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_amap_location'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.frameworks = 'JavaScriptcore', 'SystemConfiguration', 'CoreTelephony', 'CoreLocation', 'Security', 'ExternalAccessory'
  s.libraries = 'z', 'c++', 'stdc++.6.0.9'
  
  s.vendored_frameworks = 'Vendors/*.framework'
  s.preserve_paths = 'Vendors/*.framework'
  s.pod_target_xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => '$(PODS_ROOT)/Vendors/' }
  
  s.ios.deployment_target = '9.0'
  
  s.prepare_command = <<-EOF
    rm -rf Vendors/AMapFoundationKit.framework/Modules
    mkdir Vendors/AMapFoundationKit.framework/Modules
    touch Vendors/AMapFoundationKit.framework/Modules/module.modulemap
    cat <<-EOF > Vendors/AMapFoundationKit.framework/Modules/module.modulemap
    framework module AMapFoundationKit {
    umbrella header "AMapFoundationKit.h"
    export *
    link "z"
    link "c++"
    link "stdc++.6.0.9"
    }
    \EOF

    rm -rf Vendors/AMapLocationKit.framework/Modules
    mkdir Vendors/AMapLocationKit.framework/Modules
    touch Vendors/AMapLocationKit.framework/Modules/module.modulemap
    cat <<-EOF > Vendors/AMapLocationKit.framework/Modules/module.modulemap
    framework module AMapLocationKit {
      umbrella header "AMapLocationKit.h"
      export *
      link "z"
      link "c++"
      link "stdc++.6.0.9"
    }
    \EOF
  EOF
end
