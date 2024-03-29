# Website Dedicated (Ubuntu Precise 12.04 LTS x86)
# x86 Since VirtualBox does not support x64 with hardware acceleration)
# To get a x64, run a production server or enable VT-x for the CPU (BIOS Settings)
# Configure the nodes, default ram = 256
nodes = [
    { :config=> 'feedient.com', :hostname => 'local.feedient.com', :ip => '192.168.0.2', :box => 'precise-server-cloudimg-vagrant-i386', :url => 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box', :ram => 512 },
    { :config=> 'minefever.com', :hostname => 'local.minefever.com', :ip => '192.168.0.3', :box => 'precise-server-cloudimg-vagrant-i386', :url => 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box', :ram => 512 },
    { :config=> 'server.minefever.com', :hostname => 'server.minefever.com', :ip => '192.168.0.4', :box => 'precise-server-cloudimg-vagrant-i386', :url => 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-i386-disk1.box', :ram => 512 }
]

Vagrant.configure("2") do |config|
    nodes.each do |node|
        config.vm.define node[:hostname] do |node_config|
            # User setup since we use vagrant in production to?
            #node_config.ssh.username = "feedient"

            nfs_setting = RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/

            # IF NO NFS: node_config.vm.synced_folder "www", "/var/www", :owner => "www-data", :group => "www-data", :extra => 'dmode=755, fmode=664'
            node_config.vm.synced_folder "www", "/var/www", :nfs => true
            
            node_config.vm.box = node[:box]
            node_config.vm.box_url = node[:url]
            node_config.vm.hostname = node[:hostname]

            config.ssh.forward_agent = true
            node_config.vm.network :private_network, ip: node[:ip]
   
            # Virtualbox provider
            memory = node[:ram] ? node[:ram] : 256;
            node_config.vm.provider :virtualbox do |vb|
                vb.customize [
                    'modifyvm', :id, 
                    '--name', node[:hostname],
                    '--memory', memory.to_s
                ]
            end

            # Shell provisioner, we need puppet!
            node_config.vm.provision :shell, :inline => "sh /vagrant/install.sh #{node[:config]} /vagrant/"

            # We create a SSH key here so that we can login on the server
            # MAC Key Generate
            # Install curl-ca-bundle for the certificate: brew install curl-ca-bundle
            # Export SSL DIR: export SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt
            # node_config.ssh.private_key_path = "~/.ssh/id_rsa"

            # Digital Ocean provider
            #node_config.vm.provider :digital_ocean do |provider|
            #    provider.vm.box_url = node[:url];
            #    provider.ca_path = "/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt"
            #    provider.client_id = ""
            #    provider.api_key = ""
            #    provider.image = "Ubuntu 12.10 x64"
            #    provider.region = "Amsterdam 1"
            #    provider.size = "512MB"
            #end
        end
    end 
end