terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "crm-prod-terraform-state-bucket"
    prefix = "state/production"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Networking Module Call
module "networking" {
  source     = "../../modules/networking"
  project_id = var.project_id
  region     = var.region
}

# Secure GKE Cluster for CRM Workloads
module "gke" {
  source             = "../../modules/gke"
  project_id         = var.project_id
  region             = var.region
  vpc_name           = module.networking.vpc_name
  subnet_name        = module.networking.subnet_name
  min_node_count     = 2
  max_node_count     = 5
  machine_type       = "e2-standard-4"
}

# Artifact Registry for Docker Images
module "artifact_registry" {
  source      = "../../modules/artifact_registry"
  project_id  = var.project_id
  region      = var.region
  repository_id = "crm-features-repo"
}
