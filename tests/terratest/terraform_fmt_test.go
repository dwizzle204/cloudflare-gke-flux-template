package terratest

import (
	"testing"

	"github.com/dwizzle204/multi-region-gke/tests/terratest/internal/terraformrun"
	"github.com/dwizzle204/multi-region-gke/tests/terratest/internal/testenv"
)

func TestTerraformFmt(t *testing.T) {
	t.Parallel()

	terraformrun.Run(t, testenv.TerraformRoot(), "fmt", "-check", "-recursive")
}
