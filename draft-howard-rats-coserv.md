---
title: "Concise Selector for Endorsements and Reference Values"
abbrev: "CoSERV"
category: info

docname: draft-howard-rats-coserv-latest
submissiontype: IETF  # also: "independent", "editorial", "IAB", or "IRTF"
number:
date:
consensus: true
v: 3
area: "Security"
workgroup: "Remote ATtestation ProcedureS"
keyword:
 - RATS
 - attestation
 - endorsement
 - reference value
venue:
  group: "Remote ATtestation ProcedureS"
  type: "Working Group"
  mail: "rats@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/rats/"
  github: "rats-endorsements-distribution/draft-howard-rats-coserv"
  latest: "https://rats-endorsements-distribution.github.io/draft-howard-rats-coserv/draft-howard-rats-coserv.html"

author:
- ins: P. Howard
  name: Paul Howard
  organization: Arm
  email: paul.howard@arm.com
- ins: T. Fossati
  name: Thomas Fossati
  organization: Linaro
  email: Thomas.Fossati@linaro.org
- ins: H. Birkholz
  name: Henk Birkholz
  org: Fraunhofer SIT
  email: henk.birkholz@ietf.contact
- ins: S. Kamal
  name: Shefali Kamal
  org: Fujitsu
  email: Shefali.Kamal@fujitsu.com
- ins: G. Mandyam
  name: Giridhar Mandyam
  org: AMD
  email: gmandyam@amd.com

normative:
  RFC4648: base64
  RFC8610: cddl
  RFC8259: json
  STD96:
    -: cose
    =: RFC9052
  STD94:
    -: cbor
    =: RFC8949
  RFC9334: rats-arch
  I-D.ietf-rats-corim: rats-corim
  I-D.ietf-rats-msg-wrap: rats-cmw

informative:
  STD98: HTTP Caching
  RFC6024: TA requirements
  RFC7942: Improving Awareness of Running Code
  RFC7252: The Constrained Application Protocol (CoAP)
  I-D.ietf-rats-endorsements: rats-endorsements
  I-D.ietf-rats-eat: rats-eat

entity:
  SELF: "RFCthis"

--- abstract

In the Remote Attestation Procedures (RATS) architecture, Verifiers require Endorsements and Reference Values to assess the trustworthiness of Attesters.
This document specifies the Concise Selector for Endorsements and Reference Values (CoSERV), a structured query/result format designed to facilitate the discovery and retrieval of these artifacts from various providers.
CoSERV defines a query language and corresponding result structure using CDDL, which can be serialized in CBOR format, enabling efficient interoperability across diverse systems.

--- middle

# Introduction {#sec-intro}

Remote Attestation Procedures (RATS) enable Relying Parties to evaluate the trustworthiness of remote Attesters by appraising Evidence.
This appraisal necessitates access to Endorsements and Reference Values, which are often distributed across multiple providers, including hardware manufacturers, firmware developers, and software vendors.
The lack of standardized methods for querying and retrieving these artifacts poses challenges in achieving seamless interoperability.

The Concise Selector for Endorsements and Reference Values (CoSERV) addresses this challenge by defining a query language and a corresponding result structure for the transaction of artifacts between a provider and a consumer.
The query language format provides Verifiers with a standard way to specify the environment characteristics of Attesters, such that the relevant artifacts can be obtained from Endorsers and Reference Value Providers.
In turn, the result format allows those Endorsers and Reference Value Providers to package the artifacts within a standard structure.
This facilitates the efficient discovery and retrieval of relevant Endorsements and Reference Values from providers, maximising the re-use of common software tools and libraries within the transactions.

The CoSERV query language is intended to form the input data type for tools and services that provide access to Endorsements and Reference Values.
The CoSERV result set is intended to form the corresponding output data type from those tools and services.

Both the query language and the result set are designed for extensibility.
This addresses the need for a common baseline format to optimise for interoperability and software reuse, while maintaining the flexibility demanded by a dynamic and diverse ecosystem.

The environment characteristics of Endorsements and Reference Values are derived from the equivalent concepts in CoRIM {{-rats-corim}}.
CoSERV therefore borrows heavily from CoRIM, and shares some data types for its fields.
And, like CoRIM, the CoSERV schema is defined using CDDL {{-cddl}}. A CoSERV query can be serialized in CBOR {{-cbor}} format.

In addition to the CBOR-based data formats for CoSERV queries and responses, this specification also defines API bindings and behaviours for the exchange of CoSERV queries and responses.
This is to facilitate standard interactions between CoSERV producers and consumers.
Standard API endpoints and behaviours will encourage the growth of interoperable software tools and modules, not only for parsing and emitting CoSERV-compliant data, but also for implementing the clients and services that need to exchange such data when acting in the capacity of the relevant RATS roles.
This will be of greater benefit to the software ecosystem than the CoSERV data format alone.
See {{secapibindings}} for the API binding specifications.

## Terminology and Requirements Language

{::boilerplate bcp14-tagged}

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary, see {{Section 4 of -rats-arch}}.

This document uses terms and concepts defined by the CoRIM specification.
For a complete glossary, see {{Section 1.1.1 of -rats-corim}}.

This document uses the terms _"actual state"_ and _"reference state"_ as defined in {{Section 2 of -rats-endorsements}}.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}. Terms and concepts are always referenced as proper nouns, i.e., with Capital Letters.

# Aggregation and Trust Models {#secaggregation}

