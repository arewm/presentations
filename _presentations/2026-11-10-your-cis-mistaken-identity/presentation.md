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

Yet in nearly every Kubernetes CI/CD pipeline running today:

* One shared `ServiceAccount` runs every step in the pipeline.
* One ambient cloud credential or key signs SBOMs, scans, and release claims.
* A compromised dependency-fetch task inherits the **exact same authority** as build and release tasks.

<div class="warn-box" style="margin-top: 1.2em;">
  <strong>The Problem:</strong> Workload identities encode <em>location</em> (where something ran), not <em>authorization</em> (what it was permitted to do).
</div>

???

Speaker: Maia

Maia opens the talk.
"Think about what happens when a pipeline runs in Kubernetes. Tekton spawns a series of pods for tasks. All of them run in the same namespace, usually under the same service account. If you give that service account an IAM role or a Cosign key, any task that gets compromised can produce any attestation it wants."

---

layout: false

## The Identity Perspective: Why Location Fails Us

In the cloud-native identity world, we solved machine-to-machine authentication with **Workload Identity (SPIFFE/SPIRE)**.

We said: *"No more hardcoded API keys or static credentials in Kubernetes Secrets."*

### The Standard SPIFFE Deployment Model:
Workload Attestors inspect the running container:
* Kubernetes Namespace (`default-tenant`)
* ServiceAccount Name (`pipeline-runner`)
* Node or Cluster Name (`prod-cluster-01`)

```text
spiffe://company.org/ns/default-tenant/sa/pipeline-runner
```

???

Speaker: Maia

Maia: "From the identity community's perspective, SPIFFE was a huge leap forward. We eliminated static credentials. We gave workloads cryptographically verifiable identities based on kernel and kubelet attestation."

---

layout: false

## The Blind Spot: Ephemeral CI vs. Microservices

SPIFFE was designed with **long-running microservices** in mind:

* **Microservices Model:**
  * Predictable, homogeneous workloads (`service-a` talking to `service-b`).
  * The ServiceAccount boundary *is* the application boundary.
  * Location implies identity.

* **CI/CD Pipeline Reality:**
  * Ephemeral DAGs of wildly heterogeneous tools.
  * Untrusted PR checkouts, third-party package downloaders, compiler toolchains, scanners, and release signers all run under **one tenant identity**.

<div class="highlight-box" style="margin-top: 1em;">
  <strong>In CI/CD:</strong> ServiceAccount ≈ The entire factory. Location alone no longer tells you who is calling.
</div>

???

Speaker: Maia

Maia: "In a microservice, ServiceAccount ≈ Application. In CI/CD, ServiceAccount ≈ The entire factory. A single ServiceAccount represents everything from untrusted PR checkouts to production release signers. Location alone is not an authorization signal."

---

layout: false

## The Supply Chain Threat: Confused Deputies in CI

When identity is coarse, every pipeline step becomes a potential **Confused Deputy**:

```text
PipelineRun: build-and-test
  ├── Task 1: git-clone         [SA: runner]  ◄── Untrusted code / PRs
  ├── Task 2: fetch-deps        [SA: runner]  ◄── Dynamic package downloads
  ├── Task 3: build-container   [SA: runner]  ──► Needs builder authority
  └── Task 4: trivy-scan        [SA: runner]  ──► Needs scanner authority
```

* All four tasks share `sa/runner` in `default-tenant`.
* If Step 1 or Step 2 is compromised, it inherits the **full authority of Step 3 and Step 4**.

???

Speaker: Maia & Andrew

Maia: "This isn't hypothetical. Most modern supply chain compromises don't break crypto; they abuse legitimate credentials running in the wrong context."
Andrew: "When every task shares one identity, the least trusted step has the authority of the most trusted step."

---

layout: false

## Anatomy of an Attack: Ambient Authority Hijack

How an attacker exploits shared namespace credentials:

