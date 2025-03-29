package v1alpha1

#APIVersion: {
	// The deprecated field specifies that this version is deprecated and should
	// not be used.
	deprecated: bool | *false
	// Referenceable specifies that this version may be referenced by a
	// Composition in order to configure which resources an XR may be composed of.
	referenceable: bool | *true
	// Served specifies that this version should be served via REST APIs.
	served: bool | *true
	// Spec describes the schema used for validation, pruning, and defaulting of
	// this version of the defined composite resource.
	spec: {...}
	// reference to an Composition
	composition: #Composition
	// show inputs and outputs for the composition in the pod log in pretty format
	debug: bool | *false
}
