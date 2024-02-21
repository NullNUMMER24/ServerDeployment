Vagrant.configure("2") do |config|
  config.vm.box = "generic/debian10"
  
  config.vm.provider "libvirt" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end
  
  config.vm.network "private_network", ip: "192.168.121.249"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y rsync
  SHELL
  
  config.vm.provision "file", source: "/home/jamie/git/ServerDeployment/start.sh", destination: "/home/vagrant/start.sh"
end