1. **Compromised Dependency / PR:** Attacker injects code during `git-clone` or `fetch-deps`.
2. **Ambient Credential Access:** Malicious script reads the mounted `regcred` secret or projected ServiceAccount token.
3. **Identity Impersonation:** Because all tasks share `sa/runner`, the compromised step possesses push and sign privileges.
4. **Forged Integrity:** Attacker overwrites production tags or signs false claims: *"0 vulnerabilities, clean SBOM"*.

<div class="warn-box" style="margin-top: 1em;">
  <strong>The Fundamental Gap:</strong> The Pod ran with ambient cluster authority. The cluster had no verification of what code was executing inside the container.
</div>

???

Speaker: Andrew

Andrew: "Let's stop talking in theory. Let's see what actually happens in a real Kubernetes cluster right now. I'll switch to our live terminal."

---

layout: false

## Live Demo: Act 1 — The Breakdown (Ambient Authority & Secret Hijack)

<div class="demo-slide-container" data-port="7681">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Act 1</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>Ambient Authority Flaw & Registry Tag Hijack</strong><br>
      • Projected ServiceAccount token exposes coarse namespace identity (<code>sub: system:serviceaccount:...</code>).<br>
      • Untrusted pod mounts ambient <code>regcred</code> and overwrites <code>slsa-e2e-test:latest</code> with a backdoor.<br>
      • Verification proves the tag was corrupted without triggering cluster authorization alarms.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 1</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code></span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Andrew runs Act 1 live in the embedded terminal.
Walk the audience through:
1. Inspecting the projected ServiceAccount token: issuer is Kubernetes, subject is coarse-grained to default-tenant:default.
2. Running rogue-ambient-push: pod mounts the namespace's regcred and uses oras to push a backdoor payload over slsa-e2e-test:latest.
3. Verification: pulls the tag back down and prints "[VERIFICATION] Tag contents: MALICIOUS BACKDOOR EXECUTED".
Hit Escape or click Next to return focus to the slide deck.

---

class: center, middle, inverse

# Part 2: Building Task Identity
## Tekton Resolvers, Admission Control, and SPIRE

???

Speaker: Andrew

Andrew transitions into Part 2:
"Now let's look at how Tekton primitives and Kubernetes admission control solve this identity dilemma."

---

layout: false

## Tekton Architecture: Tasks, TaskRuns, and Resolvers

How do pipelines execute in cloud-native Kubernetes?

* **`Task`**: Reusable definition containing container steps (commands, env vars, image).
* **`TaskRun`**: Execution instance that instantiates a Kubernetes `Pod` to run the steps.
* **`Pipeline` & `PipelineRun`**: Directed Acyclic Graph (DAG) orchestrating multiple TaskRuns.

### The Problem: Where Do Tasks Come From?
* Historically, tasks were pasted inline into YAML or installed cluster-wide.
* If developers write inline bash in `TaskRun.spec.taskSpec`, they can execute arbitrary, unvetted binaries.
* **Tekton Resolvers**: Remote, pluggable task resolution (`git`, `cluster`, and `bundles`).

???

Speaker: Andrew

Andrew explains Tekton primitives.
"To solve the identity problem, we have to know what code is scheduled before the pod starts running. Tekton Resolvers give us exactly that hook."

---

layout: false

## Tekton Resolvers: Pinned OCI Bundles

A **Tekton Bundle** is a Tekton `Task` packaged inside an OCI container image layer:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: demo-signed-task-
  namespace: default-tenant
spec:
  taskRef:
    resolver: bundles
    params:
    - name: bundle
      value: registry.kind/tekton-catalog/builder@sha256:ce7492...
    - name: name
      value: buildah-oci-ta
