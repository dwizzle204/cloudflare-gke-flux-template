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
	versions := readFile(t, filepath.Join(testenv.TerraformRoot(), "versions.tf"))
	ciVersions := readFile(t, filepath.Join(testenv.TerraformCIRoot(), "versions.tf"))

	assert.Contains(t, rootMain, "version = \"18.2.0\"")
	assert.Contains(t, networking, "version = \"16.1.0\"")
	assert.Contains(t, networking, "version = \"8.3.0\"")
	assert.Contains(t, gke, "version = \"44.0.0\"")
	assert.Contains(t, versions, "version = \">= 7.17, < 8.0\"")
	assert.Contains(t, ciVersions, "version = \">= 7.17, < 8.0\"")
	assert.Contains(t, gke, "gateway_api_channel = \"CHANNEL_STANDARD\"")
	assert.Contains(t, gke, "fleet_project       = var.project_id")
}

func readFile(t *testing.T, path string) string {
	t.Helper()

	data, err := os.ReadFile(path)
	require.NoError(t, err)

	return string(data)
}
