# Digital Ocean Droplet
#

resource "digitalocean_droplet" "web" {
  image     = "ubuntu-18-04-x64"
  name      = "web-1"
  region    = "nyc1"
  size      = "s-1vcpu-1gb"
  user_data = "${file("userdata.yaml")}"
  ssh_keys  = ["${digitalocean_ssh_key.jean.fingerprint}"]
}
  # Not needed if using cloud-init
	# connection {
	# 	host = self.ipv4_address
	# 	user = "root"
	# 	type = "ssh"
	# 	file = ["${digitalocean_ssh_key.jean.fingerprint}"]
	# }
	
	# provisioner "remote-exec" {
	# 	inline = [
	# 		"export PATH=$PATH:/usr/bin",
	# 		# install dependencies
	# 		"sudo apt update -y"
	# 		"sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common unattended-upgrades"
	# 		# install docker
	# 		"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -"
	# 		"add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'"
	# 		"apt-get update -y"
	# 		"apt-get install -y docker-ce docker-ce-cli containerd.io"
	# 		"systemctl start docker"
	# 		"systemctl enable docker"

			
