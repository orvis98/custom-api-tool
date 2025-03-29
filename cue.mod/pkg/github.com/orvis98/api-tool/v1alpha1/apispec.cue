package v1alpha1

import (
	"strings"
)

// An APISpec defines the schema for a new custom Kubernetes API.
#APISpec: {
	// group is the API group of the defined custom resource.
	group: string & =~#"^[a-z0-9]{1,62}(\.[a-z0-9]{1,63})+$"# & strings.MaxRunes(253)
	// kind is the serialized kind of the resource. It is normally CamelCase and singular.
	kind: string & =~#"^[A-Z][A-Za-z0-9]+$"# & strings.MaxRunes(63)
	// singular is the singular name of the resource.
	singular: string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63) | *strings.ToLower(kind)
	// plural is the plural name of the resource to serve.
	plural: string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63) | *"\(singular)s"
	// shortNames are short names for the resource, exposed in API discovery documents.
	shortNames: [...(string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63))]
	// the composite resource name.
	name: string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63) | *"\(plural).\(group)"
	// claimNames specifies the names of an optional composite resource claim.
	claimNames?: {
		// kind is the serialized kind of the resource. It is normally CamelCase and singular.
		kind: string & =~#"^[A-Z][A-Za-z0-9]+$"# & strings.MaxRunes(63)
		// singular is the singular name of the resource.
		singular: string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63) | *strings.ToLower(kind)
		// plural is the plural name of the resource to serve.
		plural: string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63) | *"\(singular)s"
		// shortNames are short names for the resource, exposed in API discovery documents.
		shortNames: [...(string & =~#"^[a-z][a-z0-9-]+$"# & strings.MaxRunes(63))]
	}
	// versions is the list of all API versions of the defined composite resource.
	versions: [string]: #APIVersion
}
