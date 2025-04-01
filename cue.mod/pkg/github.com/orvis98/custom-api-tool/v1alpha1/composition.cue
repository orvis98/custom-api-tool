package v1alpha1

// Composition describes the composition pipeline step.
#Composition: {
	// The request observes the composite.
	#request: {
		observed: {
			composite: resource: {
				apiVersion?: string
				kind?:       string
				metadata: {...}
				spec: {...}
				status: {...}
			}
			resources: {...}
		}
	}

	// Reference to the composite resource in the request.
	composite: #request.observed.composite.resource

	// Reference to the composite resource in the request.
	resources: #request.observed.resources

	// The objects to create as part of the function.
	objects: [string]: {
		#composite: {
			apiVersion: string | *"kubernetes.crossplane.io/v1alpha2"
			kind:       string | *"Object"
			metadata: name: string
		}
		metadata: {
			// If claims are enabled set name from Claim.
			if composite.spec.claimRef != _|_ {
				name: composite.spec.claimRef.name
			}

			// Otherwise use value in object.
			if composite.spec.claimRef == _|_ {
				name: string
			}

			// If claims are enabled set namespace from Claim.
			if composite.spec.claimRef != _|_ {
				namespace: composite.spec.claimRef.namespace
			}

			// Otherwise use value in object.
			if composite.spec.claimRef == _|_ {
				namespace: string | *"default"
			}
			...
		}
		...
	}

	// Transform the response.
	response: desired: {
		resources: {
			for k, v in objects {
				"\(k)": resource: {
					apiVersion: v.#composite.apiVersion
					kind:       v.#composite.kind
					metadata: name: string | *"\(composite.metadata.name)-\(k)"
					spec: forProvider: manifest: v
				}
			}
		}
		...
	}
}
