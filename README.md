# api-tool

A tool for writing Crossplane XRDs and Compositions in CUE.

## Usage

```bash
dagger -m github.com/orvis98/api-tool call gen-xrd --api-spec https://raw.githubusercontent.com/orvis98/api-tool/refs/heads/main/samples/webapp.cue > xrd.yaml
dagger -m github.com/orvis98/api-tool call gen-compositions --api-spec https://raw.githubusercontent.com/orvis98/api-tool/refs/heads/main/samples/webapp.cue > compositions.yaml
kubectl apply -f https://raw.githubusercontent.com/orvis98/api-tool/refs/heads/main/samples/webapp.yaml
```
