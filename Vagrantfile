Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"
#   config.ssh.private_key_path = '~/.ssh/id_rsa'
  config.ssh.insert_key = true
  config.vm.define :talkzzz_dashboard


  config.vm.provider "virtualbox" do |vbox|
    vbox.gui = false
    vbox.memory = "1024"
    #vbox.customize ["modifyvm", :id, "--memory", 1024]
  end

  config.vm.network :private_network, ip: "192.168.56.10"
  config.vm.network :forwarded_port, guest: 80, host: 8081
  config.vm.hostname = "talkzzz.me"

  unless Vagrant.has_plugin?("vagrant-hostsupdater")
    puts 'vagrant-hostsupdater is not installed!'
    puts 'To install the plugin, run:'
    puts 'vagrant plugin install vagrant-hostsupdater'
    exit
  end


  if Vagrant.has_plugin?("vagrant-hostsupdater")
    config.hostsupdater.aliases = ["talkzzz.me", "www.talkzzz.me", "talkzzz.net", "www.talkzzz.net"]
  end

  config.ssh.forward_agent = true

  config.vm.provision :ansible do |ansible|
    ansible.verbose="vv"
    ansible.limit = 'all'
    ansible.playbook = "ansible/vagrantplaybook.yml"
#     ansible.inventory_path = "ansible/inventory/apiship.dev"
    ansible.extra_vars = "ansible/vars/development.yml"
  end

  config.vm.synced_folder "./src", "/var/www/talkzzz.me", id: "talkzzz.me",
                          owner: "vagrant",
                          group: "www-data",
                          mount_options: ["dmode=775,fmode=644"]


end
