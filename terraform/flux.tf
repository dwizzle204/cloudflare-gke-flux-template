# Standard Flux bootstrap is intentionally not managed by Terraform in this template.
#
# After Terraform provisions infrastructure, bootstrap Flux on both clusters with:
# `flux bootstrap git`
#
# Cluster paths:
# - gitops/clusters/cluster-a
# - gitops/clusters/cluster-b
#
# Git authentication uses SSH deploy key authentication rather than HTTPS token auth.
