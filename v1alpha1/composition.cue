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
	composite: #request.observed.composite.resource & {
		metadata: {...}
	}

	// The objects to create as part of the function.
	objects: [string]: {
		metadata: {
			name:      composite.metadata.name
			namespace: composite.metadata.namespace
			...
		}
		...
	}

	// Transform the response.
	response: desired: {
		resources: {
			for k, v in objects {
				"\(k)": resource: v
			}
		}
		...
	}
}
