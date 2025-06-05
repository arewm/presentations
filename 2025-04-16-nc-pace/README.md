# Let Devs Be Devs

**NC PACE 2024 - Trust Establishment in Software Supply Chain Security**

**Speaker:** Andrew McNamara, Red Hat  
**Date:** April 16, 2024  
**Duration:** 45 minutes  
**Event:** NC PACE 2024, Raleigh, NC

## Abstract

Software is meant to be used by people, not just locked down by security policies. This presentation explores how we can establish trust in our software supply chain while keeping developers productive and happy.

Using Red Hat's implementation with Tekton and Tekton Chains, we'll demonstrate a progressive trust model that starts with basic K8s + Tekton foundations and builds up through community-contributed trusted tasks, tamper-proof data flows, independent SLSA provenance generation, automated policy guidance, and finally a "build once, release everywhere" service.

The key insight: instead of blocking developers with rigid security controls, we can create systems that guide them toward secure practices while preserving their autonomy and creativity.

## Presentation Structure

### Core Themes
1. **Developer Experience First** - Security should enable, not hinder
2. **Progressive Trust Building** - Layer security incrementally 
3. **Community Contribution** - Shared responsibility and knowledge
4. **Policy as Guidance** - Violations inform rather than block
5. **Tamper-Proof Workflows** - Technical guarantees without friction

### Key Sections
- **Trust Model Visualization** - The six-layer security foundation
- **Community Workflow Demo** - From personal tasks to shared bundles
- **Policy Violations as Teaching** - Real-time feedback without blocking
- **Container Build Generalization** - Practical automation examples
- **Developer Transformation** - Before/after experience comparison

## Technical Components

- **Foundation:** Kubernetes + Tekton pipeline platform
- **Task Library:** Community-verified, reusable build components
- **Artifact Security:** Cryptographic signing and attestation  
- **Provenance Generation:** Automatic SLSA compliance via Tekton Chains
- **Policy Engine:** Conforma-based guidance and requirements checking
- **Release Service:** Multi-environment deployment orchestration

## Files

- **`let-devs-be-devs.html`** - Main presentation file (open this to view)
- **`let-devs-be-devs.md`** - Markdown source content
- **`img/`** - Presentation-specific images, diagrams, and screenshots
- **`../shared/images/`** - Shared resources (logos, QR codes, trust model diagrams)

## Viewing the Presentation

### Option 1: Direct HTML Access
```bash
cd 2024-04-16-let-devs-be-devs
open let-devs-be-devs.html
```

### Option 2: Local Server (Recommended for development)
From the repository root:
```bash
python3 -m http.server 8000
# Then visit: http://localhost:8000/2024-04-16-let-devs-be-devs/let-devs-be-devs.html
```

## Presenting

- **Navigate**: Arrow keys, Page Up/Down, or click
- **Fullscreen**: Press `F`
- **Presenter Mode**: Press `P` (shows current + next slide, timer, notes)
- **Clone View**: Press `C` (for dual monitor setup)

## Key Takeaways

1. **Trust can be built progressively** without sacrificing developer experience
2. **Community contribution** scales security knowledge and reduces individual burden  
3. **Policy violations** are opportunities for education, not roadblocks
4. **Technical guarantees** (signing, attestation) provide security without friction
5. **Developer autonomy** and security compliance can coexist

## Resources

- **Event:** NC PACE 2024, Raleigh, NC
- **Konflux CI/CD Platform:** https://konflux-ci.dev
- **Tekton Pipelines:** https://tekton.dev
- **Tekton Chains:** https://tekton.dev/docs/chains  
- **SLSA Framework:** https://slsa.dev
- **Conforma Policy Engine:** https://conforma.dev

## Development Notes

This presentation includes custom CSS for trust model visualizations and uses several animated diagrams to show the progression from basic pipelines to full supply chain security. The live demo components require local Konflux access for full functionality 