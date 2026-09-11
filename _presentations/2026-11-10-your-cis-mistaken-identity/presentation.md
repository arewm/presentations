name: inverse
layout: true
class: center, middle, inverse

---

class: center, middle, title-slide

# Your CI's Mistaken Identity

## Task-Scoped Trust in Cloud-Native Pipelines

Andrew McNamara (Red Hat) • Maia Iyer (IBM Research)

<div style="margin-top: 2em; display: flex; justify-content: center; align-items: center; gap: 2.5em;">
  <img src="/shared/logos/tekton.png" width="90" alt="Tekton logo">
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <img src="/shared/logos/intoto-icon.svg" width="90" alt="in-toto logo">
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <span style="font-family: sans-serif; font-weight: 700; font-size: 2.2em; color: #38bdf8;">SPIFFE / SPIRE</span>
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <span style="font-family: sans-serif; font-weight: 700; font-size: 2.2em; color: #f59e0b;">Kyverno</span>
</div>

.footnote[
  KubeCon + CloudNativeCon North America · November 10, 2026
]

???

Andrew and Maia introduce themselves.
Andrew: "I'm Andrew McNamara, SLSA maintainer, Konflux/Tekton contributor."
Maia: "I'm Maia Iyer from IBM Research, SPIFFE maintainer and Tornjak contributor."
"Today we're talking about why workload identity in CI/CD currently has a major identity crisis."

---

layout: false

## The Hook: A Simple Question

> **"You wouldn't ask a plumber to sign off on your electrical work."**

--

Yet in nearly every Kubernetes CI/CD pipeline running today:

* One shared `ServiceAccount` runs every step in the pipeline.
* One signing key or ambient cloud credential signs the SBOM, the vulnerability scan, and the release provenance.
* A compromised dependency-fetch task has the **exact same signing authority** as your build and release tasks.

--

<div class="warn-box">
  <strong>The Problem:</strong> Workload identities encode <em>location</em> (where something ran), not <em>authorization</em> (what it was permitted to do).
</div>

???

Think about what happens when a pipeline runs in Kubernetes. Tekton spawns a series of pods for tasks. All of them run in the same namespace, usually under the same service account. If you give that service account an IAM role or a Cosign key, any task that gets compromised can produce any attestation it wants.

---

## Where Are We Today? (Ambient Authority)

In standard Tekton and Kubernetes pipelines:

```text
PipelineRun: build-and-test
  ├── Task 1: git-clone         [SA: pipeline-runner]  ◄── Untrusted code / PRs
  ├── Task 2: fetch-deps        [SA: pipeline-runner]  ◄── Ecosystem packages
  ├── Task 3: build-container   [SA: pipeline-runner]  ──► Signs SBOM
  └── Task 4: trivy-scan        [SA: pipeline-runner]  ──► Signs CVE Report
```

--

### The Failure Mode:
* If `fetch-deps` or an inline script executes malicious code, it possesses the ambient tokens of `pipeline-runner`.
* It can call Fulcio, AWS STS, or HashiCorp Vault directly.
* It can sign an in-toto attestation claiming: *"0 vulnerabilities found!"*
* Downstream policy engines look at the signature and say: *"Signed by pipeline-runner? Looks legit to me!"*

???

Signature presence is not authorization. Just because something has a cryptographic signature doesn't mean the entity signing it had the authority to make that claim.

---

class: center, middle, inverse

# Act 1: The Core Thesis
## Authorization Must Follow Role, Not Location

---

layout: false

## Location vs. Role-Scoped Identity

Most SPIFFE/SPIRE deployments encode **location**:

```text
spiffe://company.org/ns/build-tenant/sa/pipeline-runner
```

What does this tell a downstream policy engine?
* ✅ It ran in namespace `build-tenant`.
* ✅ It used the `pipeline-runner` service account.
* ❌ Was it authorized to sign an SBOM?
* ❌ Was it a vetted vulnerability scanner or an inline bash script?

--

### What We Actually Need:

```text
spiffe://konflux-ci.dev/trusted/prod/builder/task-buildah-oci-ta
spiffe://konflux-ci.dev/trusted/prod/scanner/task-trivy-sbom-scan
```

Now the identity encodes **role** and **vetted capability**.

???

SPIFFE's design is authentication only — it identifies the workload. Authorization is delegated. By embedding admission-vetted task roles into the SPIFFE ID hierarchy, we provide policy engines with the exact signal they need to make authorization decisions.

---

class: center, middle, inverse

# Act 2: How It Works
## Tekton + Kyverno + SPIRE + Sigstore

---

layout: false

## The 4-Step Architecture