The roles of Endorser or Reference Value Provider might sometimes be fulfilled by aggregators, which collect from multiple supply chain sources, or even from other aggregators, in order to project a holistic view of the endorsed system.
The notion of such an aggregator is not explicit in the RATS architecture.
In practice, however, supply chains are complex and multi-layered.
Supply chain sources can include silicon manufacturers, device manufacturers, firmware houses, system integrators, service providers and more.
In practical terms, an Attester is likely to be a complex entity, formed of components from across such supply chains.
Evidence would be likewise structured, with contributions from different segments of the Attester's overall anatomy.
A Verifier for such Evidence may find it convenient to contact an aggregator as a single source of truth for Endorsements and Reference Values.
An aggregator would have intelligence about the Attester's complete anatomy and supply chain.
It would have the ability to contact all contributing supply chain actors for their individual Endorsements and Reference Values, before collecting them into a cohesive set, and delivering them to the Verifier as a single, ergonomic package.
In pure RATS terms, an aggregator is still an Endorser or a Reference Value Provider - or, more likely, both.
It is not a distinct role, and so there is no distinctly-modeled conveyance between an aggregator and a Verifier.
However, when consuming from an aggregator, the Verifier may need visibility of the aggregation process, possibly to the extent of needing to audit the results by inspecting the individual inputs that came from the original supply chain actors.
CoSERV addresses this need, catering equally for both aggregating and non-aggregating supply chain sources.

To support deployments with aggregators, CoSERV allows for flexible trust models as follows.

- **Shallow Trust**: in this model, the consumer trusts the aggregator, solely and completely, to provide authentic descriptions of the endorsed system.
The consumer does not need to audit the results of the aggregation process.
- **Deep Trust**: in this model, the consumer has a trust relationship with the aggregator, but does not deem this to be sufficient.
The consumer can still use the collected results from the aggregation process, where it is convenient to do so, but also needs to audit those results.

Any given CoSERV transaction can operate according to either model.
The consumer decides which model to use when it forms a query.
The CoSERV result payload can convey both the aggregated result and the audit trail as needed.
The payload size may be smaller when the shallow model is used, but the choice between the two models is a question for implementations and deployments.

Although CoSERV is designed to support aggregation, it is not a requirement.
When aggregation is not used, CoSERV still fulfills the need for a standard conveyance mechanism between Verifiers and Endorsers or Reference Value Providers.

# CoSERV Information Model {#secinfomodel}

## Overview

CoSERV is designed to facilitate query-response transactions between a producer and a consumer.
In the RATS model, the producer is either an Endorser or a Reference Value Provider, and the consumer is a Verifier.
CoSERV defines a single top-level data type that can be used for both queries and result sets.
Queries are authored by the consumer (Verifier), while result sets are authored by the producer (Endorser or Reference Value Provider) in response to the query.
A CoSERV data object always contains a query.
When CoSERV is used to express a result set, the query is retained alongside the result set that was yielded by that query.
This allows consumers to verify a match between the query that was sent to the producer, and the query that was subsequently returned with the result set.
Such verification is useful because it mitigates security threats arising from any untrusted infrastructure or intermediaries that might reside between the producer and the consumer.
An example of this is caching in HTTP {{STD98}} and CoAP {{RFC7252}}.
It might be expensive to compute the result set for a query, which would make caching desirable.
However, if caching is managed by an untrusted intermediary, then there is a risk that such an untrusted intermediary might return incorrect results, either accidentally or maliciously.
Pairing the original query with each result set provides an end-to-end contract between the consumer and producer, mitigating such risks.
The transactional pattern between the producer and the consumer would be that the consumer begins the transaction by authoring a query and sending it to the producer as a CoSERV object.
The producer receives the query, computes results, and returns a new CoSERV object formed from the results along with the original query.
Notionally, the producer is "adding" the results to the query before sending it back to the consumer.

## Artifacts {#secartifacts}

Artifacts are what the consumer (Verifier) needs in order to verify and appraise Evidence from the Attester, and therefore they form the bulk of the response payload in a CoSERV transaction.
The common CoSERV query language recognises three artifact types.
These correspond to the three categories of endorsement artifact that can be identified natively in the RATS architecture:

- **Trust Anchor**: A trust anchor is as defined in {{RFC6024}}.
An example of a trust anchor would be the public part of the asymmetric signing key that is used by the Attester to sign Evidence, such that the Verifier can verify the cryptographic signature.
- **Endorsed Value**: An endorsed value is as defined in {{Section 1.1.1 of -rats-corim}}.
This represents a characteristic of the Attester that is not directly presented in the Evidence, such as certification data related to a hardware or firmware module.
- **Reference Value**: A reference value is as defined in {{Section 1.1.1 of -rats-corim}}.
A reference value specifies an individual aspect of the Attester's desired state.
Reference values are sometimes informally called "golden values".
An example of a reference value would be the expected hash or checksum of a binary firmware or software image running in the Attester's environment.
Evidence from the Attester would then include claims about the Attester's actual state, which the Verifier can then compare with the reference values at Evidence appraisal time.

When artifacts are produced by an aggregator (see {{secaggregation}}), the following additional classifications apply:

- **Collected Artifacts**: these refer to artifacts that were derived by the aggregator by collecting and presenting data from original supply chain sources, or from other aggregators.
Collected artifacts form a single holistic package, and provide the most ergonomic consumption experience for the Verifier.
- **Source Arfifacts**: these refer to artifacts that were obtained directly from the original supply chain sources, and used as inputs into the aggregation process, allowing the aggregator to derive the collected artifacts.

In the shallow trust model of aggregation, only the collected artifacts are used by the consumer.
In the deep trust model, both the collected artifacts and the source artifacts are used.
The source artifacts allow the consumer to audit the collected artifacts and operate the trust-but-verify principle.

## Environments {#secenvironments}