```

???

Speaker: Andrew

Andrew: "A Tekton Bundle packages the Task definition inside an OCI container image layer, pinned by an immutable SHA-256 digest."

---

layout: false

## Why OCI Bundles Change the Game

Treating task definitions as OCI artifacts unlocks three critical capabilities:

1. **Content-Addressable & Immutable**
   * Pinned by cryptographic digest (`@sha256:...`).
   * No silent drift or upstream tag mutation.

2. **Registry-Native & Cryptographically Signable**
   * Stored directly in existing container registries.
   * Signed with Cosign keys or Fulcio keyless certificates.

3. **Admission-Time Visibility**
   * When a TaskRun is submitted, `taskRef.params.bundle` is **immediately inspectable** by admission webhooks before any Pod is scheduled!

???

Speaker: Andrew

Andrew: "Because the bundle is an OCI artifact pinned by digest, we can treat task definitions the same way we treat container images: we can sign them with Cosign and verify them with Kyverno at admission time."

---

layout: false

## Kyverno at the Gate: Admission-Time Verification

Kyverno intercepts `TaskRun` admission using CEL `ImageValidatingPolicy`:

```yaml
apiVersion: policies.kyverno.io/v1beta1
kind: ImageValidatingPolicy
metadata:
  name: verify-bundle-signatures
spec:
  validationActions: [Deny]
  matchConstraints:
    resourceRules:
    - apiGroups: ["tekton.dev"]
      resources: ["taskruns"]
  images:
  - name: taskBundle
    expression: 'object.spec.taskRef.params.filter(p, p.name == "bundle").map(p, p.value)'
  validations:
  - expression: 'images.taskBundle.map(img, verifyImageSignatures(img, [attestors.catalogKey])).all(v, v > 0)'
```

???

Speaker: Andrew

Andrew: "Kyverno uses CEL-based image validation to check if the bundle digest referenced in the TaskRun is signed by the trusted catalog authority. If not signed, it is denied immediately."

---

layout: false

## Policy Enforcement: Dynamic Role Promotion

How admission policy categorizes tasks before execution:

* **Verified Signed Bundles**
  * Kyverno mutates the TaskRun label: `trusted-task-role: prod`.
* **Inline Scripts / Unsigned Bundles**
  * Kyverno restricts the label to: `trusted-task-role: dev`.
* **Anti-Spoofing Policy (`prevent-pod-label-spoofing`)**
  * Blocks pods from self-assigning or altering `trusted-task-role` labels.

<div class="highlight-box" style="margin-top: 1.2em;">
  <strong>Result:</strong> Pod labels reflect cryptographically verified admission state, immune to tenant pod tampering.
</div>

???

Speaker: Andrew

Andrew: "Notice the separation of concerns: Kyverno inspects the TaskRun before scheduling. If the bundle is signed by our trusted catalog key, Kyverno promotes the TaskRun label to 'prod'. An anti-spoofing policy ensures pods cannot self-assign this label."

---

layout: false

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

* SPIRE node agent attests the Pod against the Kubernetes API.
* Only Pods possessing the verified `trusted-task-role: "prod"` label receive the production SVID template.

???

Speaker: Andrew

Andrew: "Now SPIRE comes in. The ClusterSPIFFEID uses podSelector to match the Kyverno-verified label. If the pod has trusted-task-role: prod, SPIRE issues an SVID that includes the specific task role."

---

layout: false

## Cryptographic Task Roles in Practice

Three tasks sharing `sa/runner`, but minted distinct cryptographic identities:

```text
# Scanner Task (Verified Catalog Bundle)
spiffe://konflux-ci.dev/trusted/cluster-01/runner/trivy-sbom-scan

# Builder Task (Verified Catalog Bundle)
spiffe://konflux-ci.dev/trusted/cluster-01/runner/buildah-oci-ta

