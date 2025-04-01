package v1alpha1

// Test defines a test for an CustomAPI definition.
#Test: {
	#customAPI:  #CustomAPI
	#apiVersion: string | *"v1alpha1"
	#claim: {
		spec: {
			claimRef: {...}
			...
		}
		...
	}
	#composite: {
		apiVersion: "\(#customAPI.group)/\(#apiVersion)"
		kind:       #customAPI.kind
		if #customAPI.claimNames != _|_ {
			metadata: name: #claim.metadata.name
			spec: #claim.spec & {
				claimRef: {
					apiVersion: #composite.apiVersion
					kind:       #customAPI.claimNames.kind
					name:       #claim.metadata.name
					namespace:  #claim.metadata.namespace
				}
			}
			...
		}
	}
	result: #customAPI.versions[#apiVersion].composition & {
		composite: #composite
	}
}