The environment defines the scope (or scopes) in which the endorsement artifacts are applicable.
Given that the consumer of these artifacts is likely to be a Verifier in the RATS model, the typical interpretation of the environment would be that of an Attester that either has produced evidence, or is expected to produce evidence, that the Verifier needs to appraise.
The Verifier consequently needs to query the Endorser or Reference Value Provider for artifacts that are applicable in that environment.
There are three mutually-exclusive methods for defining the environment within a CoSERV query.
Exactly one of these three methods MUST be used for the query to be valid.
All three methods correspond to environments that are also defined within CoRIM {{-rats-corim}}.

- **Class**: A class is an environment that is expected to be common to a group of similarly-constructed Attesters, who might therefore share the same set of endorsed characteristics.
An example of this might be a fleet of computing devices of the same model and manufacturer.

- **Instance**: An instance is an environment that is unique to an individual and identifiable Attester, such as a single computing device or component.

- **Group**: A group is a collection of common Attester instances that are collected together based on some defined semantics.
For example, Attesters may be put into groups for the purpose of anonymity.

### Stateful Environments {#secstateful}

In addition to specifying the Attester environment by class, instance, or group, it is sometimes necessary to constrain the target environment further by specifying aspects of its state.
This is because the applicability of Endorsements and Reference Values might vary, depending on these stateful properties.
Consider, for example, an Attester instance who signs Evidence using a derived attestation key, where the derivation algorithm is dependent on one or more aspects of the Attester's current state, such as the version number of an upgradable firmware component.
This example Attester would, at different points in its lifecycle, sign Evidence with different attestation keys, since the keys would change upon any firmware update.
To provide the correct public key to use as the trust anchor for verification, the Endorser would need to know the configured state of the Attester at the time the Evidence was produced.
Specifying such an Attester solely by its instance identifier is therefore insufficient for the Endorser to supply the correct artifact.
The environment specification would need to include these critical stateful aspects as well.
In CoRIM {{-rats-corim}}, stateful environments are modeled as an environment identifier plus a collection of measurements, and CoSERV takes the same approach.
Therefore, any environment selector in a CoSERV query can optionally be enhanced with a collection of one or more measurements, which specify aspects of the target environment state that might materially impact the selection of artifacts.

## Queries

The purpose of a query is to allow the consumer (Verifier) to specify the artifacts that it needs.
The information that is conveyed in a CoSERV query includes the following:

- A specification of the required artifact type: Reference Value, Endorsed Value or Trust Anchor.
See {{secartifacts}} for definitions of artifact types.
A single CoSERV query can only specify a single artifact type.
- A specification of the Attester's environment.
Environments can be selected according to Attester instance, group or class.
Additional properties of the environment state can be specified by adding one or more measurements to the selector.
See {{secenvironments}} for full definitions.
To facilitate efficient transactions, a single query can specify either multiple instances, multiple groups or multiple classes.
However, it is not possible to mix instance-based selectors, group-based selectors and class-based selectors in a single query.
- A timestamp, denoting the time at which the CoSERV query was sent.
- A switch to select the desired supply chain depth.
A CoSERV query can request collected artifacts, source artifacts, or both.
This switch is especially relevant when the CoSERV query is fulfilled by an aggregator.
The collected artifacts are intended for convenient consumption (according to the shallow trust model), while the source artifacts are principally useful for auditing (according to the deep trust model).
It is possible for a query to select for source artifacts only, without the collected artifacts.
This might happen when the consumer needs to inspect or audit artifacts from across the deep supply chain, while not requiring the convenience of the aggregated view.
It could also happen when the consumer is acting as an intermediate broker, gathering artifacts for delivery to another aggregator.
See {{secaggregation}} for details on aggregation, auditing and trust models.

## Result Sets

The result set contains the artifacts that the producer collected in response to the query.
The top-level structure of the result set consists of the following three items:

- A collection of one or more result entries.
This will be a collection of either reference values, endorsed values or trust anchors.
See {{secartifacts}} for definitions of artifact types.
In the future, it may be possible to support additional artifact types via an extension mechanism.
Artifact types are never mixed in any single CoSERV result set.
The artifacts in the result collection therefore MUST match the single artifact type specified in the original CoSERV query.
- A timestamp indicating the expiry time of the entire result set.
Consumers MUST NOT consider any part of the result set to be valid after this expiry time.
- A collection of the original source materials from which the producer derived the correct artifacts to include in the result set.
These source materials are optional, and their intended purpose is auditing.
They are included only when requested by the original CoSERV query.
Source materials would typically be requested in cases where the consumer is not willing to place sole trust in the producer, and therefore needs an audit trail to enable additional verifications.

Each individual result entry combines a CoMID triple with an authority delegation chain.
CoMID triples are exactly as defined in {{Section 5.1.4 of -rats-corim}}.
Each CoMID triple will demonstrate the association between an environment matching that of the CoSERV query, and a single artifact such as a reference value, trust anchor or endorsed value.
The authority delegation chain is composed of one or more authority delegates.
Each authority delegate is represented by a public key or key identifier, which the consumer can check against its own set of trusted authorities.
The authority delegation chain serves to establish the provenance of the result entry, and enables the Verifier to evaluate the trustworthiness of the associated artifact.
The purpose of the authority delegation chain is to allow CoSERV responses to support decentralized trust models, where Verifiers may apply their own policy to determine which authorities are acceptable for different classes of artifact.

Because each result entry combines a CoMID triple with an authority delegation chain, the entries are consequently known as quadruples (or "quads" for short).

# CoSERV Data Model {#secdatamodel}

This section specifies the CBOR data model for CoSERV queries and result sets.

CDDL is used to express rules and constraints of the data model for CBOR.
These rules must be strictly followed when creating or validating CoSERV data objects.

