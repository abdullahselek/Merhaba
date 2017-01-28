Pod::Spec.new do |s|

    s.name                  = 'Merhaba'
    s.version               = '1.2.0'
    s.summary               = 'Discovery and connection between iOS, macOS and tvOS devices'
    s.homepage              = 'https://github.com/abdullahselek/Merhaba'
    s.license               = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author                = {
        'Abdullah Selek' => 'abdullahselek@yahoo.com'
    }
    s.source                = {
        :git => 'https://github.com/abdullahselek/Merhaba.git',
        :tag => s.version.to_s
    }
    s.ios.deployment_target = '9.0'
    s.osx.deployment_target = '10.9'
    s.tvos.deployment_target = '9.0'
    s.source_files          = 'Sources/*.{h,m}'
    s.requires_arc          = true

end