     class { 'thin': }

      package { 'sinatra':
        ensure   => 'installed',
        provider => 'gem',
      }
      file { '/opt/demoapp/config.ru':
        content => "require './demo' ; run Sinatra::Application",
        require => User['demoapp']
      }
      file { '/opt/demoapp/demo.rb':
        content => "require 'sinatra'",
        require => User['demoapp']
      }

      user { 'demoapp':
        ensure     => 'present',
        home       => '/opt/demoapp',
        managehome => true,
        shell      => '/bin/false',
      }

      thin::app { 'demo':
        user           => 'demoapp',
        group          => 'demoapp',
        rackup         => '/opt/demoapp/config.ru',
        chdir          => '/opt/demoapp',
        socket         => '/var/run/thin/demo.sock',
        require        => [File['/opt/demoapp/demo.rb'],
                          File['/opt/demoapp/config.ru'],
                          Class['thin'],
                          Package['sinatra'],
                          User['demoapp'],]
      }
