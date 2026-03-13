# sempods — Personal Data Pods for a Decentralized Web

Today, every app stores your data in its own silo. Your calendar lives in Google, your
tasks in Todoist, your notes in Notion — and none of them can talk to each other unless
someone builds an integration. When that integration breaks (and it does), your data is
stranded. sempods inverts this: instead of scattering data across apps, you have a
**pod** — a self-hosted data space where apps come to your data. What distinguishes
sempods is how access and interoperability work in practice — through a radically
simple permission model built on a single primitive.

A pod stores data as **structured, meaningful information** using W3C Semantic Web
standards. An event isn't a row in a database — it's a `schema:Event` with a name,
a date, and a location, described in a vocabulary (like schema.org, Dublin Core, or
FOAF) that any software can understand. This isn't a new format invented by sempods:
it uses RDF (the W3C standard for structured data), JSON-LD (RDF expressed as JSON),
and SPARQL (a query language for RDF). These are established, open standards — sempods
composes them into a practical system.

Because all data shares the same semantic foundation, **interoperability is not
engineered between apps — it emerges from the architecture.** Apps never interact with
each other — they only interact with data. An event created by one app is immediately
queryable by any other app or tool that understands the same vocabulary — without
adapters, without API mappings, without coordination.

Data is organized in **contexts** (named graphs) with a simple permission model:
read, write, manage — per context. Apps authenticate via OAuth 2.0 with DID-based
identity verification. Each app gets access to exactly its own context. The pod owner
controls who gets access to what. Every pod is an independent node publishing Linked
Open Data via HTTP URIs — each new deployment extends a decentralized knowledge graph
across the web.

### Working system

A working system exists with real users and real data:

- **Eventer** ([console.eventer.app](https://console.eventer.app)) — decentralized event platform with Linked Open Data
- **Focus** ([apps.sempods.org/focus](https://apps.sempods.org/focus)) — task management with natural language input
- **w2d2d** ([w2d2d.eventer.app](https://w2d2d.eventer.app)) — social coordination across independent pods

These apps were built independently — yet they interoperate because they share the same semantic foundation.

### Status

sempods is currently being open-sourced with support from [NLnet](https://nlnet.nl/) (NGI Zero Commons Fund, applied). The server, client SDK, documentation, and community infrastructure are being prepared for public release.

### License

Apache 2.0 (code) · CC BY 4.0 (documentation)