<div style="display: flex; flex-direction: column; gap: 1em; margin-top: 1em;">
  <div class="highlight-box">
    <strong>1. Admission Verification (Kyverno):</strong> Intercepts TaskRuns before pods schedule. Validates that task definitions are digest-pinned, signed OCI bundles from an approved catalog.
  </div>
  <div class="highlight-box">
    <strong>2. Trust Classification:</strong> Kyverno stamps <code>trusted-task-role: prod</code> (for signed catalog tasks) or <code>dev</code> (for untrusted/inline tasks).
  </div>
  <div class="highlight-box">
    <strong>3. Workload Attestation (SPIRE):</strong> SPIRE agent verifies pod labels via CSI socket and issues an ephemeral SVID scoped to that specific task role.
  </div>
  <div class="highlight-box">
    <strong>4. Scoped Signing (Sigstore/Fulcio):</strong> Task exchanges SVID for a short-lived certificate and signs its role-specific in-toto attestation.
  </div>
</div>

???

Let's walk through how these pieces connect in real time. We aren't introducing proprietary tooling. This is standard Tekton, standard Kyverno, standard SPIFFE/SPIRE, and standard Sigstore.

---

## Step 1: Kyverno at the Gate

Kyverno intercepts the `TaskRun` at admission time:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-bundle-signatures
spec:
  validationFailureAction: Enforce
  rules:
  - name: verify-trusted-bundle
    match:
      resources:
        kinds: [TaskRun]
    imageExtractors:
      TaskRun:
      - path: "/spec/taskRef/params/*"
        name: "bundle"
        key: "name"
        value: "value"
        filter: "bundle"
    verifyImages:
    - type: SigstoreBundle
      imageReferences:
      - "quay.io/konflux-ci/tekton-catalog/*"
      attestors:
      - entries:
        - keys:
            publicKeys: "k8s://tekton-pipelines/catalog-pubkey"
```

???

Notice the imageExtractors stanza. Tekton bundles are OCI artifacts stored in registries. Kyverno uses our upstream filter extension to isolate the bundle parameter from general task parameters and validates its Cosign signature before the task pod is allowed to run as prod.

---

## Step 2: SPIRE Mints the Role SVID

`ClusterSPIFFEID` evaluates the Kyverno-verified pod labels:

```yaml
apiVersion: spire.spiffe.io/v1alpha1
kind: ClusterSPIFFEID
metadata:
  name: konflux-trusted-prod
spec:
  spiffeIDTemplate: >-
    spiffe://konflux-ci.dev/trusted/cluster-01/{{ .PodSpec.ServiceAccountName }}/{{ index .PodMeta.Labels "tekton.dev/task" }}
  podSelector:
    matchLabels:
      trusted-task-role: "prod"
```

--

### The Resulting Identities:
* Scanner Task:
  `spiffe://konflux-ci.dev/trusted/cluster-01/runner/trivy-sbom-scan`
* Builder Task:
  `spiffe://konflux-ci.dev/trusted/cluster-01/runner/buildah-oci-ta`
* Untrusted / Inline Task:
  `spiffe://konflux-ci.dev/dev/cluster-01/runner/arbitrary-script`

???

Notice how cleanly the roles separate. Even though all three pods run under the 'runner' ServiceAccount, they receive completely distinct cryptographic identities because of admission-time verification.

---

## Step 3: Scoped Attestation Signing

Each task produces attestations matching its specific domain:

### Builder Task (`buildah-oci-ta`):
```bash
cosign attest \
  --predicate sbom.spdx.json \
  --type https://spdx.dev/Document/v2.3 \
  --yes "$IMAGE"
```
*Signed by:* `.../runner/buildah-oci-ta`

--

### Scanner Task (`trivy-sbom-scan`):
```bash
cosign attest \
  --predicate trivy-report.json \
  --type https://aquasecurity.github.io/trivy/report/v1 \
  --yes "$IMAGE"
```
*Signed by:* `.../runner/trivy-sbom-scan`

???

Each task communicates with the SPIRE agent over the local CSI socket. Cosign exchanges the SPIFFE JWT-SVID with Fulcio to get a code-signing certificate where the SAN URI matches the task's specific SPIFFE identity.

---

## Step 4: Policy Enforcement (Conforma)

Now the policy engine can enforce **Separation of Duties**:

```rego
package policy.cve

# Rule: Vulnerability reports MUST be signed by an authorized scanner
deny[msg] {
  attestation := input.attestations[_]
  attestation.predicateType == "https://aquasecurity.github.io/trivy/report/v1"
  
  # Check certificate identity
  not startswith(attestation.certificate.uri, 
                 "spiffe://konflux-ci.dev/trusted/cluster-01/runner/trivy-sbom-scan")
  
  msg := sprintf("CVE scan signed by unauthorized role: %s", [attestation.certificate.uri])
}
```

