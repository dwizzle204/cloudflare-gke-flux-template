terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.17, < 8.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.17, < 8.0"
    }
  }
}

provider "google" {
  access_token = "mock-access-token"
  project      = "example-project-12345"
  region       = "us-central1"
}

provider "google-beta" {
  access_token = "mock-access-token"
  project      = "example-project-12345"
  region       = "us-central1"
}
