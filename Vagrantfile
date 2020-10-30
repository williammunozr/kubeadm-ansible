Vagrant.require_version ">= 1.7.0"

$os_image = (ENV['OS_IMAGE'] || "ubuntu18").to_sym

def set_vbox(vb, config)
  vb.gui = false
  vb.memory = 2048
  vb.cpus = 2

  case $os_image
  when :centos7
    config.vm.box = "bento/centos-7.2"
  when :ubuntu16
    config.vm.box = "bento/ubuntu-16.04"
  when :ubuntu18
    config.vm.box = "hashicorp/bionic64"
    config.vm.box_version = "1.0.282"
  end
end

Vagrant.configure("2") do |cf|
  # NFS Server
  cf.vm.provider "virtualbox"
  cf.ssh.shell = "bash -l"
  cf.vm.define "nfs-server" do |nfs|
    nfs.vm.hostname = "nfs-server"
    #nfs.vm.network :private_network, ip: "192.168.0.200", auto_config: true
    nfs.vm.network "public_network", :bridge => "en1: Wi-Fi (Airport)", :ip =>  "192.168.0.200"
    nfs.vm.provider "virtualbox" do |vb, override|
      vb.name = "k8s-nfs-server"
      set_vbox(vb, override)
    end
  end
  cf.vm.provision :shell, path: "./hack/bootstrap_nfs.sh"
end

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  master = 1
  node = 2

  config.ssh.shell = "bash -l"

  private_count = 201
  (1..(master + node)).each do |mid|
    name = (mid <= node) ? "n" : "m"
    id   = (mid <= node) ? mid : (mid - node)

    config.vm.define "k8s-#{name}#{id}" do |n|
      n.vm.hostname = "k8s-#{name}#{id}"
      ip_addr = "192.168.0.#{private_count}"
      #n.vm.network :private_network, ip: "#{ip_addr}",  auto_config: true
      n.vm.network "public_network", :bridge => "en1: Wi-Fi (Airport)", :ip =>  "#{ip_addr}"

      n.vm.provider :virtualbox do |vb, override|
        vb.name = "#{n.vm.hostname}"
        set_vbox(vb, override)
      end
      private_count += 1
    end
  end

  # Install of dependency packages using script
  config.vm.provision :shell, path: "./hack/setup-vms.sh"
end