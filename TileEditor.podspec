Pod::Spec.new do |s|
    s.name = 'TileEditor'
    s.version = '0.3.0'
    s.license = ''
    s.homepage = 'http://www.yellokrow.com'
    s.authors = 'yellokrow'
    s.summary = 'TileEditor framework for pixel manipulation and palette selection'
    s.source  = { :path => 'TileEditor/*.swift' }
    s.source_files = 'TileEditor/*.swift'
    s.osx.deployment_target = '10.11'
    s.resource = 'TileEditor/*.xib'

    s.dependency 'XCGLogger'
end
