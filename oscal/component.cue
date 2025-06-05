package oscal

import (
	oscalv1 "github.com/orvis98/daggerverse/oscal/v1alpha1"
	"strings"
	"uuid"
)

oscalv1.#ComponentDefinition & {
	_uuid:  strings.ToLower("F2F30897-09F4-4F45-96EB-A4157BE9765A")
	"uuid": _uuid
	metadata: {
		title: "Custom API Tool"
		parties: [
			{
				"uuid": uuid.SHA1(_uuid, "github:"+name)
				type:   "person"
				name:   "orvis98"
				links: [{
					href: "https://github.com/orvis98"
					rel:  "website"
				}]
			},
		]
	}
	components: [
		{
			"uuid":      uuid.SHA1(_uuid, "github:cue-lang/cue")
			type:        "software"
			title:       "CUELang"
			description: "Validates and defines text-based and dynamic configurations."
			purpose:     "Provides configuration, unification and execution."
			"responsible-roles": [{
				"role-id": "provider"
				"party-uuids": [uuid.SHA1(_uuid, "github:cue-lang")]
			}]
		},
		{
			"uuid":      uuid.SHA1(_uuid, "github:crossplane/crossplane")
			type:        "software"
			title:       "Crossplane"
			description: "A cloud-native control plane."
			purpose:     "Control plane for realizing resources."
			"responsible-roles": [{
				"role-id": "provider"
				"party-uuids": [uuid.SHA1(_uuid, "github:crossplane")]
			}]
		},
		{
			"uuid":      uuid.SHA1(_uuid, "github:dagger/dagger")
			type:        "software"
			title:       "Dagger"
			description: "An open-source runtime for composable workflows."
			purpose:     "CI/CD."
			"responsible-roles": [{
				"role-id": "provider"
				"party-uuids": [uuid.SHA1(_uuid, "github:dagger")]
			}]
		},
	]
}
