package terraformrun

import (
	"os/exec"
	"testing"

	"github.com/stretchr/testify/require"
)

func Run(t *testing.T, dir string, args ...string) string {
	t.Helper()

	cmd := exec.Command("terraform", args...)
	cmd.Dir = dir
	output, err := cmd.CombinedOutput()
	require.NoErrorf(t, err, "terraform %v failed:\n%s", args, string(output))

	return string(output)
}
