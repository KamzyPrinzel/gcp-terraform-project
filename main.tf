terraform {
  required_version = ">= 1.0.0"
  
  backend "gcs" {
    bucket = "tf-state-bucket-${var.project_id}" # Will be created below
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create GCS bucket for Terraform state
resource "google_storage_bucket" "tf_state" {
  name          = "tf-state-bucket-${var.project_id}"
  location      = var.region
  force_destroy = true # Allows bucket to be deleted even if not empty

  versioning {
    enabled = true 
  }
}

# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Create a firewall rule to allow SSH
resource "google_compute_firewall" "ssh" {
  name    = "${var.project_id}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Warning: In production, restrict this to your IP
}

# Create a GCP instance
resource "google_compute_instance" "vm" {
  name         = "terraform-test"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link

    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  tags = ["ssh"]
}
