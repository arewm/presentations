---
title: "From Mild To Wild: How Hot Can Your SLSA Be?"
event: "Open Source SecurityCon"
date: 2026-03-23
slides_path: presentation.md
custom_css: custom.css
excerpt: "You have attestations—now what? Three levels of policy enforcement: mild (simple verification), medium (combining multiple attestations and producing a VSA), wild (leveraging attestation specifics for trusted-task L3). Demonstrated with AMPEL and Conforma on the same use cases."
session: https://sched.co/2DY1G
# recording: "https://example.com/video-link"
---

## Abstract

Policy engines can consume attestations at three heat levels. Start mild and turn up the heat as you mature.

Mild: Verify builder identity, SLSA levels, signatures, attestations. Answer "Who built this?" and "Does it meet standards?"

Medium: Generate Verification Summary Attestations from multiple sources. Deploy admission controllers blocking nonconforming workloads from deploying. Enforce standards automatically. Attestations drive decisions, not documentation.

Wild: Build trust chains through provenance. Chain attestations across the software lifecycle, from the build environment, down to the consumer. Enabling verifiers to reason about artifacts, not just their signatures. Demands process maturity but unlocks flexible security.

We demonstrate implementations at each level using policy engines, including AMPEL and Conforma. Discover which heat level matches your organization and how to turn up the temperature.

## Key Topics

- Attestations and predicates (in-toto, SLSA provenance)
- Three levels: mild (simple verification), medium (combining attestations + VSA), wild (attestation-specific trust, e.g. trusted tasks → L3)
- Combining multiple attestations so downstream checks one VSA instead of re-verifying each
- Comparing AMPEL and Conforma on identical use cases; policy portability across engines
- Tekton provenance, trusted task allowlists, VSA at L2 vs L3
