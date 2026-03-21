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

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.4"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }
}
