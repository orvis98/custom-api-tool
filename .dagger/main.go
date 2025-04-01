package main

import (
	"context"
	"dagger/api-tool/internal/dagger"
)

type ApiTool struct{}

// A container with CUE and a source directory.
func (m *ApiTool) Cue(
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) *dagger.Container {
	return dag.Container().
		From("cuelang/cue:0.12.0").
		WithDirectory(".", source)
}

// Generate and print an XRD from a CustomAPI definition.
func (m *ApiTool) GenXRD(
	ctx context.Context,
	api *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	return m.Cue(source).
		WithFile("api.cue", api).
		WithExec([]string{"cue", "cmd", "xrd"}).
		Stdout(ctx)
}

// Generate and print Compositions from a CustomAPI definition.
func (m *ApiTool) GenCompositions(
	ctx context.Context,
	api *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	return m.Cue(source).
		WithFile("api.cue", api).
		WithExec([]string{"cue", "cmd", "composition"}).
		Stdout(ctx)
}

// Generate and print XRD and Compositions from a CustomAPI definition.
func (m *ApiTool) Gen(
	ctx context.Context,
	api *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	xrd, _ := m.GenXRD(ctx, api, source)
	compositions, _ := m.GenCompositions(ctx, api, source)
	return xrd + compositions, nil
}

// Test a CustomAPI using a manifest and print the result.
func (m *ApiTool) Test(
	ctx context.Context,
	manifest *dagger.File,
	api *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	return m.Cue(source).
		WithFile("test.yaml", manifest).
		WithFile("api.cue", api).
		WithExec([]string{"cue", "cmd", "test", "-t", "manifest=test.yaml", "-t", "api=api.cue"}).
		Stdout(ctx)
}
