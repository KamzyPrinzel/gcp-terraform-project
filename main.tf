terraform {
  required_version = ">= 1.0.0"

  backend "gcs" {
    bucket = "kcuf"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "random" {}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "tf_state" {
  name          = "tf-state-${var.project_id}-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true
  
  versioning {
    enabled = true
  }
}

resource "google_compute_network" "vpc" {
  name                    = "nice-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "nice-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "ssh" {
  name    = "nice-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm" {
  name         = "nice-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {}  # Assigns external IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}
