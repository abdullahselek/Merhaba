Pod::Spec.new do |s|

    s.name                  = 'Merhaba'
    s.version               = '0.1'
    s.summary               = 'Discovery and connection between iOS & macOS devices'
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
    s.source_files          = 'Sources/*.{h,m}'
    s.requires_arc          = true

end