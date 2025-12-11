Pod::Spec.new do |s|
  s.name             = 'libvips_ffi_macos'
  s.version          = '1.0.0'
  s.summary          = 'Pre-compiled libvips for macOS'
  s.description      = <<-DESC
Pre-compiled libvips binaries for macOS. Part of the libvips_ffi package family.
                       DESC
  s.homepage         = 'https://github.com/CaiJingLong/libvips_ffi'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CaiJingLong' => 'cjl_spy@163.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform         = :osx, '10.14'
  s.swift_version    = '5.0'

  # TODO: Add pre-compiled libvips when available
  # s.vendored_libraries = 'Libraries/libvips.dylib'
end
