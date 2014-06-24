class { 'thin': }

package { 'sinatra':
  ensure   => 'installed',
  provider => 'gem',
}
file { '/tmp/config.ru':
  content => "require './demo' ; run Sinatra::Application"
}
file { '/tmp/demo.rb':
  content => "require 'sinatra'"
}

thin::app { 'demo':
  user           => 'root',
  group          => 'root',
  rackup         => '/tmp/config.ru',
  chdir          => '/tmp',
  require        => [File['/tmp/demo.rb'],
                    File['/tmp/config.ru'],
                    Package['sinatra'],
                    Class['thin'],
                    ]
}

