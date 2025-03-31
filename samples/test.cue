package main

import (
	apitoolv1 "github.com/orvis98/api-tool/v1alpha1"
	"strings"
)

claim: {...}
composite: {...}
apitoolv1.#Test & {
	#apiSpec: #APISpec
	if #APISpec.claimNames != _|_ {
		#apiVersion: strings.TrimPrefix(claim.apiVersion, "\(#apiSpec.group)/")
	}
	if #APISpec.claimNames == _|_ {
		#apiVersion: strings.TrimPrefix(composite.apiVersion, "\(#apiSpec.group)/")
	}
	#claim:     claim
	#composite: composite
}