The top-level CoSERV data structure is given by the following CDDL:

~~~cddl
{::include cddl/coserv.cddl}
~~~

## Common Data Types

CoSERV inherits the following types from the CoRIM data model `class-map`, `$class-id-type-choice`, `$instance-id-type-choice` and `$group-id-type-choice`.

The collated CDDL is in {{collated-cddl}}.

## Profile

In common with EAT and CoRIM, CoSERV supports the notion of profiles.
As with EAT and CoRIM, profiles are a way to extend or specialize the structure of a generic CoSERV query in order to cater for a specific use case or environment.

In a CoSERV query, the profile can be identified by either a Uniform Resource Identifier (URI) or an Object Identifier (OID).
This convention is identical to how EAT profiles are identified using the `eat_profile` claim as described in {{Section 4.3.2 of -rats-eat}}.

## Query Structure

The CoSERV query language enables Verifiers to specify the desired characteristics of Endorsements and Reference Values based on the environment in which they are applicable.

The top-level structure of a CoSERV query is given by the following CDDL:

~~~cddl
{::include cddl/query.cddl}
~~~

The meanings of these fields are detailed in the following subsections.

### Artifact Type

The `artifact-type` field is the foremost discriminator of the query.
It is a top-level category selector. Its three permissible values are `trust-anchors` (codepoint 1), `endorsed-values` (codepoint 0) and `reference-values` (codepoint 2).

See {{secartifacts}} for full definitions of artifact types.

It is expected that implementations might choose to store these different categories of artifacts in different top-level stores or database tables.
Where this is the case, the `artifact-type` field serves to narrow the query down to the correct store or table.
Even where this is not the case, the discriminator is useful as a filter for the consumer, resulting in an efficiency gain by avoiding the transfer of unwanted data items.

### Environment Selector

The environment selector forms the main body of the query, and its CDDL is given below:

~~~cddl
{::include cddl/environment-selector.cddl}
~~~

Environments can be specified according to instance, group or class. See {{secenvironments}} for details.

Although these three environment definitions are mutually-exclusive in a CoSERV query, all three support multiple entries.
This is to gain efficiency by allowing the consumer (Verifier) to query for multiple artifacts in a single transaction.
For example, where artifacts are being indexed by instance, it would be possible to specify an arbitrary number of instances in a single query, and therefore obtain the artifacts for all of them in a single transaction.
Likewise for classes and groups.
However, it would not be possible for a single query to specify more than one kind of environment.
For example, it would not be possible to query for both class-level and instance-level artifacts in a single CoSERV transaction.

All three environment selector types can optionally be enhanced with one or more `measurement-map` entries, which are used to express aspects of the environment state.
See {{secstateful}} for a description of stateful environments.

#### Selector Semantics

When multiple environment selectors are present in a single query, such as multiple instances or multiple groups, the implementation of the artifact producer MUST consider these to be alternatives, and hence use a logical `OR` operation when applying the query to its internal data stores.

Below is an illustrative example of how a CoSERV query for endorsed values, selecting for multiple Attester instances, might be transformed into a semantically-equivalent SQL database query:

~~~sql
SELECT *
  FROM endorsed_values
 WHERE ( instance-id = "At6tvu/erQ==" ) OR
       ( instance-id = "iZl4ZVY=" )`
~~~

The same applies for class-based selectors; however, since class selectors are themselves composed of multiple inner fields, the implementation of the artifact producer MUST use a logical `AND` operation in consideration of the inner fields for each class.

Also, for class-based selectors, any unset fields in the class are assumed to be wildcard (`*`), and therefore match any value.

Below is an illustrative example of how a CoSERV query for reference values, selecting for multiple Attester classes, might be transformed into a semantically-equivalent SQL database query:

~~~sql
SELECT *
  FROM reference_values
 WHERE ( class-id = "iZl4ZVY=" AND class-vendor = "ACME Inc." ) OR
       ( class-id = "31fb5abf-023e-4992-aa4e-95f9c1503bfa" )
~~~

### Timestamp

The `timestamp` field records the date and time at which the query was made, formatted according to {{Section 3.4.1 of -cbor}}.
Implementations SHOULD populate this field with the current date and time when forming a CoSERV query.

### Result Type

The `result-type` field selects for either `collected-artifacts` (codepoint 0), `source-artifacts` (codepoint 1) or `both` (codepoint 2).
See {{secaggregation}} for definitions of source and collected artifacts.

## Result Set Structure

The result set structure is given by the following CDDL:

~~~cddl
{::include cddl/result-set.cddl}
~~~

## Encoding Requirements {#secencoding}

Implementations may wish to use serialized CoSERV queries as canonical identifiers for artifact collections.
For example, a Reference Value Provider service may wish the cache the results of a CoSERV query to gain efficiency when responding to a future identical query.
For these use cases to be effective, it is essential that any given CoSERV query is always serialized to the same fixed sequence of CBOR bytes.
Therefore, CoSERV queries MUST always use CBOR deterministic encoding as specified in {{Section 4.2 of -cbor}}.
Further, CoSERV queries MUST use CBOR definite-length encoding.

## Cryptographic Binding Between Query and Result Set {#signed-coserv}

CoSERV is designed to ensure that any result set passed from a producer to a consumer is precisely the result set that corresponds to the consumer's original query.
This is the reason why the original query is always included along with the result set in the data model.
However, this measure is only sufficient in cases where the conveyance protocol guarantees that CoSERV result sets are always transacted over a secure channel without any untrusted intermediaries.
Wherever this is not the case, producers MUST create an additional cryptographic binding between the query and the result.
This is achieved by transacting the result set within a cryptographic envelope, with a signature added by the producer, which is verified by the consumer.
A CoSERV data object can be signed using COSE {{-cose}}.
A `signed-coserv` is a `COSE_Sign1` with the following layout:

~~~ cddl
{::include cddl/signed-coserv.cddl}
~~~

The payload MUST be the CBOR-encoded CoSERV.

~~~ cddl
{::include cddl/signed-coserv-headers.cddl}
~~~

The protected header MUST include the signature algorithm identifier.
The protected header MUST include either the content type `application/coserv+cbor` or the CoAP Content-Format TBD1.
Other header parameters MAY be added to the header buckets, for example a `kid` that identifies the signing key.

# Examples

## Query Data Examples

This section provides some illustrative examples of valid CoSERV query objects.

The following example shows a query for Reference Values scoped by a single class.
The `artifact-type` is set to 2 (`reference-values`), indicating a query for Reference Values.
The `profile` is given the example value of `tag:example.com,2025:cc-platform#1.0.0`.
Finally, the `environment-selector` uses the key 0 to select for class, and the value contains a single entry with illustrative settings for the identifier, vendor and model.

