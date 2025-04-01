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

// Print the XRD manifest generated from the CustomAPI definition to stdout.
command: xrd: {
	// Generate a Crossplane XRD from the API specification.
	_xrd: {
		apiVersion: "apiextensions.crossplane.io/v1"
		kind:       "CompositeResourceDefinition"
		metadata: name: #CustomAPI.name
		spec: {
			group: #CustomAPI.group
			names: {
				kind:   #CustomAPI.kind
				plural: #CustomAPI.plural
				// shortNames can be undefined, but cannot be an empty list
				if #CustomAPI.shortNames != [] {
					shortNames: #CustomAPI.shortNames
				}
				singular: #CustomAPI.singular
			}
			if #CustomAPI.claimNames != _|_ {
				claimNames: {
					kind:     #CustomAPI.claimNames.kind
					singular: #CustomAPI.claimNames.singular
					plural:   #CustomAPI.claimNames.plural
					// shortNames can be undefined, but cannot be an empty list
					if #CustomAPI.claimNames.shortNames != [] {
						shortNames: #CustomAPI.claimNames.shortNames
					}
				}
			}
			versions: [
				for k, v in #CustomAPI.versions {
					name:          k
					deprecated:    v.deprecated
					referenceable: v.referenceable
					served:        v.served
					_cmd: {
						"spec-\(k)": exec.Run & {
							cmd:     "cue def . -e #CustomAPI.versions.\(k).spec"
							stdout:  string
							_schema: "#spec\(strings.TrimPrefix(stdout, "\n_#def\n_#def"))"
						}
						"status-\(k)": exec.Run & {
							cmd:     "cue def . -e #CustomAPI.versions.\(k).status"
							stdout:  string
							_schema: "#status\(strings.TrimPrefix(stdout, "\n_#def\n_#def"))"
						}
						"eval-\(k)": exec.Run & {
							stdin:  _cmd["spec-\(k)"]._schema + _cmd["status-\(k)"]._schema
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

// Print the Composition manifest(s) generated from the CustomAPI definition to stdout.
command: composition: {
	for k, v in #CustomAPI.versions {
		"composition-\(k)": {
			apiVersion: "apiextensions.crossplane.io/v1"
			kind:       "Composition"
			metadata: name: "\(#CustomAPI.name)-\(k)"
			spec: {
				compositeTypeRef: {
					apiVersion: "\(#CustomAPI.group)/\(k)"
					kind:       #CustomAPI.kind
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
			cmd:    "cue def -e #CustomAPI.versions.\(k).composition --inline-imports"
			stdout: string
		}
		"print-\(k)": cli.Print & {
			text: "---\n\(yaml.Marshal(composition["composition-\(k)"]))"
		}
	}
}

// Print the result of testing a manifest against a CustomAPI definition using CUE.
command: test: {
	var: {
		// Path to a file containing the manifest to test.
		manifest: string @tag(manifest)
		// Path to the CustomAPI definition file.
		customAPI: *"api.cue" | string @tag(api)
		// Output format.
		out: *"yaml" | "json" | "cue"
	}
	if #CustomAPI.claimNames != _|_ {
		read: exec.Run & {
			cmd: "cue export \(var.manifest) -l \"claim\" samples/test.cue \(var.customAPI) -e result.response --out=\(var.out)"
		}
	}
	if #CustomAPI.claimNames == _|_ {
		read: exec.Run & {
			cmd: "cue export \(var.manifest) -l \"composite\" samples/test.cue \(var.customAPI) -e result.response --out=\(var.out)"
		}
	}
}
