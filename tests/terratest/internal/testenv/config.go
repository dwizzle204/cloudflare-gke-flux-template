package testenv

import (
	"path/filepath"
	"runtime"
)

func RepoRoot() string {
	_, file, _, _ := runtime.Caller(0)
	return filepath.Clean(filepath.Join(filepath.Dir(file), "..", "..", "..", ".."))
}

func TerraformRoot() string {
	return filepath.Join(RepoRoot(), "terraform")
}

func TerraformCIRoot() string {
	return filepath.Join(TerraformRoot(), "ci")
}

func TestDataPath(name string) string {
	return filepath.Join(RepoRoot(), "tests", "terratest", "testdata", name)
}
