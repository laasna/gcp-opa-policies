# Sample GCP Infrastructure for OPA Policy Testing
# This demonstrates the infrastructure types mentioned in the task requirements

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Variables for testing different scenarios
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "laasna"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# VPC Network with different configurations
resource "google_compute_network" "vpc_network" {
  name                    = "${var.environment}-vpc-${random_id.suffix.hex}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Subnet with different configurations
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment}-subnet-${random_id.suffix.hex}"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
  
  # This will be validated by network policies
  private_ip_google_access = true
}

# Firewall rules with various network configurations
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh-${random_id.suffix.hex}"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # This will trigger policy violations if set to 0.0.0.0/0 in production
  source_ranges = var.environment == "prod" ? ["10.0.0.0/8"] : ["0.0.0.0/0"]
  target_tags   = ["ssh-server"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "${var.environment}-allow-http-${random_id.suffix.hex}"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# GCE instances with various network configurations (public IPs, firewall rules)
resource "google_compute_instance" "web_server" {
  name         = "${var.environment}-web-${random_id.suffix.hex}"
  machine_type = var.environment == "prod" ? "e2-standard-2" : "e2-micro"
  zone         = var.zone
  project      = var.project_id

  tags = ["web-server", "ssh-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
      type  = "pd-standard"
    }
    # Encryption settings will be validated by compute policies
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id

    # Conditional public IP - will trigger policy violations in production
    dynamic "access_config" {
      for_each = var.environment == "prod" ? [] : [1]
      content {
        // Ephemeral public IP
      }
    }
  }

  service_account {
    email  = google_service_account.compute_sa.email
    scopes = ["cloud-platform"]
  }

  labels = {
    environment = var.environment
    purpose     = "web-server"
  }
}

resource "google_compute_instance" "database_server" {
  name         = "${var.environment}-db-${random_id.suffix.hex}"
  machine_type = var.environment == "prod" ? "n2-standard-2" : "e2-small"
  zone         = var.zone
  project      = var.project_id

  tags = ["database-server", "ssh-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 50
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    # No public IP for database servers
  }

  service_account {
    email  = google_service_account.compute_sa.email
    scopes = ["cloud-platform"]
  }

  labels = {
    environment = var.environment
    purpose     = "database"
  }
}

# Cloud Storage buckets with different IAM bindings and encryption settings
resource "google_storage_bucket" "app_data" {
  name     = "${var.environment}-app-data-${random_id.suffix.hex}"
  location = "US"
  project  = var.project_id

  # These settings will be validated by storage policies
  public_access_prevention = "enforced"
  
  uniform_bucket_level_access {
    enabled = true
  }

  versioning {
    enabled = var.environment == "prod" ? true : false
  }

  labels = {
    environment = var.environment
    purpose     = "application-data"
  }
}

resource "google_storage_bucket" "backup_data" {
  name     = "${var.environment}-backup-${random_id.suffix.hex}"
  location = "US"
  project  = var.project_id

  public_access_prevention = "enforced"
  
  uniform_bucket_level_access {
    enabled = true
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    purpose     = "backup"
  }
}

# Service accounts with different permission levels
resource "google_service_account" "compute_sa" {
  account_id   = "${var.environment}-compute-sa-${random_id.suffix.hex}"
  display_name = "Compute Service Account"
  description  = "Service account for compute instances"
  project      = var.project_id
}

resource "google_service_account" "storage_sa" {
  account_id   = "${var.environment}-storage-sa-${random_id.suffix.hex}"
  display_name = "Storage Service Account"
  description  = "Service account for storage operations"
  project      = var.project_id
}

# IAM bindings that will be validated by IAM policies
resource "google_project_iam_binding" "compute_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin"

  members = [
    "serviceAccount:${google_service_account.compute_sa.email}",
  ]
}

resource "google_project_iam_binding" "storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.storage_sa.email}",
  ]
}

# VPC peering setup (for network policy testing)
resource "google_compute_network_peering" "peering" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "${var.environment}-peering-${random_id.suffix.hex}"
  network      = google_compute_network.vpc_network.id
  peer_network = google_compute_network.vpc_network.id
  project      = var.project_id
}

# Outputs for validation
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "web_server_internal_ip" {
  description = "Internal IP of the web server"
  value       = google_compute_instance.web_server.network_interface[0].network_ip
}

output "storage_bucket_names" {
  description = "Names of created storage buckets"
  value = [
    google_storage_bucket.app_data.name,
    google_storage_bucket.backup_data.name
  ]
}

output "service_account_emails" {
  description = "Email addresses of created service accounts"
  value = [
    google_service_account.compute_sa.email,
    google_service_account.storage_sa.email
  ]
}