packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}


locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "vagrant" "image" {
  add_force    = true
  communicator = "ssh"
  provider     = "virtualbox"
  source_path  = "ubuntu/focal64"
}

build {
  sources = ["source.vagrant.image"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script = "script/install_nginx.sh"
  }


  provisioner "file" {
    sources = [
      "./key/id_rsa.pub",
    ]
    destination = "/home/vagrant/"
  }

  provisioner "file" {
    sources = [
      "./script/install_nginx.sh",
    ]
    destination = "/home/vagrant/"
  }

  provisioner "shell" {
    inline = [
      "sudo cat /home/vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys",
    ]
  }
 provisioner "shell" {
    inline = [
      "cd /home/vagrant/",
      "chmod +x install_nginx.sh",
    ]
  }

}