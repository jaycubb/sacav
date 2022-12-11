terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "web" {
  count = 1  # <-- specify 1 compute instance

  image  = "ubuntu-20-04-x64"  # <-- specify Ubuntu 20.04
  name   = "web-server-${count.index}"
  region = "sfo3"  # <-- specify region near Seattle
  size   = "s-1vcpu-1gb"  # <-- specify smallest possible size
  vpc_uuid = digitalocean_vpc.vpc.id

  user_data = <<-EOF
  #!/bin/bash
  git clone https://github.com/jaycubb/sacav.git
  cd sacav
  apt update
  apt install ansible -y
  ansible-playbook playbook.yml
  EOF

  monitoring = true  # <-- enable monitoring for the compute instance
}

resource "digitalocean_loadbalancer" "lb" {
  name       = "web-lb"
  region     = "sfo3"  # <-- specify region near Seattle
  droplet_ids = digitalocean_droplet.web.*.id
  vpc_uuid = digitalocean_vpc.vpc.id
  forwarding_rule {
    entry_port = 80
    entry_protocol = "tcp"
    target_port = 80
    target_protocol = "tcp"
  }
}

resource "digitalocean_vpc" "vpc" {
  name = "sacav-vpc"
  region = "sfo3"  # <-- specify region near Seattle
}


#resource "digitalocean_monitoring_alert_policy" "policy" {
#  name   = "web-alert-policy"
#  region = "sfo3"  # <-- specify region near Seattle
#
#  # create alerts for every possible metric
#  alert_rules = [
#    {
#      type = "metric"
#      name = "CPU usage"
#      value = "cpu"
#      period = "600"
#      threshold = "80"
#      operator = ">"
#    },
#    {
#      type = "metric"
#      name = "Disk I/O time"
#      value = "disk"
#      period = "600"
#      threshold = "1000"
#      operator = ">"
#    },
#    {
#      type = "metric"
#      name = "Memory usage"
#      value = "memory"
#      period = "600"
#      threshold = "80"
#      operator = ">"
#    },
#    {
#      type = "metric"
#      name = "Network in"
#      value = "net"
#      period = "600"
#      threshold = "10000000"
#      operator = ">"
#    },
#    {
#      type = "metric"
#      name = "Network out"
#      value = "net"
#      period = "600"
#      threshold = "10000000"
#      operator = "<"
#    },
#    {
#      type = "metric"
#      name = "Swap usage"

