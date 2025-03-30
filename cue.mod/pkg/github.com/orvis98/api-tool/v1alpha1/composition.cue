package v1alpha1

// Composition describes the composition pipeline step.
#Composition: {
	// The request observes the composite.
	#request: {
		observed: {
			composite: resource: {
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
					apiVersion: "kubernetes.crossplane.io/v1alpha2"
					kind:       "Object"
					metadata: name: "\(composite.metadata.name)-\(k)"
					spec: forProvider: manifest: v
				}
			}
		}
		...
	}
}
