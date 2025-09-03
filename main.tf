terraform {
  required_version = ">= 1.6.0"

  backend "gcs" {
    bucket = "wf-terraform-state-wayfair-test-378605"  # replace with your bucket
    prefix = "vm-dev/state"                          # folder-style prefix
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "wayfair-test-378605"
  region  = "us-east1"
  zone    = "us-east1-d"
}

# Extra disk
resource "google_compute_disk" "extra_disk" {
  name  = "extra-disk"
  type  = "pd-standard"
  zone  = "us-east1-d"
  size  = 150   # GB
}

# VM without public IP
resource "google_compute_instance" "private_vm" {
  name         = "private-vm"
  machine_type = "e2-medium"
  zone         = "us-east1-d"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "wf-vpc-dev"   # existing VPC
    subnetwork = "wf-dsm-us-east1"
    # No access_config -> no public IP
  }

  attached_disk {
    source = google_compute_disk.extra_disk.id
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

 
}