# Untrusted Task (Inline Script or Unsigned Bundle)
spiffe://konflux-ci.dev/dev/cluster-01/runner/arbitrary-script
```

<div class="highlight-box" style="margin-top: 0.8em;">
  <strong>Key Architectural Leap:</strong> All three tasks share <code>sa/runner</code>, but receive completely different cryptographic identities based on <em>admission-verified task code</em>!
</div>

???

Speaker: Andrew

Andrew: "Even though all three tasks share the exact same ServiceAccount, they no longer share the same cryptographic identity. The identity is bound to the verified catalog code."

---

layout: false

## Live Demo: Act 2 — Task Admission & Cryptographic Identity

<div class="demo-slide-container" data-port="7682">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Act 2</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>Task Admission Classification & SPIRE Identity Minting</strong><br>
      • Inline untrusted tasks are classified into the unprivileged <code>dev</code> role.<br>
      • Attacker attempting to spoof catalog namespace with unsigned task is denied at admission.<br>
      • Cosign-signed catalog bundle verified by Kyverno, promoted to <code>prod</code>, and minted production SVID.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 2</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code></span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Andrew runs Act 2 live:
1. Shows classify-taskrun and prevent-pod-label-spoofing policies.
2. Submits untrusted inline task: Kyverno sets trusted-task-role: dev, SPIRE mints spiffe://konflux-ci.dev/dev/...
3. Submits spoofed unsigned task: Kyverno's ImageValidatingPolicy blocks admission at the API boundary!
4. Submits Cosign-signed catalog task: Kyverno admits with trusted-task-role: prod, SPIRE mints vetted production SVID.
Hit Escape or click Next to return to slides.

---

class: center, middle, inverse

# Part 3: What This Unlocks
## Location vs. Authorization & Same-Namespace API Gating

???

Speaker: Maia

Maia introduces Part 3:
"Now let's examine what fine-grained task identities unlock within the pipeline namespace."

---

layout: false

## The Implications: Breaking the Location Trap

What did we just establish?

### 1. We Broke the "Location = Authorization" Trap
* In microservices, knowing `default-tenant:default` was enough because the service was single-purpose.
* In CI/CD, location alone is meaningless.
* We now have **cryptographic proof of what code is executing**, certified by admission control.

### 2. We Preserved SPIFFE's Core Tenets
* **SPIFFE does Authentication**: Cryptographically asserts *who* the workload is.
* **Consuming Systems do Authorization**: Decides *what* that workload is allowed to do.
* We didn't mutate SPIFFE—we fed SPIRE verified admission metadata!

<div class="highlight-box" style="margin-top: 1em;">
  <strong>The Principle:</strong> Authorization must follow <em>Role</em>, not <em>Location</em>.
</div>

???

Speaker: Maia

Maia reflects on the implications.
"This is the critical conceptual pivot. In the identity world, we always say: Authentication is identity; Authorization is policy. But if the identity only says 'Kubernetes Pod in Namespace X', downstream services have no signal to authorize. By feeding admission-verified task roles into the SPIFFE ID hierarchy, we give downstream services the exact signal they need."

---

layout: false

## Generalizing Within the Namespace: Three Core Patterns

Once tasks possess fine-grained cryptographic identities, how do we use them inside the tenant namespace?

<div style="display: flex; flex-direction: column; gap: 0.8em; margin-top: 1em;">
  <div class="highlight-box">
    <strong>Pattern 1: Federated OCI Push Gating</strong><br>
    Eliminate ambient registry secrets (<code>regcred</code>). Configure the OCI registry with OIDC Bearer auth matching SPIFFE SVIDs—only vetted builder tasks can initiate push sessions.
  </div>
  <div class="highlight-box">
    <strong>Pattern 2: Portable Secretless Service Access</strong><br>
    Internal microservices (CVE databases, KMS, artifact stores) validate caller SVIDs directly against SPIRE's <code>/keys</code> JWKS endpoint without mounting static Kubernetes Secrets.
  </div>
  <div class="highlight-box">
    <strong>Pattern 3: Separation of Duties Attestations</strong><br>
    Tasks sign in-toto claims via Sigstore/Fulcio. Policy engines (Conforma / OPA) verify that the certificate SAN matches the authorized role (scanners sign CVEs, builders sign SBOMs).
  </div>
</div>

???

Speaker: Maia

Maia outlines the three same-namespace patterns.
"We now have three immediate use cases inside the same namespace that completely eliminate ambient secrets."

---

layout: false

## Pattern 1: Federated OCI Push Gating

Zot OCI registry validates bearer JWTs against SPIRE's OIDC discovery endpoint (`/keys`):

```json
{
  "repositories": {
    "slsa-e2e-test": {
      "policies": [{
        "users": ["spiffe://konflux-ci.dev/trusted/cluster-01/runner/buildah-oci-ta"],
        "actions": ["read", "create"]
      }]
    }
  }
}
```

* **Dev / Attacker Task SVID** ➔ Rejected with **`HTTP 403 Forbidden`**.
* **Vetted Builder Task SVID** ➔ Accepted with **`HTTP 202 Accepted`**.
* **Zero ambient push tokens** stored in the tenant namespace.

???

Speaker: Andrew

Andrew explains Zot's access control policy: "Notice that we don't need dockerconfigjson secrets in the namespace anymore. Zot accepts the SPIFFE JWT as an OIDC bearer token and checks if the subject is the approved builder task."

---

layout: false

## Pattern 2: Portable Secretless Service Access

Internal cluster services authenticate callers using SPIRE JWTs directly:

* **Zero Static Secrets:** No API keys or database tokens mounted into pipeline pods.
* **Direct JWKS Validation:** Services validate bearer JWT signatures against SPIRE's `/keys` endpoint.
* **Role-Based Authorization:**
  * Only `runner/trivy-sbom-scan` is permitted to query the CVE vulnerability feed.
  * Inline tasks or unauthorized builders receive **`HTTP 403 Forbidden`**.

<div class="highlight-box" style="margin-top: 1.2em;">
  <strong>Benefit:</strong> Secrets cannot leak from compromised containers because the secrets simply do not exist in the tenant pod.
</div>

???

Speaker: Andrew & Maia

Andrew: "In Pattern 2, internal microservices like our CVE database validate caller JWTs directly against SPIRE's JWKS. No secrets exist in the pod for an attacker to steal."

---

layout: false

## Pattern 3: Scoped Attestations & Separation of Duties

Pipelines produce multiple in-toto attestations, each signed by a distinct role:

* **Builder Task (`buildah-oci-ta`):**
  * Authorized to sign container images and SBOMs (`https://spdx.dev/Document/v2.3`).
