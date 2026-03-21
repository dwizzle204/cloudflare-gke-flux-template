package terratest

import (
	"testing"

	"github.com/dwizzle204/multi-region-gke/tests/terratest/internal/testenv"
	terraform "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformPlanContract(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: testenv.TerraformCIRoot(),
		VarFiles:     []string{testenv.TestDataPath("ci.auto.tfvars")},
		NoColor:      true,
		PlanFilePath: "tfplan",
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	counts := map[string]int{}
	for _, resource := range plan.ResourcePlannedValuesMap {
		counts[resource.Type]++
	}

	assert.Equal(t, 1, counts["google_compute_network"])
	assert.Equal(t, 2, counts["google_compute_subnetwork"])
	assert.Equal(t, 2, counts["google_compute_router"])
	assert.Equal(t, 2, counts["google_compute_router_nat"])
	assert.Equal(t, 1, counts["google_compute_global_address"])
	assert.Equal(t, 2, counts["google_container_cluster"])
	assert.Equal(t, 2, counts["google_container_node_pool"])
	assert.Equal(t, 2, counts["google_gke_hub_feature"])

	_, hasClusterA := plan.RawPlan.OutputChanges["cluster_a_name"]
	_, hasClusterB := plan.RawPlan.OutputChanges["cluster_b_name"]
	_, hasGatewayIP := plan.RawPlan.OutputChanges["gateway_static_ip"]
	assert.True(t, hasClusterA)
	assert.True(t, hasClusterB)
	assert.True(t, hasGatewayIP)

	assert.Zero(t, counts["flux_bootstrap_git"])
	assert.Zero(t, counts["cloudflare_dns_record"])
}
