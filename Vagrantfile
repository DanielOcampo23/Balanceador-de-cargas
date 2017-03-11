VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  config.vm.define :centos_web do |web|
    web.vm.box = "Centos64Update"
    web.vm.network "private_network", ip: "192.168.33.55"
    web.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.57"
    web.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-web" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "web"
    end
  end

 config.vm.define :centos_web2 do |web2|
    web2.vm.box = "Centos64Update"
    web2.vm.network "private_network", ip: "192.168.33.56"
    web2.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.58"
    web2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-web2" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "web2"
    end
  end

  config.vm.define :centos_db do |db|
    db.vm.box = "Centos64Update"
    db.vm.network "private_network", ip: "192.168.33.57"
    db.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.59"
    db.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-db" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "db"
    end
  end


config.vm.define :centos_bc do |bc|
    bc.vm.box = "Centos64Update"
    bc.vm.network "private_network", ip: "192.168.33.58"
    bc.vm.network "public_network", bridge: "enp5s0", ip: "192.168.131.56"
    bc.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "centos-bc" ]
    end
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "bc"
    end
  end
end	
