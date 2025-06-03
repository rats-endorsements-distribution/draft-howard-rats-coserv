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

normative:
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
This document does not define the complete APIs or interaction models for such tools and services.
The scope of this document is limited to the definitions of the query language and the result set only.

Both the query language and the result set are designed for extensibility.
This addresses the need for a common baseline format to optimise for interoperability and software reuse, while maintaining the flexibility demanded by a dynamic and diverse ecosystem.

The environment characteristics of Endorsements and Reference Values are derived from the equivalent concepts in CoRIM {{-rats-corim}}.
CoSERV therefore borrows heavily from CoRIM, and shares some data types for its fields.
And, like CoRIM, the CoSERV schema is defined using CDDL {{-cddl}}. A CoSERV query can be serialized in CBOR {{-cbor}} format.

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

## Queries

The purpose of a query is to allow the consumer (Verifier) to specify the artifacts (Endorsements and Reference Values) that it needs.
Consequently, a query corresponds to the environmental characteristics of one or more Attesters.
Such environmental characteristics are identical to those used in the information model of CoRIM {{-rats-corim}}.
In summary, they can include the following:

- An individual Attester instance.
- A group (identifiable collection) of Attester instances.
- A class of Attester, defined by characteristics such as the vendor or model, of which there may be an arbitrary number of instances.

To facilitate efficient transactions, a single query can specify either multiple instances, multiple groups or multiple classes.

## Result Sets

The result set contains the artifacts that the producer collected in response to the query.
The top-level structure of the result set consists of the following three items:

- A collection of one or more result entries.
This will be a collection of either reference values, endorsed values, trust anchors, or extensions.
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
These correspond to the following three categories of endorsement artifact that can be identified in the RATS architecture:

  - **Trust Anchor** (`trust-anchors`): A trust anchor is as defined in {{RFC6024}}. An example of a trust anchor would be the public part of the asymmetric signing key that is used by the Attester to sign Evidence, such that the Verifier is able to verify the cryptographic signature.
  - **Endorsed Value** (`endorsed-values`): An endorsed value is as defined in {{Section 1.1.1 of -rats-corim}}.
  - **Reference Value** (`reference-values`): A reference value is as defined in {{Section 1.1.1 of -rats-corim}}. A reference value specifies an individual aspect of the Attester's desired state. Reference values are sometimes informally called "golden values". An example of a reference value would be the expected hash or checksum of a binary firmware or software image running in the Attester's environment. Evidence from the Attester would then include claims about the Attester's actual state, which the Verifier can then compare with the reference values at Evidence appraisal time.

It is expected that implementations might choose to store these different categories of artifacts in different top-level stores or database tables.
Where this is the case, the `artifact-type` field serves to narrow the query down to the correct store or table.
Even where this is not the case, the discriminator is useful as a filter for the consumer, resulting in an efficiency gain by avoiding the transfer of unwanted data items.

### Environment Selector

The environment selector forms the main body of the query, and its CDDL is given below:

~~~cddl
{::include cddl/environment-selector.cddl}
~~~

The environment defines the scope (or scopes) in which the endorsement artifacts are applicable.
Given that the consumer of these artifacts is likely to be a Verifier in the RATS model, the typical interpretation of the environment would be that of an Attester that either has produced evidence, or is expected to produce evidence, that the Verifier needs to appraise.
The Verifier consequently needs to query the Endorser or Reference Value Provider for artifacts that are applicable in that environment.
There are three mutually-exclusive methods for defining the environment within a CoSERV query.
Exactly one of these three methods must be used for the query to be valid.
All three methods correspond to environments that are also defined within CoRIM.

- **Class**: A class is an environment that is expected to be common to a group of similarly-constructed Attesters, who might therefore share the same set of endorsed characteristics. An example of this might be a fleet of computing devices of the same model and manufacturer.

- **Instance**: An instance is an environment that is unique to an individual and identifiable Attester, such as a single computing device or component.

- **Group**: A group is a collection of common Attester instances that are collected together based on some defined semantics. For example, Attesters may be put into groups for the purpose of anonymity.

Although these three environment definitions are mutually-exclusive in a CoSERV query, all three support multiple entries.
This is to gain efficiency by allowing the consumer (such as a Verifier) to query for multiple artifacts in a single transaction.
For example, where artifacts are being indexed by instance, it would be possible to specify an arbitrary number of instances in a single query, and therefore obtain the artifacts for all of them in a single transaction.
Likewise for classes and groups.
However, it would not be possible for a single query to specify more than one kind of environment.
For example, it would not be possible to query for both class-level and instance-level artifacts in a single CoSERV transaction.

## Result Set Structure

The result set structure is given by the following CDDL:

~~~cddl
{::include cddl/result-set.cddl}
~~~

## Encoding Requirements

Implementations may wish to use serialized CoSERV queries as canonical identifiers for artifact collections.
For example, a Reference Value Provider service may wish the cache the results of a CoSERV query to gain efficiency when responding to a future identical query.
For these use cases to be effective, it is essential that any given CoSERV query is always serialized to the same fixed sequence of CBOR bytes.
Therefore, CoSERV queries MUST always use CBOR deterministic encoding as specified in {{Section 4.2 of -cbor}}.
Further, CoSERV queries MUST use CBOR definite-length encoding.

## Cryptographic Binding Between Query and Result Set {#signed-coserv}

CoSERV is designed to ensure that any result set passed from a producer to a consumer is precisely the result set that corresponds to the consumer's original query.
This is the reason why the original query is always included along with the result set in the data model.
However, this measure is only sufficient in cases where the conveyance protocol guarantees that CoSERV result sets are always transacted over an end-to-end secure channel without any intermediaries.
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
The result structure is a map with two entries: `expiry` (codepoint 10) and `reference-value triples` (codepoint 0).
A single reference-value triple is shown in this example. Its `environment-map`, as expected, is the same as the `environment-map` that was supplied in the query.
The rest of the structure is the `measurement-map` as defined in CoRIM {{-rats-corim}}.

~~~edn
{::include-fold cddl/examples/rv-results.diag}
~~~

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

# Acknowledgments
{:numbered="false"}

TODO acknowledge.

[^rfced]: RFC Editor:
