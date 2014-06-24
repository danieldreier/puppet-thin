require 'spec_helper_acceptance'

describe 'thin class' do
  context 'without parameters' do
    it 'should run with no errors' do
      pp = <<-EOS
      class { 'thin': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('thin') do
      it {
        should be_installed.by('gem')
      }
    end

    describe service('thin') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end

  context 'with sinatra hello world app' do
    it 'should run with no errors' do
      pp = <<-EOS
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
                          Class['thin'],
                          Package['sinatra']]
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('thin') do
      it {
        should be_installed.by('gem')
      }
    end

    describe service('thin-demo') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(3000) do
      it {
        should be_listening
      }
    end

  end
end