* **Scanner Task (`trivy-sbom-scan`):**
  * Authorized to sign vulnerability scans (`https://aquasecurity.github.io/trivy/report/v1`).

### The Threat:
What happens if a compromised build step generates a false vulnerability report claiming: *"Zero CVEs Found"*?

???

Speaker: Andrew

Andrew: "A classic pipeline weakness: if any task with a signing key can sign any claim, a compromised build step can forge a clean vulnerability report. That's why we need Separation of Duties."

---

layout: false

## Enforcing Separation of Duties with Conforma (OPA Rego)

Conforma verifies that the X.509 certificate SAN URI matches the authorized role:

```rego
package policy.cve

# Rule: Vulnerability reports MUST be signed by an authorized scanner
deny[msg] {
  attestation := input.attestations[_]
  attestation.predicateType == "https://aquasecurity.github.io/trivy/report/v1"
  
  not startswith(attestation.certificate.uri, 
                 "spiffe://konflux-ci.dev/trusted/cluster-01/runner/trivy-sbom-scan")
  
  msg := sprintf("CVE scan signed by unauthorized role: %s", [attestation.certificate.uri])
}
```

<div class="highlight-box" style="margin-top: 0.8em;">
  <strong>The Guarantee:</strong> Even if a builder signs a zero-CVE report, Conforma rejects it because the builder is not an authorized scanner!
</div>

???

Speaker: Andrew

