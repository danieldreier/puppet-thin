# == Class: thin
#
# This class installs Thin
#
class thin (
  $config_dir         = '/etc/thin.d',
  $log_dir            = '/var/log/thin',
  $pid_dir            = '/var/run/thin',
  $package_type       = 'gem',
  $package_name       = 'thin',
  $service            = 'thin',
  $service_ensure     = 'running',
  $manage_service     = false,
  $service_enable     = true,
  $service_hasstatus  = false,
  $service_hasrestart = true,
  $service_pattern    = 'thin server'
) {

  case $package_type {
    'gem'    : {
      package {$package_name:
        ensure   => 'installed',
        provider => 'gem',
      }
    }
    'package': {
      package { $package_name:
        ensure   => 'installed',
      }
    }
    default  : { fail "Unsupported package type ${package_type}" }
  }

  file {[$config_dir, $log_dir]:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
  }

  file {$pid_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '1777',
  }

  if $manage_service == true {
    file {"/etc/init.d/${service}":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/thin/thin.init',
    }

    service {$service:
      ensure     => $service_ensure,
      enable     => $service_enable,
      hasstatus  => $service_hasstatus,
      hasrestart => $service_hasrestart,
      pattern    => $service_pattern,
      require    => [
        File[$config_dir,$log_dir,$pid_dir],
        File["/etc/init.d/${service}"], Package['thin'],
      ],
    }
  }

}
