package main

import (
	"encoding/yaml"
	"strings"
	"tool/cli"
	"tool/exec"
)

// List available commands.
command: help: exec.Run & {
	cmd: "cue help cmd"
}

// Print the XRD manifest generated from the API specification to stdout.
command: xrd: {
	// Generate a Crossplane XRD from the API specification.
	_xrd: {
		apiVersion: "apiextensions.crossplane.io/v1"
		kind:       "CompositeResourceDefinition"
		metadata: name: #APISpec.name
		spec: {
			group: #APISpec.group
			names: {
				kind:   #APISpec.kind
				plural: #APISpec.plural
				// shortNames can be undefined, but cannot be an empty list
				if #APISpec.shortNames != [] {
					shortNames: #APISpec.shortNames
				}
				singular: #APISpec.singular
			}
			if #APISpec.claimNames != _|_ {
				claimNames: {
					kind:     #APISpec.claimNames.kind
					singular: #APISpec.claimNames.singular
					plural:   #APISpec.claimNames.plural
					// shortNames can be undefined, but cannot be an empty list
					if #APISpec.claimNames.shortNames != [] {
						shortNames: #APISpec.claimNames.shortNames
					}
				}
			}
			versions: [
				for k, v in #APISpec.versions {
					name:          k
					deprecated:    v.deprecated
					referenceable: v.referenceable
					served:        v.served
					_cmd: {
						"def-\(k)": exec.Run & {
							cmd:     "cue def . -e #APISpec.versions.\(k).spec"
							stdout:  string
							_schema: "#spec\(strings.TrimPrefix(stdout, "\n_#def\n_#def"))"
						}
						"eval-\(k)": exec.Run & {
							stdin:  _cmd["def-\(k)"]._schema
							cmd:    "cue eval - --out=openapi+yaml"
							stdout: string
						}
					}
					schema: openAPIV3Schema: {
						type:       "object"
						properties: yaml.Unmarshal(_cmd["eval-\(k)"].stdout).components.schemas
					}
				},
			]
		}
	}
	print: cli.Print & {
		text: "---\n\(yaml.Marshal(_xrd))"
	}
}

// Print the Composition manifest(s) generated from the API specification to stdout.
command: composition: {
	for k, v in #APISpec.versions {
		"composition-\(k)": {
			apiVersion: "apiextensions.crossplane.io/v1"
			kind:       "Composition"
			metadata: name: "\(#APISpec.name)-\(k)"
			spec: {
				compositeTypeRef: {
					apiVersion: "\(#APISpec.group)/\(k)"
					kind:       #APISpec.kind
				}
				mode: "Pipeline"
				pipeline: [{
					step: "compose-resource"
					functionRef: name: "function-cue"
					input: {
						apiVersion: "fn-cue/v1"                    // can be anything
						kind:       "CueFunctionParams"            // can be anything
						source:     "Inline"                       // only Inline is supported for now
						script:     composition["def-\(k)"].stdout // text of cue program
						debug:      v.debug                        // show inputs and outputs for the composition in the pod log in pretty format
					}
				}]
			}
		}
		"def-\(k)": exec.Run & {
			cmd:    "cue def -e #APISpec.versions.\(k).composition --inline-imports"
			stdout: string
		}
		"print-\(k)": cli.Print & {
			text: "---\n\(yaml.Marshal(composition["composition-\(k)"]))"
		}
	}
}
