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

Maia opens the talk.
"Think about what happens when a pipeline runs in Kubernetes. Tekton spawns a series of pods for tasks. All of them run in the same namespace, usually under the same service account. If you give that service account an IAM role or a Cosign key, any task that gets compromised can produce any attestation it wants."

---

## The Identity Perspective: Why Location Fails Us

<span class="pill pill-blue">Maia · Identity & Auth</span>

In the cloud-native identity world, we solved machine-to-machine authentication with **Workload Identity (SPIFFE/SPIRE)**.

We said: *"No more hardcoded API keys or static credentials in Kubernetes Secrets."*

--

### The Standard SPIFFE Deployment Model:
Workload Attestors inspect the running container:
* Kubernetes Namespace (`default-tenant`)
* ServiceAccount Name (`pipeline-runner`)
* Node or Cluster Name (`prod-cluster-01`)

```text
spiffe://company.org/ns/default-tenant/sa/pipeline-runner
```

--

### The Blind Spot:
* Workload identity was designed for **long-running microservices** communicating over mTLS (`service-a` talking to `service-b`).
* In microservices, the service boundary *is* the identity boundary.
* In CI/CD, the workload is an **ephemeral DAG of heterogeneous tools** executing wildly different actions under a single tenant identity.

???

Maia: "From the identity community's perspective, SPIFFE was a huge leap forward. We eliminated static credentials. But we brought microservice-era assumptions into CI/CD. In a microservice, ServiceAccount ≈ Application. In CI/CD, ServiceAccount ≈ The entire factory, including untrusted PR checkouts, third-party package downloaders, compiler toolchains, security scanners, and release signers. Location alone no longer tells you who is calling."

---

## The Supply Chain Threat: Confused Deputies in CI

<span class="pill pill-blue">Maia · Identity & Auth</span>

When identity is coarse, every pipeline step becomes a potential **Confused Deputy**:

```text
PipelineRun: build-and-test
  ├── Task 1: git-clone         [SA: runner]  ◄── Untrusted code / PRs
  ├── Task 2: fetch-deps        [SA: runner]  ◄── Dynamic package downloads
  ├── Task 3: build-container   [SA: runner]  ──► Needs builder authority
  └── Task 4: trivy-scan        [SA: runner]  ──► Needs scanner authority
```

--

### What Actually Happens During an Attack:
1. **Malicious PR / Typosquatted Dependency:** Injects code during `git-clone` or `fetch-deps`.
2. **Ambient Authority Exploitation:** The malicious code accesses the pod's ambient token or local identity socket.
3. **Identity Impersonation:** Because all tasks share `sa/runner`, the compromised step can exchange its token with Fulcio, Vault, or AWS STS.
4. **Forged Integrity:** The attacker signs an attestation claiming: *"Vulnerabilities: 0; SBOM: Clean"*.

--

<div class="warn-box">
  <strong>Takeaway:</strong> Cryptographic signatures are only as good as the authorization of the signer. Signature presence without role constraints is security theater.
</div>

???

Maia: "This isn't hypothetical. Most modern supply chain compromises don't break crypto; they abuse legitimate credentials running in the wrong context. If a dependency download step can sign a vulnerability report, your policy engine has no way to detect the forgery because the signature is mathematically valid and issued by your cluster."

---

## The Core Tenet: Authentication vs. Authorization

<span class="pill pill-blue">Maia · Identity & Auth</span>

SPIFFE's architectural boundary has always been clear:
* **SPIFFE does Authentication**: Cryptographically proves *who* a workload is.
* **Consuming Systems do Authorization**: Decides *what* that workload is allowed to do.

--

### How Do We Bridge the Gap in CI?

```text
[ Typical SPIFFE (Location) ]
spiffe://trust-domain/ns/{namespace}/sa/{service-account}
      │
      │  ❌ Does not capture what code is running or whether it was verified
      ▼
[ Role-Scoped SPIFFE (Verified Role) ]
spiffe://trust-domain/trusted/{cluster}/{sa}/{task-role}
      │
      │  ✅ Encodes the vetted task definition verified at admission time
      ▼
[ Policy Engine (Authorization) ]
Conforma / OPA evaluates: Is {task-role} authorized to sign this claim?
```

--

<div class="highlight-box">
  <strong>The Division of Labor:</strong><br>
  • <strong>Maia (Identity):</strong> How we make SPIFFE SVIDs express fine-grained task roles without changing SPIFFE's core tenets.<br>
  • <strong>Andrew (Implementation):</strong> How Tekton, Kyverno, Sigstore, and Conforma make this work end-to-end in Kubernetes.
</div>

???

Maia: "We don't need to reinvent SPIFFE or break its boundaries. We keep SPIFFE doing what it does best: authenticating the workload. But instead of only feeding SPIRE dumb metadata like namespace and service account, we feed SPIRE admission-verified task roles. Let's hand it over to Andrew to show how we wire this through Tekton, Kyverno, and Sigstore."

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
* **Pipeline-Scoped Identity (Working Today):** SVID identifies the whole verified release pipeline authority:
  `spiffe://konflux-ci.dev/release/{app}/{pipeline}`
  Issued *only* when Kyverno validates the pipeline run AND SPIRE matches the attachment step.
* **Policy Clearance Tokens (The Horizon):** `verify-conforma` mints an ephemeral capability token tied to `PipelineRun.UID` *only* when 100% of policy rules pass.
* The attachment task presents identity to Fulcio to sign the VSA keylessly into Rekor.

--

### Beyond Sigstore: Secretless, Environment-Agnostic Tasks
* **Zero Pre-Shared Secrets:** Tasks exchange SPIFFE JWTs with external services (Zot, HashiCorp Vault, AWS/GCP STS).
* **Portability:** Tasks run in *any* cluster or ephemeral cloud runner without copying Kubernetes Secrets across environments.
* **Registry Push Gating:** Zot validates OIDC Bearer tokens—the same release SVID that signs the VSA gates write access to the release repository.

???

Inside the build namespace, task-scoped identity enforces separation of duties. At the release boundary, we demonstrate Pipeline-Scoped Dual-Gating: early tasks get zero signing access, while the VSA attachment step receives a release authority SVID. Looking forward, capability clearance tokens make it physically impossible to sign without a cryptographic policy verdict.

Furthermore, this identity pattern is not limited to Sigstore signing. By leveraging SPIRE's OIDC discovery endpoint, tasks can exchange their SPIFFE identity with HashiCorp Vault, cloud IAM (AWS/GCP Workload Identity), or OCI registries like Zot. Tasks become completely secretless and portable across any Kubernetes cluster or cloud environment.

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
