# Installation
## Installation Steps
### Staging
#### Mac Prerequisites
* Virtualbox (Get the latest version here: https://www.virtualbox.org/wiki/Downloads)
* Vagrant (Get the latest version here: http://downloads.vagrantup.com/)
* Git
* XCode
* XCode Command-Line Tools

#### Installation
<ol>
	<li>Clone this repository using "git clone https://github.com/thebillkidy/ProjectFeeds-Vagrant.git"</li>
	<li>Open a terminal and navigate to the directory</li>
	<li>Enter "vagrant up <sitename>" (example: vagrant up local.feedient.com)</li>
	<li>Wait till it is completely done (Go grab some food or a drink :D)</li>
	<li>When it is done press "vagrant ssh <sitename>" (example: vagrant ssh local.feedient.com) to enter the terminal</li>
	<li>When on the box make sure to run sudo service nginx reload if you can not access the webserver</li>
	<li>Make sure to run post installation steps, example: symfony2 needs the composer to update the vendors, ...</li>
	<li>Have fun using Vagrant :D</li>
</ol>

### Production
#### Prerequisites
* Git (apt-get -y install git-core)

Full command to install everything:
```bash sudo apt-get install -y git-core```

#### Installation
<ol>
	<li>Login on your production server (ssh) and open a terminal</li>
	<li>Clone this repository using "git clone https://github.com/thebillkidy/ProjectFeeds-Vagrant.git"</li>
	<li>run ./install.sh <sitename>, this will check if chef is installed and will install if if needed, it will also run for your defined configuration. (example: ./install.sh feedient.com</li>
	<li>Wait till it is completely done (Go grab some food or a drink :D)</li>
	<li>When it is done run your post installation steps, example: symfony2 needs composer to update the vendors, ...</li>
	<li>Have fun using your new server</li>
</ol>

#### Used cookbooks from remote repositories:
<ol>
	<li>https://github.com/opscode-cookbooks/java (Stripped windows support)</li>
</ol>