--

<div class="highlight-box">
  <strong>The Guarantee:</strong> Even if a builder task signs an attestation claiming 0 vulnerabilities, Conforma rejects it because the builder is not an authorized scanner!
</div>

???

This is the punchline of the talk. The policy engine doesn't just ask 'is there a signature from the cluster?'. It asks: 'Did the claim come from the role authorized to make that claim?'. Plumbers do plumbing. Electricians do electrical.

---

class: center, middle, inverse

# Act 3: Live Demo
## Watch the Separation of Duties in Action

---

layout: false

## Live Demo Architecture

```text
[ Developer triggers PipelineRun ]
       │
       ├──► Kyverno intercepts TaskRuns
       │      ├── Signed Catalog Task   ──► Labeled: trusted-task-role: prod
       │      └── Tampered Inline Task  ──► Labeled: trusted-task-role: dev
       │
       ├──► Tasks execute in Pods
       │      ├── Trivy mounts SPIFFE socket ──► Gets Scanner SVID ──► Signs CVE report
       │      └── Buildah mounts SPIFFE socket ──► Gets Builder SVID ──► Signs SBOM
       │
       └──► Conforma Policy Evaluation
              ├── Checks SBOM signer == Builder SVID   ──► [PASS]
              ├── Checks CVE signer  == Scanner SVID   ──► [PASS]
              └── Malicious scan signed by Builder     ──► [REJECTED]
```

--

* **Demo Scenario 1:** Normal build with signed, separated roles passing policy.
* **Demo Scenario 2:** Attacker attempts to forge clean scan from build step ➔ Policy blocks release.

???

We run through the demo live on a local cluster. Show the TaskRun admission, inspect the SPIFFE SVID in the pod, inspect the resulting Fulcio certificate SANs on the image, and show Conforma's policy evaluation catching the role violation.

---

class: center, middle, inverse

# Act 4: The Next Frontier
## Extending Trust to the Release Boundary

---

layout: false

## The Managed Release Boundary

Does task-scoped identity solve everything?

--

In the platform's **release namespace**:
```text
spiffe://konflux-ci.dev/trusted/cluster-01/release-sa/attach-summary-attestations
```

* Downstream consumers verifying a **Verification Summary Attestation (VSA)** don't care *which container script attached the label*.
* Consumers need proof that **policy was actually satisfied**.

--

### The Next Evolution: Dual-Control & Clearance Tokens
* **Pipeline-Scoped Identity:** SVID identifies the whole verified release pipeline authority.
* **Policy Clearance Tokens:** `verify-conforma` mints an ephemeral token tied to `PipelineRun.UID` *only* when 100% of policy rules pass.
* The attachment task must present **both** identity and clearance token to sign the VSA.

???

This is a great thought-provoking teaser for the audience. Inside the build namespace, task-scoped identity enforces separation of duties. At the release boundary, identity evolves into proof of policy compliance.

---

## Key Takeaways

1. **Location ≠ Authorization**: Stop treating Kubernetes namespaces and generic ServiceAccounts as authorization boundaries.
2. **Shift Verification to Admission**: Intercepting task bundles at admission with Kyverno prevents untrusted code from ever gaining production identities.
3. **Task-Scoped Identity is Real Today**: Combining Tekton, Kyverno, SPIFFE/SPIRE, and Sigstore brings least-privilege cryptographic identity to every CI step.
4. **Policy Closes the Loop**: In-toto attestations signed by role-scoped SVIDs allow policy engines like Conforma to verify *who was authorized to make each claim*.

--

<div class="highlight-box" style="text-align: center; margin-top: 1.5em;">
  <strong>Working Code & Helm Charts:</strong><br>
  <code>github.com/arewm/slsa-konflux-example</code><br>
  (Branch: <code>worktree-spiffe-spire-exploration</code>)
</div>

---

class: center, middle, inverse

# Thank You!

### Questions & Discussion

**Andrew McNamara** (amcnamar@redhat.com) • **Maia Iyer** (miyer@redhat.com)

<div style="margin-top: 2em; display: flex; justify-content: center; gap: 4em;">
  <div>
    <strong>Presentation & Code</strong><br>
    <code>github.com/arewm/presentations</code>
  </div>
  <div>
    <strong>SLSA & Tekton Demo</strong><br>
    <code>github.com/arewm/slsa-konflux-example</code>
  </div>
</div>
