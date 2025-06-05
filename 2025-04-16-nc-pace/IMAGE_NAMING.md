# Image Naming Convention

This presentation uses **content-based naming** for all images to make them more maintainable and meaningful, independent of slide order.

## Naming Categories

### Developer Workflow Images (`dev-*`)
- `dev-workflow-icon.png` - Generic developer workflow icon (consolidated from 3 identical copies)
- `dev-build-process-chain.png` - Build process chain visualization
- `dev-troubleshoot-system.png` - System troubleshooting workflow  
- `dev-explore-pipelines.png` - Exploring new tech via pipelines workflow

### Konflux Architecture Diagrams (`konflux-*`)
- `konflux-architecture-overview.png` - Overall Konflux architecture diagram
- `konflux-trusted-tasks.png` - Trusted task library diagram
- `konflux-trusted-artifacts.png` - Trusted artifacts flow diagram
- `konflux-observer-attestations.png` - Observer attestations diagram
- `konflux-policy-engine.png` - Policy engine architecture diagram

### Policy & Base Images (`policy-*`, `base-images-*`)
- `policy-base-images-example.png` - Example of allowed base images policy
- `policy-violations-screenshot.png` - Policy violations interface screenshot
- `base-images-icon.png` - Base images icon (consolidated from 2 identical copies)
- `base-images-icon-3.png` - Base images icon (variant 3)

### Workflow Screenshots
- `onboard-repository-screenshot.png` - Repository onboarding interface
- `pac-changes-pr-proposal.png` - PAC changes PR proposal (consolidated from 2 identical copies)
- `troubleshoot-pr-screenshot.png` - PR troubleshooting interface
- `explore-custom-tasks-screenshot.png` - Custom tasks exploration interface

## Shared Images

Common logos and icons are stored in `../shared/images/` and referenced by multiple presentations:
- `slsa-supply-chain-threats.png`
- `slsa-favicon.png`
- `tekton-logo.png`
- `pipelines-as-code-logo.png`
- `oci-logo.png`
- `tekton-chains-logo.png`
- `tekton-chains-how-it-works.png`
- `conforma-icon.png`
- `conforma-screenshot.png`
- `konflux-logo.png`
- `konflux-banner.png`
- `github-logo.png`
- `qr-konflux-ci.png`
- `qr-hermeto.png`
- `qr-conforma.png`

## Benefits of Content-Based Naming

1. **Slide-Order Independent**: Images can be moved between slides without renaming
2. **Self-Documenting**: Names clearly indicate what each image contains
3. **Easier Maintenance**: Finding and updating specific images is straightforward
4. **Reusability**: Images can be easily referenced from other presentations
5. **Version Control Friendly**: Changes to slide order don't affect image references
6. **Reduced Redundancy**: Identical images are consolidated to save space and reduce confusion 