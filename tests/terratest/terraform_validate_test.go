package terratest

import (
	"testing"

	"github.com/dwizzle204/multi-region-gke/tests/terratest/internal/testenv"
	terraform "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformValidate(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testenv.TerraformRoot(),
		NoColor:      true,
	})

	terraform.InitAndValidate(t, terraformOptions)
}
