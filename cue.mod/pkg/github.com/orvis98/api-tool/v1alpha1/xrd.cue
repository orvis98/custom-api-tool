package v1alpha1

#XRD: {
  #apiSpec: #apiSpec
	apiVersion: "apiextensions.crossplane.io/v1"
	kind:       "CompositeResourceDefinition"
  metadata: name: #apiSpec.name
	spec: {
		group: #apiSpec.group
		names: {
			kind:       #apiSpec.kind
			plural:     #apiSpec.plural
			// shortNames can be undefined, but cannot be an empty list
			if #apiSpec.shortNames != [] {
				shortNames: #apiSpec.shortNames
			}
			singular:   #apiSpec.singular
		}
		if #apiSpec.claimNames != _|_ {
			claimNames: {
				kind: #apiSpec.claimNames.kind
				singular: #apiSpec.claimNames.singular
				plural: #apiSpec.claimNames.plural
				// shortNames can be undefined, but cannot be an empty list
				if #apiSpec.claimNames.shortNames != [] {
					shortNames: #apiSpec.claimNames.shortNames
				}
			}
		}
		versions: [
			for k, v in #apiSpec.versions {
				name:          k
				deprecated:    v.deprecated
				referenceable: v.referenceable
				served:        v.served
				//_cmd: {
				//	"def-\(k)": exec.Run & {
				//		cmd:     "cue def . -e #apiSpec.versions.\(k).spec"
				//		stdout:  string
				//		_schema: "#spec\(strings.TrimPrefix(stdout, "\n_#def\n_#def"))"
				//	}
				//	"eval-\(k)": exec.Run & {
				//		stdin:  _cmd["def-\(k)"]._schema
				//		cmd:    "cue eval - --out=openapi+yaml"
				//		stdout: string
				//	}
				//}
				//schema: openAPIV3Schema: {
				//	type:       "object"
				//	properties: yaml.Unmarshal(_cmd["eval-\(k)"].stdout).components.schemas
				//}
			},
		]
  }
}

