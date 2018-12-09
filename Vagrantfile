# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = '1024'
  end
  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    curl -LSfs https://raw.githubusercontent.com/sasaplus1/dotfiles/master/Makefile | CI=true make setup -f -
  SHELL
end
