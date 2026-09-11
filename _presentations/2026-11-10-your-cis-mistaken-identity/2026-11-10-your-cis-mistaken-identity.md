---
title: "Your CI's Mistaken Identity: Task-Scoped Trust in Cloud-Native Pipelines"
event: "KubeCon + CloudNativeCon North America 2026"
date: 2026-11-10
slides_path: presentation.md
excerpt: "You wouldn't ask a plumber to sign off on your electrical work. Yet most CI/CD pipelines run under a single identity: one credential for signing SBOMs and reporting vulnerabilities alike. How Tekton, Kyverno, SPIFFE/SPIRE, and Sigstore close this gap."
# session: "https://kccncna2026.sched.com/event/..."
# recording: "https://www.youtube.com/watch?v=..."
demo: "https://github.com/arewm/slsa-konflux-example/tree/worktree-spiffe-spire-exploration"
---

## Abstract

You wouldn't ask a plumber to sign off on your electrical work. Yet most CI/CD pipelines run under a single identity: one credential for signing SBOMs and reporting vulnerabilities alike. Workload identities encode location, not authorization.

This session shows how to close that gap with Tekton: admission-time verification of signed remote task definitions constrains the SPIFFE/SPIRE identity each task receives. Tasks use that SVID to produce in-toto attestations scoped to their role. Policy engines can then enforce that each claim came from the right kind of task — a vulnerability attestation from a scanner, an SBOM from a build task — not just that a signature exists.

Attendees leave with a working technique and one transferable insight: authorization should follow role, not location — from signing attestations to authenticating against external services.

## Key Topics

- **The Mistaken Identity Problem**: Pod-scoped vs. role-scoped workload identity in CI/CD pipelines.
- **Admission-Time Classification**: Using Kyverno to verify remote, content-addressed OCI task bundles at admission time.
- **Dynamic Identity Issuance**: Using SPIFFE/SPIRE to mint task-scoped SVIDs based on admission verification labels.
- **Role-Based Attestations**: Tasks using short-lived SVIDs to sign role-specific in-toto statements (Trivy scanner signing vulnerability reports, Buildah signing SBOMs).
- **Policy Enforcement (Conforma)**: Verifying that each claim was authored by an authorized task role, eliminating ambient ServiceAccount authority.
- **Managed Release Boundaries**: Extending task identity to pipeline-scoped authority and cryptographic policy clearance tokens.
