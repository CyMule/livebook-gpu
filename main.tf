resource "google_compute_network" "vpc_network" {
  // project project_id variable
  project                 = var.project_id
  name                    = "livebook-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  project       = var.project_id
  name          = "livebook-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "default" {
  project = var.project_id
  name    = "livebook-vm"
  machine_type = "n1-standard-4"
  zone         = var.zone
  tags         = ["ssh"]

  // set maintenance policy to TERMINATE. required for GPUS?
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
  }

  boot_disk {
    initialize_params {
      //image = "projects/ml-images/global/images/c0-deeplearning-common-cu113-v20221026-debian-10"
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230213"
    }
  }

  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }

  # Install Jupyterlab
  metadata_startup_script = <<EOT
    sudo apt-get update
    sudo apt-get install -yq erlang-inets erlang-os-mon erlang-runtime-tools erlang-ssl erlang-xmerl erlang-dev erlang-parsetools elixir make curl wget gnupg apt-transport-https
    # switch to ubuntu user
    sudo su - ubuntu
    curl -fsSL https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo gpg --dearmor -o /usr/share/keyrings/erlang.gpg
    echo "deb [signed-by=/usr/share/keyrings/erlang.gpg] https://packages.erlang-solutions.com/ubuntu $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/erlang.list
    sudo apt-get update
    sudo apt-get install -yq esl-erlang
    git clone https://github.com/elixir-lang/elixir.git
    cd elixir
    make clean test
    echo "export PATH=\$PATH:/home/ubuntu/elixir/bin" >> ~/.bashrc
    echo "export PATH=\$PATH:/home/ubuntu/elixir/bin" >> /home/ubuntu/.bashrc
    cd /home/ubuntu
    git clone https://github.com/livebook-dev/livebook.git
    cd livebook
    mix local.hex --force --only prod
    mix deps.get --force --only prod
    MIX_ENV=prod mix release
  EOT

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
  # add ssh key
  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key)}"
  }

}

resource "google_compute_firewall" "ssh" {
  project = var.project_id
  name    = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "allow-livebook" {
  project = var.project_id
  name    = "allow-colab"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# output "external_ip" {
#   value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
# }
# same as above but remove .pub from the end of the ssh key
output "connection_string" {
  value = "ssh -i ${replace(var.ssh_key, ".pub", "")} -L 8888:localhost:8080 ubuntu@${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}
