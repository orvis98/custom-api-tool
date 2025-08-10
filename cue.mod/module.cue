module: "github.com/orvis98/custom-api-tool"
language: {
	version: "v0.14.0"
}
source: {
	kind: "git"
}
deps: {
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.5.0"
		default: true
	}
}