Andrew: "Conforma evaluates the in-toto attestation against this Rego policy. It checks the certificate SAN URI. Even if the signature is mathematically valid, if it wasn't signed by trivy-sbom-scan, it's rejected."

---

layout: false

## Live Demo: Act 3 — Same-Namespace API Gating & Separation of Duties

<div class="demo-slide-container" data-port="7683">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Act 3</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>OCI Push Gating, Secretless Services & Separation of Duties</strong><br>
      • <strong>Zot OCI Push Gating:</strong> Rogue task rejected with <code>403 Forbidden</code>; vetted builder accepted with <code>202 Accepted</code>.<br>
      • <strong>Secretless CVE DB:</strong> Zero secrets in namespace; untrusted caller gets <code>403</code>; scanner gets <code>200 OK</code>.<br>
      • <strong>Separation of Duties:</strong> OPA tests prove builder forgery of scanner reports is blocked.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 3</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code></span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Andrew runs Act 3 live:
1. Zot push gating: rogue dev task attempts upload handshake -> 403 Forbidden. Vetted builder task attempts upload handshake -> 202 Accepted.
2. Secretless CVE database: dev task queries internal service -> 403 Forbidden. Scanner task queries internal service -> 200 OK with vulnerability feed.
3. Separation of duties: runs opa test proving builder forgery is blocked.
Hit Escape or click Next to return to slides.

---

class: center, middle, inverse

# Part 4: The Next Frontier
## Cross-Task Artifacts and the Managed Release Boundary

???

Speaker: Andrew & Maia

Andrew: "Now let's examine the boundaries that stretch beyond a single task: data plane isolation and cross-namespace release boundaries."

---

layout: false

## The Data Plane Loophole: Shared PersistentVolumes

Does securing task identities protect the pipeline? **Not if tasks share a disk.**

* Most Kubernetes CI pipelines share a `PersistentVolumeClaim` (PVC) across tasks.
* If a linter or test task executes on that shared volume, it can **tamper with compiled binaries on disk** before packaging!

```text
Task A (build) ──────► [ Shared PVC Workspace ] ◄────── Task B (untrusted test)
                             │
                             ▼ (tampered files)
                       Task C (package & sign) ──► Cryptographically valid MALWARE!
```

???

Speaker: Andrew

Andrew: "Identity on the control plane is useless if your data plane is compromised. If tasks share a PVC, any task can alter the binaries before they are packaged."

---

layout: false

## The Solution: OCI Trusted Artifacts

Replace shared mutable volumes with immutable OCI storage:

* **Digest-Pinned Storage:** Each task packages output artifacts into an OCI image layer and pushes it to the registry pinned by digest.
* **Hermetic Consumption:** Downstream tasks fetch strictly immutable digests, never shared mutable directories.
* **SLSA Build Level 3 Compliance:** Required to achieve tamper-resistant, isolated build environments.

<div class="highlight-box" style="margin-top: 1.2em;">
  <strong>Key Principle:</strong> Control plane identity (SPIRE) + Data plane immutability (OCI Trusted Artifacts) = End-to-End Pipeline Integrity.
</div>

???

Speaker: Andrew

Andrew: "Trusted Artifacts eliminate shared PVCs. Every task produces an immutable, digest-pinned artifact in the registry, ensuring tasks cannot tamper with each other's inputs or outputs."

---

layout: false

## The Managed Release Boundary

Build-time tasks in `default-tenant` must **never** possess release authority:

* **Tenant Namespaces (`default-tenant`):**
  * Untrusted developer code, compiler execution, unit tests, and vulnerability scans.
  * Can produce build provenance, but cannot trigger final release.

* **Managed Release Namespaces (`managed-tenant`):**
  * Isolated, hardened environment for enterprise release pipelines.
  * Governs final release gating, registry promotion, and signing.

### The Challenge:
How do downstream verifiers know an attestation was produced by an authorized **release pipeline**, not an arbitrary tenant pod?

