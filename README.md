# api-tool

A tool for writing Crossplane XRDs and Compositions in CUE.

## Usage

```bash
dagger -m github.com/orvis98/api-tool call gen-xrd --api-spec ./samples/webapp.cue > xrd.yaml
kubectl apply -f xrd.yaml
dagger -m github.com/orvis98/api-tool call gen-compositions --api-spec ./samples/webapp.cue > compositions.yaml
kubectl apply -f compositions.yaml --server-side
kubectl apply -f https://raw.githubusercontent.com/orvis98/api-tool/refs/heads/main/samples/webapp.yaml

kubectl get object
NAME                        KIND             PROVIDERCONFIG   SYNCED   READY   AGE
demo-2cjfb-deployment       Deployment       default          True     True    2s
demo-2cjfb-httproute        HTTPRoute        default          True     True    2s
demo-2cjfb-secret           Secret           default          True     True    2s
demo-2cjfb-securitypolicy   SecurityPolicy   default          True     True    2s
demo-2cjfb-service          Service          default          True     True    2s
```
