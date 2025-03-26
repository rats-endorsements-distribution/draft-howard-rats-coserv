---
title: "Concise Selector for Endorsements and Reference Values"
abbrev: "CoSERV"
category: info

docname: draft-rats-howard-coserv-latest
submissiontype: IETF  # also: "independent", "editorial", "IAB", or "IRTF"
number:
date:
consensus: true
v: 3
# area: AREA
# workgroup: WG Working Group
keyword:
 - RATS
 - attestation
 - endorsement
 - reference value
venue:
#  group: WG
#  type: Working Group
#  mail: WG@example.com
#  arch: https://example.com/WG
  github: "paulhowardarm/draft-rats-howard-coserv"
  latest: "https://paulhowardarm.github.io/draft-rats-howard-coserv/draft-rats-howard-coserv.html"

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

informative:
  RFC6024: TA requirements
  I-D.ietf-rats-endorsements: rats-endorsements
  I-D.ietf-rats-corim: rats-corim
  I-D.ietf-rats-eat: rats-eat

--- abstract

In the Remote Attestation Procedures (RATS) architecture, Verifiers require Endorsements and Reference Values to assess the trustworthiness of Attesters.
This document specifies the Concise Selector for Endorsements and Reference Values (CoSERV), a structured query format designed to facilitate the discovery and retrieval of these artifacts from various providers.
CoSERV defines a query language using CDDL that can be serialized in CBOR format, enabling interoperability across diverse systems.

--- middle

# Introduction {#sec-intro}

Remote Attestation Procedures (RATS) enable Relying Parties to evaluate the trustworthiness of remote Attesters by appraising Evidence.
This appraisal necessitates access to Endorsements and Reference Values, which are often distributed across multiple providers, including hardware manufacturers, firmware developers, and software vendors.
The lack of standardized methods for querying and retrieving these artifacts poses challenges in achieving seamless interoperability.

The Concise Selector for Endorsements and Reference Values (CoSERV) addresses this challenge by defining a query language that allows Verifiers to specify the environment characteristics of the desired artifacts.
This facilitates the efficient discovery and retrieval of relevant Endorsements and Reference Values from providers.

The CoSERV query language is intended to form the input data type for tools and services that provide access to Endorsements and Reference Values.
This document does not define the complete APIs or interaction models for such tools and services.
Nor does this document constrain the format of the output data that such tools and services might produce.
The scope of this document is limited to the definition of the query language only.

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

# CoSERV Query Language

The CoSERV query language enables Verifiers to specify the desired characteristics of Endorsements and Reference Values based on the environment in which they are applicable.
This section presents the CBOR data model for CoSERV queries.

CDDL is used to express rules and constraints of the data model for CBOR.
These rules must be strictly followed when creating or validating CoSERV data objects.

## Common Data Types

CoSERV inherits the following types from the CoRIM data model `class-map`, `$class-id-type-choice`, `$instance-id-type-choice` and `$group-id-type-choice`.

The collated CDDL is in {{collated-cddl}}.

## Query Structure

The top-level structure of a CoSERV query is given by the following CDDL:

~~~cddl
{::include cddl/coserv.cddl}
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

### Profile

In common with EAT and CoRIM, CoSERV supports the notion of profiles.
As with EAT and CoRIM, profiles are a way to extend or specialize the structure of a generic CoSERV query in order to cater for a specific use case or environment.

In a CoSERV query, the profile can be identified by either a Uniform Resource Identifier (URI) or an Object Identifier (OID).
This convention is identical to how EAT profiles are identified using the `eat_profile` claim as described in {{Section 4.3.2 of -rats-eat}}.

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

# Examples

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

# Security Considerations
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

# Privacy Considerations
TODO

# Implementation Status
TODO

# IANA Considerations

TODO: Add media type requests for `application/serv+cbor` and `application/serv+json`.

--- back

# Collated CoSERV CDDL {#collated-cddl}

~~~
{::include-fold cddl/coserv.cddl}

{::include-fold cddl/environment-selector.cddl}

{::include-fold cddl/mini-comid.cddl}

{::include-fold cddl/mini-cose.cddl}
~~~

# Acknowledgments
{:numbered="false"}

TODO acknowledge.
