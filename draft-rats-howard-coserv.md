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
  STD96:
    -: cose
    =: RFC9052
  STD94:
    -: cbor
    =: RFC8949
  RFC9334: rats-arch

informative:
  I-D.ietf-rats-endorsements: rats-endorsements

--- abstract

In the Remote Attestation Procedures (RATS) architecture, Verifiers require Endorsements and Reference Values to assess the trustworthiness of Attesters. This document specifies the Concise Selector for Endorsements and Reference Values (CoSERV), a structured query format designed to facilitate the discovery and retrieval of these artifacts from various providers. CoSERV defines a query language that can be expressed in both JSON and CBOR formats, with a common CDDL schema, enabling interoperability across diverse systems.

--- middle

# Introduction {#sec-intro}

Remote Attestation Procedures (RATS) enable Relying Parties to evaluate the trustworthiness of remote Attesters by appraising Evidence. This appraisal necessitates access to Endorsements and Reference Values, which are often distributed across multiple providers, including hardware manufacturers, firmware developers, and software vendors. The lack of standardized methods for querying and retrieving these artifacts poses challenges in achieving seamless interoperability.

The Concise Selector for Endorsements and Reference Values (CoSERV) addresses this challenge by defining a query language that allows Verifiers to specify the environment characteristics of the desired artifacts. This facilitates the efficient discovery and retrieval of relevant Endorsements and Reference Values from providers.

## Terminology and Requirements Language

{::boilerplate bcp14-tagged}

This document uses terms and concepts defined by the RATS architecture.
For a complete glossary, see {{Section 4 of -rats-arch}}.

This document uses the terms _"actual state"_ and _"reference state"_ as defined in {{Section 2 of -rats-endorsements}}.

The terminology from CBOR {{-cbor}}, CDDL {{-cddl}} and COSE {{-cose}} applies;
in particular, CBOR diagnostic notation is defined in {{Section 8 of -cbor}}
and {{Section G of -cddl}}. Terms and concepts are always referenced as proper nouns, i.e., with Capital Letters.

### Glossary {#sec-glossary}

This document uses the following terms:

- **Attester**: An entity that produces attestation Evidence about its identity, software, and operational state.

- **Verifier**: An entity that appraises Evidence using Endorsements, Reference Values, and appraisal policies to produce Attestation Results.

- **Endorsement**: A secure statement from an entity (typically a manufacturer) vouching for the integrity of an Attester's signing capability.

- **Reference Value**: Known-good measurements or configurations against which the Verifier compares the Attester's Evidence.

- **Environment**: The context in which measurements are applicable, encompassing attributes such as hardware, software, and configuration settings.

- **CoRIM**: Concise Reference Integrity Manifest, a format for conveying Endorsements and Reference Values.

- **CoSERV**: Concise Selector for Endorsements and Reference Values, the query format specified in this document.

# Problem Statement

As outlined in the RATS architecture [RFC9334], Verifiers rely on Endorsements and Reference Values to assess attestation Evidence. These artifacts are often maintained by different providers, leading to challenges in their discovery and retrieval. The absence of a standardized query mechanism results in:

- **Interoperability Issues**: Diverse data formats and access methods hinder seamless integration between Verifiers and artifact providers.

- **Increased Complexity**: Verifiers must implement multiple interfaces to interact with various providers, complicating the attestation process.

- **Latency in Appraisal**: Delays in retrieving necessary artifacts can impede timely attestation, affecting system performance and security.

CoSERV aims to mitigate these issues by providing a unified query format that standardizes the selection criteria for Endorsements and Reference Values, facilitating efficient and interoperable interactions between Verifiers and providers.

# CoSERV Query Language

The CoSERV query language enables Verifiers to specify the desired characteristics of Endorsements and Reference Values based on the environment in which they are applicable. This section details the structure of CoSERV queries, which can be serialized in both JSON and CBOR formats, adhering to a common CDDL schema.

# Environment Specification

An environment in CoSERV encompasses attributes that define the context for which Endorsements or Reference Values are relevant. These attributes include:

- **Class**: The general category of the environment (e.g., hardware, software, virtual machine).

- **Instance**: Specific details identifying a unique environment instance, such as serial numbers or unique identifiers.

- **Group**: A collection of related environments sharing common characteristics.

# Query Structure

A CoSERV query comprises the following elements:

- **Environment**: An object detailing the environment attributes as specified above.

- **Artifact Type**: A field indicating whether the query is for an Endorsement, Reference Value, or both.

- **Version Constraints**: Optional parameters specifying acceptable version ranges for the requested artifacts.

- **Security Level**: Optional attribute denoting the required security assurance level of the artifacts.

# JSON Representation

Below is an example of a CoSERV query in JSON format:

```json
{
  "environment": {
    "class": "hardware",
    "instance": {
      "id": "1234-5678-9012",
      "attributes": {
        "manufacturer": "ExampleCorp",
        "model": "X1000"
      }
    },
    "group": {
      "group_id": "group-01",
      "members": ["1234-5678-9012", "1234-5678-9013"]
    }
  },
  "artifact_type": "endorsement",
  "version_constraints": {
    "min_version": "1.0",
    "max_version": "2.0"
  },
  "security_level": "high"
}

# IANA Considerations

This document has no IANA actions.


--- back

# Acknowledgments
{:numbered="false"}

TODO acknowledge.
