package v1alpha1

// Test defines a test for an APISpec.
#Test: {
	#apiSpec:    #APISpec
	#apiVersion: string | *"v1alpha1"
	#claim: {
		spec: {
			claimRef: {...}
			...
		}
		...
	}
	#composite: {
		apiVersion: "\(#apiSpec.group)/\(#apiVersion)"
		kind:       #apiSpec.kind
		if #apiSpec.claimNames != _|_ {
			metadata: name: #claim.metadata.name
			spec: #claim.spec & {
				claimRef: {
					apiVersion: #composite.apiVersion
					kind:       #apiSpec.claimNames.kind
					name:       #claim.metadata.name
					namespace:  #claim.metadata.namespace
				}
			}
			...
		}
	}
	result: #apiSpec.versions[#apiVersion].composition & {
		composite: #composite
	}
}
