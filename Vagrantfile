VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :ubuntu_fuzzback do |ubuntu|
    ubuntu.vm.box = 'ubuntu/jammy64'
    ubuntu.vm.provision 'shell', path: 'tests/provision/tmux.sh'
    ubuntu.vm.provision 'shell', privileged: false, path: 'tests/provision/fzf.sh'
  end
end
