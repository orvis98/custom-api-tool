package main

import (
	apitoolv1 "github.com/orvis98/api-tool/v1alpha1"
	//appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	httproutev1 "gateway.networking.k8s.io/httproute/v1"
	securitypolicyv1 "gateway.envoyproxy.io/securitypolicy/v1alpha1"
)

// Specification for the WebApp custom Kubernetes API.
#APISpec: apitoolv1.#APISpec & {
	group: "example.com"
	kind:  "XWebApp"
	claimNames: kind: "WebApp"
	versions: {
		v1alpha1: {
			spec: {
				// Number of desired pods.
				replicas: int & >0 | *1
				// Container image name.
				image: string
				// Number of HTTP port to expose on the pod's IP address.
				containerPort: int & >0 & <65536 | *80
				// Environment variables to set in the container
				env?: [string]: string
				// BasicAuth defines the configuration for the HTTP Basic Authentication.
				basicAuth?: {
					// Username-password pairs in htpasswd format.
					users: string
				}
			}
			composition: #v1alpha1
		}
	}
}

// Composition function for API version `v1alpha1`.`
#v1alpha1: apitoolv1.#Composition & {
	composite: spec: #APISpec.versions.v1alpha1.spec
	objects: {
		deployment: { // appsv1.#Deployment & { (bug?)
			apiVersion: "apps/v1"
			kind:       "Deployment"
			spec: {
				selector: matchLabels: "kcp.io/name": composite.metadata.name
				replicas: composite.spec.replicas
				template: {
					metadata: labels: selector.matchLabels
					spec: containers: [{
						name:  "webapp"
						image: composite.spec.image
						ports: [{containerPort: composite.spec.containerPort}]
						if composite.spec.env != _|_ {
							env: [for k, v in composite.spec.env {name: k, value: v}]
						}
					}]
				}
			}
		}
		service: corev1.#Service & {
			apiVersion: "v1"
			kind:       "Service"
			spec: {
				selector: deployment.spec.selector.matchLabels
				ports: [{
					name:       "http"
					port:       80
					targetPort: composite.spec.containerPort
				}]
			}
		}
		httproute: httproutev1.#HTTPRoute & {
			spec: {
				parentRefs: [{
					name:        "webapps"
					namespace:   "default"
					sectionName: "http"
				}]
				hostnames: [composite.metadata.name]
				rules: [{
					backendRefs: [{
						group:  ""
						kind:   service.kind
						name:   service.metadata.name
						port:   80
						weight: 1
					}]
					matches: [{
						path: {
							type:  "PathPrefix"
							value: "/"
						}
					}]
				}]
			}
		}
		secret: corev1.#Secret & {
			apiVersion: "v1"
			kind:       "Secret"
			stringData: {
				if composite.spec.basicAuth != _|_ {
					".htpasswd": composite.spec.basicAuth.users
				}
			}
		}
		securitypolicy: securitypolicyv1.#SecurityPolicy & {
			spec: {
				targetRef: {
					group: "gateway.networking.k8s.io"
					kind:  objects.httproute.kind
					name:  composite.metadata.name
				}
				if composite.spec.basicAuth != _|_ {
					basicAuth: users: {
						group: ""
						kind:  objects.secret.kind
						name:  objects.secret.metadata.name
					}
				}
			}
		}
  }
}
