resource "google_compute_network" "vpc_network" {
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
  project      = var.project_id
  name         = "livebook-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["ssh"]

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230213"
      size  = var.disk_size
    }
  }

  # Either RUNNING or TERMINATED
  desired_status = var.vm_state

  guest_accelerator {
    type  = var.gpu_type
    count = var.num_gpus
  }

  metadata_startup_script = file("start.sh")

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Needed to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("${var.ssh_key}.pub")}"
  }

}

resource "google_compute_firewall" "ssh" {
  project = var.project_id
  name    = "allow-ssh-livebook"
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

output "connection_string" {
  value = "ssh -i ${var.ssh_key} -L 8080:localhost:8080 -L 8081:localhost:8081 ubuntu@${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
}

