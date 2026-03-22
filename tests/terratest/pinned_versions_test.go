package terratest

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/dwizzle204/multi-region-gke/tests/terratest/internal/testenv"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPinnedModuleAndProviderVersions(t *testing.T) {
	t.Parallel()

	rootMain := readFile(t, filepath.Join(testenv.TerraformRoot(), "main.tf"))
	networking := readFile(t, filepath.Join(testenv.TerraformRoot(), "networking.tf"))
	gke := readFile(t, filepath.Join(testenv.TerraformRoot(), "gke.tf"))
	flux := readFile(t, filepath.Join(testenv.TerraformRoot(), "flux.tf"))
	cloudflare := readFile(t, filepath.Join(testenv.TerraformRoot(), "cloudflare.tf"))
	certificates := readFile(t, filepath.Join(testenv.TerraformRoot(), "certificates.tf"))
	clusterA := readFile(t, filepath.Join(testenv.RepoRoot(), "gitops", "clusters", "cluster-a", "apps-sample.yaml"))
	clusterAFlux := readFile(t, filepath.Join(testenv.RepoRoot(), "gitops", "clusters", "cluster-a", "flux-system", "gotk-sync.yaml"))
	clusterBFlux := readFile(t, filepath.Join(testenv.RepoRoot(), "gitops", "clusters", "cluster-b", "flux-system", "gotk-sync.yaml"))
	gateway := readFile(t, filepath.Join(testenv.RepoRoot(), "gitops", "infrastructure", "gateway", "gateway.yaml"))
	versions := readFile(t, filepath.Join(testenv.TerraformRoot(), "versions.tf"))
	ciVersions := readFile(t, filepath.Join(testenv.TerraformCIRoot(), "versions.tf"))

	assert.Contains(t, rootMain, "version = \"18.2.0\"")
	assert.Contains(t, networking, "version = \"16.1.0\"")
	assert.Contains(t, networking, "version = \"8.3.0\"")
	assert.Contains(t, gke, "version = \"44.0.0\"")
	assert.Contains(t, gke, "regional = true")
	assert.Contains(t, versions, "version = \">= 7.17, < 8.0\"")
	assert.Contains(t, ciVersions, "version = \">= 7.17, < 8.0\"")
	assert.Contains(t, gke, "gateway_api_channel = \"CHANNEL_STANDARD\"")
	assert.Contains(t, gke, "fleet_project       = var.project_id")
	assert.Contains(t, cloudflare, "cloudflare_authenticated_origin_pulls_settings")
	assert.Contains(t, cloudflare, "cloudflare_zone_setting")
	assert.Contains(t, certificates, "google_certificate_manager_certificate")
	assert.Contains(t, certificates, "google_certificate_manager_certificate_map")
	assert.NotContains(t, versions, "source  = \"hashicorp/helm\"")
	assert.NotContains(t, flux, "FluxInstance")
	assert.NotContains(t, flux, "helm_release")
	assert.Contains(t, flux, "`flux bootstrap git`")
	assert.Contains(t, clusterAFlux, "ssh://git@github.com/REPLACE_ME/REPLACE_ME")
	assert.Contains(t, clusterAFlux, "branch: REPLACE_ME_GIT_BRANCH")
	assert.Contains(t, clusterBFlux, "ssh://git@github.com/REPLACE_ME/REPLACE_ME")
	assert.Contains(t, clusterBFlux, "branch: REPLACE_ME_GIT_BRANCH")
	assert.Contains(t, clusterA, "name: flux-system")
	assert.Contains(t, gateway, "networking.gke.io/certmap")
	assert.Contains(t, gateway, "protocol: HTTPS")
}

func readFile(t *testing.T, path string) string {
	t.Helper()

	data, err := os.ReadFile(path)
	require.NoError(t, err)

	return string(data)
}
