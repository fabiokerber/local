# -*- mode: ruby -*-
# vi: set ft=ruby :

machines = {
  "srv01-lab" => {"memory" => "4096", "cpu" => "4", "image" => "centos/6"}
}

Vagrant.configure("2") do |config|

  config.vm.box_check_update = false
  config.vm.boot_timeout = 600
  machines.each do |name, conf|
    config.vm.define "#{name}" do |machine|
      machine.vm.box = "#{conf["image"]}"
      machine.vm.hostname = "#{name}"
      machine.vm.network "private_network", ip: "10.0.0.21" 
      machine.vm.network "private_network", ip: "10.0.0.41" 
      machine.vm.network "public_network", bridge: "enp1s0", auto_config: false 
      machine.vm.provider "virtualbox" do |vb|
        vb.name = "#{name}"
        vb.memory = conf["memory"]
        vb.cpus = conf["cpu"]
        vb.customize ["modifyvm", :id, "--groups", "/Samba"]
	vb.customize ["storageattach", :id,
                "--storagectl", "IDE",
                "--port", "0", "--device", "1",
                "--type", "dvddrive",
                "--medium", "/usr/share/virtualbox/VBoxGuestAdditions.iso"]
        
        file_to_disk = 'disk2.vdi'
        unless File.exist?(file_to_disk)
          # 5GB disk
          vb.customize ['storagectl', :id, '--name', 'SATA Controller', '--add', 'sata', '--controller', 'IntelAhci']
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 5 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]

        file_to_disk = 'disk3.vdi'
        unless File.exist?(file_to_disk)
          # 5GB disk
          vb.customize ['createhd', '--filename', file_to_disk, '--size', 5 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
 
    end
  end
 end
end
