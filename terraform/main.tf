module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "18.2.0"

  project_id = var.project_id
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "trafficdirector.googleapis.com"
  ]

  disable_services_on_destroy = false
  disable_dependent_services  = false
}