???

Speaker: Maia & Andrew

Maia: "Build tasks should never have release authority. We separate tenant build namespaces from managed release namespaces."
Andrew: "And to prove an artifact passed the managed release gate, we use Dual-Gated Release Authority."

---

layout: false

## Model 2: Dual-Gated Release Authority

SPIRE issues the release SVID *only* upon the conjunction of two distinct gates:

1. **Gate 1 (PipelineRun Classification):**
   Kyverno validates the managed PipelineRun definition and labels:
   `trusted-pipeline-role: release-authority`
2. **Gate 2 (Task Selector Conjunction):**
   SPIRE matches both the pipeline label AND the specific task selector (`attach-summary-attestations`).

```text
spiffe://konflux-ci.dev/release/demo-app/slsa-e2e-release-dual-gated
```

* Signed keylessly with Cosign into Rekor; verified via the transparency log.

???

Speaker: Andrew

Andrew: "In the release namespace, we don't just ask if the task is attach-summary-attestations. We ask: is this task running inside an authorized, policy-governed release pipeline? Both conditions must be met simultaneously."

---

layout: false

## Live Demo: Act 4 — Dual-Gated Managed Release Authority

<div class="demo-slide-container" data-port="7684">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Act 4</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>Managed Release Boundary & Dual-Control Signing</strong><br>
      • Ambient ServiceAccount release authority is prohibited in <code>managed-tenant</code>.<br>
      • Dual-gating requires Kyverno PipelineRun validation AND SPIRE attachment task selector matching.<br>
      • Attaches Verification Summary Attestation (VSA) keylessly with Cosign into Rekor and verifies the transparency log.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 4</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code></span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Andrew runs Act 4 live:
1. Submits AppStudio Release CR in default-tenant referencing demo-app snapshot.
2. Watches managed-tenant release pipeline execute verify-conforma, push-snapshot, and attach-summary-attestations.
3. Shows Rekor query: extracts log entry, parses X.509 certificate SAN, verifies it matches spiffe://konflux-ci.dev/release/demo-app/...
Hit Escape or click Next to advance to conclusions.

---

layout: false

## Key Takeaways

1. **Location ≠ Authorization**: Stop treating Kubernetes namespaces and generic ServiceAccounts as authorization boundaries.
2. **Shift Verification to Admission**: Intercepting task bundles at admission with Kyverno prevents untrusted code from ever gaining production identities.
3. **Task-Scoped Identity is Real Today**: Combining Tekton, Kyverno, SPIFFE/SPIRE, and Sigstore brings least-privilege cryptographic identity to every CI step.
4. **Policy Closes the Loop**: In-toto attestations signed by role-scoped SVIDs allow policy engines like Conforma to verify *who was authorized to make each claim*.

<div class="highlight-box" style="text-align: center; margin-top: 1.5em;">
  <strong>Working Code & Helm Charts:</strong><br>
  <code>github.com/arewm/slsa-konflux-example</code><br>
  (Branch: <code>kubecon-na-2026-your-cis-mistaken-identity</code>)
</div>

???

Speaker: Maia & Andrew

Maia and Andrew deliver the closing thoughts.
Maia: "Workload identity is evolving. By bringing admission control and task resolvers together, we can bring zero-trust principles directly to CI/CD."
Andrew: "Everything we showed today runs in our open-source repo on Kind."

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

???

Speaker: Maia & Andrew

Open the floor for questions from the audience.

---

layout: false

## Appendix: Full End-to-End Demonstration Arc

<div class="demo-slide-container" data-port="7680">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Complete Arc</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>Complete Walkthrough (Acts 0 through 4)</strong><br>
      Runs the entire end-to-end demonstration arc from pre-flight cluster baseline through ambient breakdown, Kyverno admission, same-namespace API gating, and dual-gated release authority.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code></span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Full uninterrupted demonstration arc from pre-flight baseline to final Rekor verification.
