# sempods — your data belongs to you

Every app wants to become the place where your data lives. Your calendar in one silo, your
tasks in another, your notes in a third — and nothing moves between them unless somebody
builds and maintains an integration. When it breaks, and it does, the data is stranded.

**sempods takes the opposite route.** The data goes in a pod you control. The apps come to
it. An event is not a row in one company's database — it is a thing on the web, with a URI,
described in vocabulary anyone already understands.

Interoperability then stops being something you engineer between apps. Two apps that have
never heard of each other work on the same data, because there is nothing between them to
integrate.

The stack is familiar on purpose. sempods does not invent a new graph database, query language or
auth world. It composes HTTP, RDF, JSON-LD, SPARQL, OAuth/OIDC and MCP into one pod contract:
resources have stable web addresses, every statement lives in a permissioned context, and apps,
websites and agents all meet the same server-enforced rules.

### It is running

A venue in Chemnitz publishes its events from its own pod. No account, no key, no mock:

```bash
curl -X POST https://sempods.org/aaltra/_system/sparql/query \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX schema: <https://schema.org/>
          SELECT ?e ?name ?start WHERE {
            ?e a schema:Event ; schema:name ?name ; schema:startDate ?start
          } ORDER BY ?start LIMIT 3'
```

Those are real events, served as Linked Open Data. Every one has its own URI — follow it and
you get the resource, not an API response shaped for one client.

### Start here

| | |
|---|---|
| **[www.sempods.org](https://www.sempods.org)** | what this is, and why — start here if you are new |
| **[spec.sempods.org](https://spec.sempods.org)** | the specification: what a pod must do — a core every pod implements, and modules it may |
| **[Try the API](https://spec.sempods.org/api/index.html)** | the HTTP surface, with a client you can send requests from |
| **[sempods-spec](https://github.com/sempods/sempods-spec)** | the specification's repository — the contract, not one implementation of it |
| **[sempods-kotlin](https://github.com/sempods/sempods-kotlin)** | the reference implementation for the JVM, [on Maven Central](https://central.sonatype.com/search?q=org.sempods) |
| **[schema.sempods.org](https://schema.sempods.org)** | the vocabulary — the few terms sempods adds to the ones that already exist |
| **[Discussions](https://github.com/sempods/sempods-kotlin/discussions)** | questions, ideas, and what is being decided |

### Status

`0.x`, one maintainer, and pods serving real data in production. The specification is
extracted from the reference implementation today; at the `0.1` tag that reverses and the
implementation follows the specification instead.

What does not exist yet: a conformance suite, so nobody can *prove* an implementation
conformant — including this one.

### License

Code is Apache 2.0. The specification, documentation and vocabulary are CC BY 4.0.

"sempods" is a trademark of Danilo Stein. The Apache License grants no trademark rights;
[TRADEMARKS.md](https://github.com/sempods/sempods-kotlin/blob/main/TRADEMARKS.md) says what
you may call your own work, and is deliberately permissive — the name is regulated only where
it would suggest origin or endorsement.