~~~edn
{::include-fold cddl/examples/rv-class-simple.diag}
~~~

The next example is similar, but adds a second entry to the set of classes in the `environment-map`, showing how multiple classes can be queried at the same time.

~~~edn
{::include-fold cddl/examples/rv-class-two-entries.diag}
~~~

The following example shows a query for Reference Values scoped by instance.
Again, the `artifact-type` is set to 2, and `profile` is given a demonstration value. The `environment-selector` now uses the key 1 to select for instances, and the value contains two entries with example instance identifiers.

~~~edn
{::include-fold cddl/examples/rv-instance-two-entries.diag}
~~~

## Result Data Examples

This section provides some illustrative examples of valid CoSERV queries with their corresponding result sets.

In this next example, the query is a reference value query based on class.

The top-level structure is a map with three entries: `profile` (codepoint 0), `query` (codepoint 1) and `results` (codepoint 2).

The profile and query structures are the same as in the previous examples.
The result structure is a map with two entries: `expiry` (codepoint 10) and `rvq` (codepoint 0).
The `rvq` (reference value quad) entry comprises the asserting authority and the asserted triples.
A single reference-value triple is shown in this example.
Its `environment-map`, as expected, is the same as the `environment-map` that was supplied in the query.
The rest of the structure is the `measurement-map` as defined in CoRIM {{-rats-corim}}.

~~~edn
{::include-fold cddl/examples/rv-results.diag}
~~~

The following example is for a query that requested the results be provided in the "source artifacts" format.
This means one or more original signed manifests containing information that satisfies the query criteria.

Compared with the previous example, the `rvq` entry is empty, while the `source-artifacts` (codepoint 11) contain two CMW records {{-rats-cmw}}, each of which contains a (made up) manifest with the type "application/vnd.example.refvals".

~~~edn
{::include-fold cddl/examples/rv-class-simple-results-source-artifacts.diag}
~~~

# API Bindings {#secapibindings}

This section sets out the ways in which CoSERV queries and responses can be exchanged between software components and services using APIs.
The CoSERV data format itself is agnostic of any particular API model or transport.
The API bindings provided here are intended to complement the data format.
They will allow implementations to build the complete functionality of a CoSERV producer or consumer, in a way that is well-suited to any transport or interaction model that is needed.

It is intended that these API definitions carry minimal additional semantics, since these are largely the preserve of the CoSERV query language itself.
The API definitions are merely vehicles for the exchange of CoSERV queries and responses.
Their purpose is to facilitate standard interactions that make the most effective use of available transports and protocols.

The only API binding that is specified in this document is a request-response protocol that uses HTTP for transport.
This is a simple pattern, and likely to be a commonly occurring one for a variety of use cases.
Future specifications may define other API bindings.
Such future bindings may introduce further HTTP-based protocols.
Alternatively, they may define protocols for use with other transports, such as CoAP {{RFC7252}}.

## Request Response over HTTP {#secrrapi}

This section defines and mandates the API endpoint behaviours for CoSERV request-response transactions over HTTP.
Implementations MUST provide all parts of the API as specified in this section.
The API is a simple protocol for the execution of CoSERV queries.
It takes a single CoSERV query as input, and produces a corresponding single CoSERV result set as the output.
It is a RESTful API because the CoSERV query serves as a unique and stable identifier of the target resource, where that resource is the set of artifacts being selected for by the query.
The encoding rules for CoSERV are deterministic as set out in {{secencoding}}.
This means that any given CoSERV query will always encode to the same sequence of bytes.
The Base64Url encoding ({{Section 2 of !RFC7515}}) of the byte sequence becomes the rightmost path segment of the URI used to identify the target resource.
The HTTP `GET` verb is then used with this URI to execute the query.
Further details are provided in the subsections below.

Authentication is out of scope for this document.
Implementations MAY authenticate clients, for example for authorization or for preventing denial of service attacks.

### Discovery {#secrrapidisco}

* body text
* request and response example
* CDDL model for the discovery payload (+ media type)

### Execute Query {#secrrapiquery}

This endpoint executes a single CoSERV query and returns a CoSERV result set.

The HTTP method is `GET`.

The URL path is formed of the discovered `coserv` endpoint (as set out in {{secrrapidisco}}), followed by a path separator ('/'), followed by the CoSERV query to be executed, which is represented as a Base64Url encoding of the query's serialized CBOR byte sequence.

There are no additional URL query parameters.

Clients MUST set the HTTP `Accept` header to a suitably-profiled `application/coserv+cose` or `application/coserv+cbor` media type.

