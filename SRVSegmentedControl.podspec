Pod::Spec.new do |s|
  s.name             = "SRVSegmentedControl"
  s.version          = "0.0.1"
  s.summary          = "A nice segmented control for iOS"
  s.homepage         = "https://github.com/samvoigt/SRVSegmentedControl"
  s.license          = 'MIT'
  s.author           = { "Sam Voigt" => "sam.voigt@gmail.com" }
  s.source           = { :git => "https://github.com/samvoigt/SRVSegmentedControl.git", :tag => '0.0.1' }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'SRVSegmentedControl/*.{h,m}'
  s.resource_bundles = {
	'SRVSegmentedControl' => ['SRVSegmentedControl/Resources/*.png']
	}

end