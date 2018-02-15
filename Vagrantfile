Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 8192
    vb.cpus = 2
  end
  config.vm.network "forwarded_port", guest: 9130, host: 9130
  config.vm.network "forwarded_port", guest: 80, host: 3000
end