Endpoint implementations MUST respond with an HTTP status code and response body according to one of the subheadings below.

#### Responses

##### Successful Transaction (200)

This response indicates that the CoSERV query was executed successfully.

Example HTTP request:

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

GET /coserv/ogB4I3R... HTTP/1.1
Host: endorsements-distributor.example
Accept: application/coserv+cose; \
        profile="tag:vendor.com,2025:cc_platform#1.0.0"
~~~

Example HTTP response:

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

HTTP/1.1 200 OK
Content-Type: application/coserv+cose; \
              profile="tag:vendor.com,2025:cc_platform#1.0.0"

Body (in CBOR Extended Diagnostic Notation (EDN))

{::include-fold cddl/examples/signed-rv-class-simple-results.diag}
~~~

##### Failure to Validate Query (400)

This response indicates that the supplied query is badly formed.

Example HTTP request:

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

GET /coserv/badquery... HTTP/1.1
Host: endorsements-distributor.example
Accept: application/coserv+cose; \
        profile="tag:vendor.com,2025:cc_platform#1.0.0"
~~~

Example HTTP response:

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

HTTP/1.1 400 Bad Request
Content-Type: application/concise-problem-details+cbor

Body (in CBOR Extended Diagnostic Notation (EDN))

{
  / title /  -1: "Query validation failed",
  / detail / -2: "The query payload is not in CBOR format"
}
~~~

##### Failure to Negotiate Profile (406)

This response indicates that the client has specified a CoSERV profile that is not understood or serviceable by the receiving endpoint implementation.

Example HTTP request:

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

GET /coserv/ogB4I3R... HTTP/1.1
Host: endorsements-distributor.example
Accept: application/coserv+cose; \
        profile="tag:vendor.com,2025:cc_platform#2.0.0"
~~~

Example HTTP response:

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

HTTP/1.1 406 Not Acceptable
Content-Type: application/concise-problem-details+cbor

Body (in CBOR Extended Diagnostic Notation (EDN))

{
  / title /  -1: "Unsupported profile",
  / detail / -2: "Profile tag:vendor.com,2025:cc_platform#2.0.0 \
                  not supported",
}
~~~

#### Caching {#secrrapicaching}

* body text
* example request
* example response

~~~ http-message
# NOTE: '\' line wrapping per RFC 8792

GET coserv/ogB4I3RhZ... HTTP/1.1
Host: coserv.example
Accept: application/coserv+cbor; \
        profile="tag:example.com,2025:cc-platform#1.0.0"
