terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

# This is the provider used to spin up the gcloud instance
provider "google" {
  version = "~> 2.9.0"
  project = "project-id"
  region = "asia-east1"
  zone    = "asia-east1-a"
}

# This creates the google instance
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"

    # Associated our public IP address to this instance
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  # We connect to our instance via Terraform and remotely executes our script using SSH
#   provisioner "remote-exec" {

  connection {
    type        = "ssh"
    host        = google_compute_address.static.address
    user        = "user"
    private_key = file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
    "sudo apt-get update",
    "sudo apt-get install docker.io -y",
  ]   
  }
}

# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
}
