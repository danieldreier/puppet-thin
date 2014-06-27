####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with thin](#setup)
    * [What thin affects](#what-thin-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with thin](#beginning-with-thin)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

This module manages the [Thin](http://code.macournoyer.com/thin/) ruby application server, and can create services to manage individual apps deployed with it. Only Debian 7 and Ubuntu 12.04 are currently supported.

##Module Description

This module can install thin for you, configure apps to run under thin, and either configure a service to run all thin apps you've configured, or configure services on a per-app basis. The module has no module dependencies, but currently only works on Debian 7 or Ubuntu 12.04. The codebase is a forked version of the camptocamp-thin module from https://github.com/camptocamp/puppet-thin, which is not published on the forge. If you need to run thin via puppet under CentOS, consider the evenup/thin module.

The forked version is written for the use case of running a puppetmaster under thin, via the ploperations/puppet module. It can also run rails or sinatra apps.

There are two options for running thin apps as services. By default, this module will create a service for each app, and that service will be enabled. Optionally, you can disable that behavior for each app, and set `manage_service => true` for the `thin` class. That will create a single service to manage all thin apps, but the init script for that service does not support status and results in execution for each puppet run, slightly breaking idempotency. The per-app services are the best option.

##Usage

You can install Thin as a web server in two ways, based on gem packages (default behavior) or with system packages:

    class {'thin': }

The definition thin::app offers an easy way to configure and start your Rails application:

    thin::app {'myapp':
      ensure  => present,
      address => 'localhost',
      port    => '3001',
      chdir   => '/opt/myapp',
      user    => 'myapp',
      group   => 'myapp',
      rackup  => '/opt/myapp/config.ru',
    }

To create a unix socket, which may be useful if you've got nginx in front of the app:

    thin::app { 'demo':
       user       => 'demoapp',
       group      => 'demoapp',
       rackup     => '/opt/demoapp/config.ru',
       chdir      => '/opt/demoapp',
       socket     => '/var/run/thin/demo.sock',
       force_home => '/opt/demoapp',
       require    => [File['/opt/demoapp/demo.rb'],
                     File['/opt/demoapp/config.ru'],
    }

Note that the user and group specified must already exist. These thin::app examples will result in the creation of a service named thin-myapp or thin-demo, respectively. This is the default behavior. If you'd rather have a single init script to start and stop all your thin apps at once, use something like the following:

    class {'thin':
      manage_service => true
    }

    thin::app {'myapp':
      ensure         => present,
      address        => 'localhost',
      port           => '3001',
      chdir          => '/opt/myapp',
      user           => 'myapp',
      group          => 'myapp',
      rackup         => '/opt/myapp/config.ru',
      manage_service => false,
    }

The thin service created for this does not currently show status, so the per-service option is the default and recommended approach.


##Reference

```
thin::app { 'appname':
  $chdir          => # directory thin will run from
  $user           => # user thin will run as
  $group          => # group thin will run as
  $rackup         => # location of config.ru file for thin
  $socket         => # (optional) unix socket path
  $force_home     => # (optional) $HOME environment to inject into service init script (required for puppetmaster)
  $ensure         => # present is the only valid option; absent does not work completely.
  $address        => # address to bind to
  $port           => # port to bind to
  $timeout        => # (optional) thin timeout in seconds
  $servers        => # (optional) number of thin instances to start
  $daemonize      => # (optional) defaults to true
  $manage_service => # (optional) create service for this app true|false
  $service        => # (optional) name of service to create if manage_service is enabled
}

All parameters for the thin class are optional.
class { 'thin':
  $config_dir         => # location thin app definitions will be stored
  $log_dir            => # thin log location
  $pid_dir            => # thin log location
  $package_type       => # gem or package
  $package_name       => # alternate package name for thin, normally used for system packages
  $service            => # service name for the monolithic thin service, if used
  $service_ensure     => # service state for monolithic thin service
  $manage_service     => # create a service to manage all thin apps (false by default)
  $service_enable     => # start thin service on boot
}
```

##Limitations

- Only Debian 7 and Ubuntu 12.04 running puppet 3.x are supported, largely because the init scripts don't work with CentOS.
- Thin will still listen on a port even if only unix sockets are requested
- Firewall ports aren't managed by this module
- Rubygems must be available; the module does not install it. On Ubuntu 12.04, rubygems must be installed before this module runs.
- If you run the thin service instead of app-specific services, it doesn't have status, so puppet will take action with each run.

##Development

This module uses beaker for testing. If you use bundler to install the gems, you can use rake to run tests as follows:
```bash
BEAKER_set=debian-73-x64 BEAKER_destroy=onpass bundle exec rake acceptance
```

If you'd like to make a pull request, please test your changes with beaker first. If you add significant functionality, consider adding beaker test coverage, or it may get broken later and nobody will notice. If you need a feature, feel free to file an issue on github at https://github.com/danieldreier/puppet-thin/issues.