Content-Type: application/coserv+cbor
~~~
{: #fig-rest-req title="Request CoSERV"}

# Implementation Status
[^rfced] please remove this section prior to publication.

This section records the status of known implementations of the protocol defined by this specification at the time of posting of this Internet-Draft, and is based on a proposal described in {{RFC7942}}.
The description of implementations in this section is intended to assist the IETF in its decision processes in progressing drafts to RFCs.
Please note that the listing of any individual implementation here does not imply endorsement by the IETF.
Furthermore, no effort has been spent to verify the information presented here that was supplied by IETF contributors.
This is not intended as, and must not be construed to be, a catalog of available implementations or their features.
Readers are advised to note that other implementations may exist.

According to {{RFC7942}}, "this will allow reviewers and working groups to assign due consideration to documents that have the benefit of running code, which may serve as evidence of valuable experimentation and feedback that have made the implemented protocols more mature.
It is up to the individual working groups to use this information as they see fit".

## Veraison
Responsible Organisation: Veraison (open source project within the Confidential Computing Consortium).

Location: https://github.com/veraison

Description: Veraison provides components that can be used to build a Verifier, and also exemplifies adjacent RATS roles such as the Relying Party.
There is an active effort to extend Veraison so that it can act in the capacity of an Endorser or Reference Value Provider, showing how CoSERV can be used as a query language for such services.
This includes library code to assist with the creation, parsing and manipulation of CoSERV queries.

Level of Maturity: This is a proof-of-concept prototype implementation.

License: Apache-2.0.

Coverage: This implementation covers all aspects of the CoSERV query language.

Contact: Thomas Fossati, Thomas.Fossati@linaro.org

# Security Considerations {#seccons}
The CoSERV data type serves an auxiliary function in the RATS architecture.
It does not directly convey Evidence, Endorsements, Reference Values, Policies or Attestation Results.
CoSERV exists only to facilitate the interactions between the Verifier and the Endorser or Reference Value Provider roles.
Consequently, there are fewer security considerations for CoSERV, particularly when compared with data objects such as EAT or CoRIM.

Certain security characteristics are desirable for interactions between the Verifier and the Endorser or Reference Value Provider.
However, these characteristics would be the province of the specific implementations of these roles, and of the transport protocols in between them.
They would not be the province of the CoSERV data object itself.
Examples of such desirable characteristics might be:

- The Endorser or Reference Value Provider is available to the Verifier when needed.
- The Verifier is authorised to query data from the Endorser or Reference Value Provider.
- Queries cannot be intercepted or undetectably modified by an entity that is interposed between the Verifier and the Endorser or Reference Value Provider.

## Forming Native Database Queries from CoSERV
Implementations should take care when transforming CoSERV queries into native query types that are compatible with their underlying storage technology (such as SQL queries).
There is a risk of injection attacks arising from poorly-formed or maliciously-formed CoSERV queries.
Implementations must ensure that suitable sanitization procedures are in place when performing such translations.

# Privacy Considerations
A CoSERV query can potentially contain privacy-sensitive information.
Specifically, the `environment-selector` field of the query may reference identifiable Attester instances in some cases.
This concern naturally also extends to the data objects that might be returned to the consumer in response to the query, although the specifications of such data objects are beyond the scope of this document.
Implementations should ensure that appropriate attention is paid to this.
Suitable mitigations include the following:

- The use of authenticated secure channels between the producers and the consumers of CoSERV queries and returned artifacts.
- Collating Attester instances into anonymity groups, and referencing the groups rather than the individual instances.

# IANA Considerations

[^rfced] replace "{{&SELF}}" with the RFC number assigned to this document.

## Media Types Registrations

IANA is requested to add the following media types to the "Media Types" registry {{!IANA.media-types}}.

| Name | Template | Reference |
|-----------------|-------------------------|-----------|
| `coserv+cbor` | `application/coserv+cbor` | {{secdatamodel}} of {{&SELF}} |
| `coserv+cose` | `application/coserv+cose` | {{signed-coserv}} of {{&SELF}} |
{: #tab-mc-regs title="CoSERV Media Types"}

### `application/coserv+cbor`

{:compact}
Type name:
: application

Subtype name:
: coserv+cbor

Required parameters:
: n/a

Optional parameters:
: "profile" (CoSERV profile in string format.  OIDs must use the dotted-decimal notation.)

Encoding considerations:
: binary (CBOR)

Security considerations:
: {{seccons}} of {{&SELF}}

Interoperability considerations:
: n/a

Published specification:
: {{&SELF}}

Applications that use this media type:
: Verifiers, Endorsers, Reference Value Providers

Fragment identifier considerations:
: The syntax and semantics of fragment identifiers are as specified for "application/cbor". (No fragment identification syntax is currently defined for "application/cbor".)

Person & email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration:
: no

### `application/coserv+cose`

{:compact}
Type name:
: `application`

Subtype name:
: `coserv+cose`

Required parameters:
: n/a (cose-type is explicitly not supported, as it is understood to be "cose-sign1")

Optional parameters:
: "profile" CoSERV profile in string format.
OIDs must use the dotted-decimal notation.
Note that the `cose-type` parameter is explicitly not supported, as it is understood to be `"cose-sign1"`.

Encoding considerations:
: binary

Security considerations:
: {{seccons}} of {{&SELF}}

Interoperability considerations:
: n/a

Published specification:
: {{&SELF}}

Applications that use this media type:
: Verifiers, Endorsers, Reference Value Providers

Fragment identifier considerations:
: n/a

Person and email address to contact for further information:
: RATS WG mailing list (rats@ietf.org)

Intended usage:
: COMMON

Restrictions on usage:
: none

Author/Change controller:
: IETF

Provisional registration?
: no

## CoAP Content-Formats

IANA is requested to register the following Content-Format IDs in the "CoAP Content-Formats" registry, within the "Constrained RESTful Environments (CoRE) Parameters" registry group {{!IANA.core-parameters}}:

| Content-Type | Content Coding | ID | Reference |
| application/coserv+cbor | - | TBD1 | {{secdatamodel}} of {{&SELF}} |
| application/coserv+cose | - | TBD2 | {{signed-coserv}} of {{&SELF}} |
{: align="left" title="New CoAP Content Formats"}

If possible, TBD1 and TBD2 should be assigned in the 256..9999 range.

--- back

# Collated CoSERV CDDL {#collated-cddl}

~~~
{::include-fold cddl/coserv.cddl}

{::include-fold cddl/environment-selector.cddl}

{::include-fold cddl/comid-autogen.cddl}
~~~

# OpenAPI Schema
{: #openapi-schema}

The OpenAPI schema for the request/response HTTP API described in {{secrrapi}} is provided below.

~~~
{::include openapi/rr.yaml}
~~~

# Acknowledgments
{:numbered="false"}

The participants in the "Staircase meeting" at FOSDEM '25:

~~~
@@@@#=+++==+=+++++==+++++++++=========-========================-=======
@@@@@@@@#+*++++=+++****#########+====================================-=
*+@@@@@@%@%@%=***#*########%#####*++===============================-===
%%%%%@@%#@*@@@%%%%##%%%####%%###%#%++++=+=+================--==========
%%%%%%@@@%#%@%@@%###%#%#%%%#%%%#%%####===%%%+==================-=======
%%%%%%%@%%##%%%%%####%++=+=++++*%*=#+*++++++%#=== Mathias Brossard ====
%%%@%%%%%%%%%%%@%%####*##**#***+%%#**=*==*==*%================-========
%%%%%%@%%%%%%%%%#@###**+==%**%###%#+*+++=*+=*%=========================
%%%%%%%%%%%#%%%#*%###%###@#**%##%@#*%#++=+*#*=======================-==
@@@@@@@@%@@@#%#%%####%##%%%**###**%#+++++++++++======================--
%%@@@@@@@@%%#%%#%#==+%##%+%+=**##*%#%@@%%%***+==============-===-===-=:
%-*@%@%%%%#%%%##%==--#**##+*@@%%#*#@@@%%%%%%@%##%%==----======----=---:
%%%@@%#**%%%%%##%---#%@@%%%##**@@@%%%%%%%%@@#***%%=...-== Thomas ==-::+
=###%@@%%%%%%#*+===%#%%##%*#@@@@%%%%%%%%@@%%*+*+#=..:==== Fossati =-:**
+**+#%@@@@@@@@@@@@####*+++*@@@@@%%%@%%%%%#@%=+=--.:====================
+++**+%%@@@@@@%%%%%%%@@+#++#@@%@%%%@%%%%%@#+=-:.:==++++++++++++++++++++
+=++*#%#%@@%%%%%%#%**@+#+-+-%#%*%%%###%%%%#%%++++********++++++++++++++
++++**###=*@%%%%%%%++%*%+*==%##*#%+###@@@@%%%#===++++* Yogesh ++ ++++++
++=+++#**+=@*@@@@%#++#==+=+-%##**#*=+@@@@@%%#*----===+ Deshpande =+=+==
==+**+###++%++**@%*++#====+*##*****@%@#%%##%%*-==========+++++===+=++++
*+++++###++%=++*%#**+%===*++##***++@@%#%@%%%@%###-:::===++=---=-----:==
%++=-=%###+#====****=#===+=*=##*+%*@@%%%%%%@@%*=++#--===*==+=-+==+=-+++
%==----###=%===++*++=%*=+=***@#+***@%%*@%%%##%*##*%%@+=+==+++++++++++++
#*++----##=@*=+=**+*=*++#+=%%#*##%#*+@%@@%%%%%**%@%@@+#+**#*#####***#*+
+*+++@**+#%=%=+++++*=#++#%#+*****##*+@+++%%%%%#@@@@@@=-====-----+**++++
+*+*=%%#**#%=%@%=#++=%+***++*********%%%@%%#-==*+===++===++++++++++++++
#+**++%@%**#%@@%+#+*+%++=+=+*##*****%%%##%==-==**-+====-----:---::::--=
%%***+#%@%**%%=#*#+++%=====+*****#*+*@@+====-==%#*+-.-..-==:==.-.:::...
##**++=@%%#*#%%++#**=%-====+%%+###+++%#=====-+=%%##**+------===::=---::
#***++=+%%%#*%%==#+-+---==+*%%#@@%%++##=====-==%%%%=*++== Paul =:---===
##***+===%%@##@#%#*#=----===+++=+##*+##=====-==%%%%=*=-.. Howard .:-===
##***++==%%%%+**#%%#++-#%====+++%*++==#=====-==%%%%%%+--.:.-::--+=--+=+
##***+=+=%@%%##%##+######=++*=%=---*=+*=====--+%%%%%%+#--:.:--+**#*####
****+++==+%%@@%%%#%*########-%%=-====+*=-===-=+%%%%%%+++++++++*********
*+****++=##%%@@@%%#%+###%###%#@#+=+++==--===-=+%%%%%#+=+++--..====----=
++**+=#++#%%@+#@@@#%%####*#*##@*##%#*++=======+------++=++=--.-----=---
*%++*=+*+%#@#*@*%%#%%*###%#####+##%%=--+======+==:---+=--- Thore -===--
*++##**%=:==-#*+%#%=-=%%#%#%#%%##%*-=====-=--====--*-+-=== Sommer --=-=
-++*=%%*=%++-:#+=:*:####%#%%#%%**++=-==+---*-=*==--**+-===============+
-%#=%%%%%%@%%*%%##*%%%%%%%%%*@#%#++==---------=*+###++========+++++++++
-%@=*%%@%#%%@#@%%%%%%#@++++++@%%@#%%%%%%%---=====++++++++++++++++++++++
-%@=++*#@%#%*@++*#%%%*%*#*##@%+:%##+@@%%#%%#==========+++++++++++++++++
=%%=*==+%###+@%@%%@@%%%%####****+%#%%%%@%*###=:-========++++++++=++++++
==@==-+*##**+#%%%%#%##**###******++*%#%%##%*%#--===========++++++++++++
=-%=+*+-%#**-%@%%%@##**#*******+***%%%%##*%%%%-==++##===== Hannes +++++
+=@+*++++%**=%*+++%##+=@%%@%@@%*@%%%%%%+###+*==+=---%#==== Tschofenig +
+=@=++++*%**+%@+*=%###=-=-=-###%%@%%%#%*%#%%+==--+==%#====+=+++++++++++
*=%%==*+*#**=%@+#@@#==+=%*-----=%%#%%%%##%#%%%@=-+*%*++++++++++++++++++
#*@#+*+++#**=*=++-=+=+*#%%%%%%=-+%%%@@@%##%%%@#=+=+++++++++++++++++++++
****:::::-:::.=*++.=+**#######%%####%####*%%#%%%+++++++++++++++++++++++
*****:-::---==%+++=###+%********%%####%####@%##%%+++++++++++***********
#***##+++%#*++%++=+##*=%++#@@@@@%%%#%#####*%%##%%@*+++++++*************
#####+++*@%#+*@++*+%##+%++===+++++++++==========-=***+*****************
%%%#+***++@%@*@++*%%%%*#+===========================%%+================
%===++*++#***#@**%%%#%#+==========================%%%==================
######*****###*##*##===========================%%%#====================
#######****##*#*##**=====+++=++-----=======++%%#+======================
#########**#***##*#*#=+=======-:::::--====@%##-========================
######*=####**=#####*++++++++=-------+++@%##--=============------------
%%######@@@@@@@%++++=%====%+==----=++%%%#==---=========================
%%%%#%%###@@=**=++=------==#----+++%%%#+====-======================+===
======+##=%@++**=#-:--::---+-+++%%%#===== Ionut Mihalcea ==============
---------=+=*++%#*+=-=::---*++%%%#==================================+==
------------==%==-:::=*=*##%%%%#======*================================
===========-=##------+%%@%%%#+====================== =  /` _____ `\;,
###############*+*****@%%%#+========================   /__(^===^)__\';,
*############++++++#%%%#++==========++==============     /  :::  \   ,;
+++****##*#++=+++@%%%#+==== The Staircase ==========    |   :::   | ,;'
++++++++======++@#%#================================    '._______.'`
++++++++====++@#%#===================================  Dionna Glaze ===
~~~

Henk Birkholz and Jag Raman are puppeteering in the shadows.

[^rfced]: RFC Editor:
