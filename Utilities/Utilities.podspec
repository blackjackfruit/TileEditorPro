Pod::Spec.new do |s|
    s.name = 'Utilities'
    s.version = '0.1.0'
    s.license = ''
    s.homepage = 'http://www.yellokrow.com'
    s.authors = 'yellokrow'
    s.summary = 'Utitlies framework that are common to all yellokrow frameworks'
    s.source  = { :path => 'Utilities/*.swift' }
    s.source_files = 'Utilities/*.swift'
    s.osx.deployment_target = '10.12'

    s.dependency 'XCGLogger'
end
