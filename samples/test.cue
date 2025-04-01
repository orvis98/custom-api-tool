package main

import (
	apitoolv1 "github.com/orvis98/api-tool/v1alpha1"
	"strings"
)

claim: {...}
composite: {...}
apitoolv1.#Test & {
	#customAPI: #CustomAPI
	if #customAPI.claimNames != _|_ {
		#apiVersion: strings.TrimPrefix(claim.apiVersion, "\(#customAPI.group)/")
	}
	if #customAPI.claimNames == _|_ {
		#apiVersion: strings.TrimPrefix(composite.apiVersion, "\(#customAPI.group)/")
	}
	#claim:     claim
	#composite: composite
}
