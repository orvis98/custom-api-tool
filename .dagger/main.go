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

// Generate and print an XRD from an API specification.
func (m *ApiTool) GenXRD(
	ctx context.Context,
	apiSpec *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	return m.Cue(source).
		WithFile("apispec.cue", apiSpec).
		WithExec([]string{"cue", "cmd", "xrd"}).
		Stdout(ctx)
}

// Generate and print Compositions from an API specification.
func (m *ApiTool) GenCompositions(
	ctx context.Context,
	apiSpec *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	return m.Cue(source).
		WithFile("apispec.cue", apiSpec).
		WithExec([]string{"cue", "cmd", "composition"}).
		Stdout(ctx)
}

// Generate and print XRD and Compositions from an API specification.
func (m *ApiTool) Gen(
	ctx context.Context,
	apiSpec *dagger.File,
	// +optional
	// +defaultPath="/"
	source *dagger.Directory,
) (string, error) {
	xrd, _ := m.GenXRD(ctx, apiSpec, source)
	compositions, _ := m.GenCompositions(ctx, apiSpec, source)
	return xrd + compositions, nil
}
