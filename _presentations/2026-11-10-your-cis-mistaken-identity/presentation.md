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

<span class="pill pill-blue">Maia · Identity & Auth</span>

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

<span class="pill pill-purple">Maia & Andrew</span>

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
2. **Ambient Authority Exploitation:** The malicious code accesses the pod's ambient token (`regcred` or projected SA token).
3. **Identity Impersonation:** Because all tasks share `sa/runner`, the compromised step can overwrite registry tags or sign false claims.
4. **Forged Integrity:** The attacker pushes backdoored images or signs an attestation claiming: *"Vulnerabilities: 0; SBOM: Clean"*.

--

<div class="warn-box">
  <strong>Andrew:</strong> Let's stop talking in theory. Let's see what actually happens in a real Kubernetes cluster right now.
</div>

???

Maia: "This isn't hypothetical. Most modern supply chain compromises don't break crypto; they abuse legitimate credentials running in the wrong context."
Andrew: "Let's pull up our live cluster and demonstrate how an untrusted step silently hijacks ambient authority to overwrite a production container tag."

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
      • Standard projected ServiceAccount token exposes namespace-wide ambient identity (<code>sub: system:serviceaccount:...</code>).<br>
      • An untrusted pod mounts ambient <code>regcred</code> credentials and silently overwrites <code>slsa-e2e-test:latest</code> with a backdoor payload.<br>
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

---

layout: false

## Tekton Architecture: Tasks, TaskRuns, and Resolvers

<span class="pill pill-red">Andrew · Pipelines & Architecture</span>

How do pipelines execute in cloud-native Kubernetes?

--

### The Tekton Execution Hierarchy:
* **`Task`**: Reusable definition containing steps (container images, commands, env vars).
* **`TaskRun`**: Execution instance that instantiates a Kubernetes `Pod` to run the steps.
* **`Pipeline` & `PipelineRun`**: Directed Acyclic Graph (DAG) orchestrating multiple TaskRuns.

--

### The Problem: Where Do Tasks Come From?
* Historically, tasks were pasted inline into YAML or installed cluster-wide.
* If developers can write inline bash in `TaskRun.spec.taskSpec`, they can execute arbitrary, unvetted binaries.
* **Tekton Resolvers**: Introduced remote, pluggable task resolution:
  - `git` resolver: Pulls tasks from Git repositories.
  - `cluster` resolver: Pulls tasks from cluster namespaces.
  - **`bundles` (OCI) resolver**: Pulls tasks packaged as immutable OCI artifacts!

???

Andrew explains Tekton primitives.
"To solve the identity problem, we have to know what code is scheduled before the pod starts running. Tekton Resolvers give us exactly that hook."

---

## Tekton Resolvers: Pinned OCI Bundles as Trust Anchors

<span class="pill pill-red">Andrew · Pipelines & Architecture</span>

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
      value: registry-service.kind-registry/tekton-catalog/demo-catalog-task@sha256:ce7492...
    - name: name
      value: demo-catalog-task
    - name: kind
      value: task
```

--

### Why This Changes the Game:
1. **Content-Addressable & Immutable**: Pinned by cryptographic digest (`@sha256:...`).
2. **Registry-Native**: Stored alongside application images; supports Sigstore signatures.
3. **Admission-Time Visibility**: When a TaskRun is submitted to the Kubernetes API, `taskRef.params.bundle` is **immediately inspectable** before any Pod is scheduled!

???

Andrew: "Because the bundle is an OCI artifact pinned by digest, we can treat task definitions the same way we treat container images: we can sign them with Cosign and verify them with Kyverno at admission time."

---

## Bridging Tekton to SPIRE: Kyverno at the Gate

<span class="pill pill-red">Andrew · Pipelines & Architecture</span>

Kyverno intercepts the `TaskRun` at admission time using a CEL-based `ImageValidatingPolicy`:

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
    expression: >-
      object.spec.taskRef.params
        .filter(p, p.name == "bundle")
        .map(p, p.value)
  validations:
  - expression: >-
      images.taskBundle.map(img,
        verifyImageSignatures(img, [attestors.catalogKey])
      ).all(valid, valid > 0)
```

--

### The Trust Promotion:
* **Verified signed catalog bundles** ➔ Kyverno stamps `trusted-task-role: prod`.
* **Inline or unpinned scripts** ➔ Kyverno restricts to `trusted-task-role: dev`.
* **Anti-Spoofing Policy (`prevent-pod-label-spoofing`)** ➔ Blocks pods from forging labels.

???

Andrew: "Notice what's happening here. Kyverno inspects the TaskRun before scheduling. If the bundle is signed by our trusted catalog key, Kyverno promotes the TaskRun label to 'prod'. An anti-spoofing policy ensures pods cannot self-assign this label."

---

## Step 2: SPIRE Mints the Role SVID

<span class="pill pill-red">Andrew · Pipelines & Architecture</span>

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

### The Resulting Distinct Identities:
* **Scanner Task:**
  `spiffe://konflux-ci.dev/trusted/cluster-01/runner/trivy-sbom-scan`
* **Builder Task:**
  `spiffe://konflux-ci.dev/trusted/cluster-01/runner/buildah-oci-ta`
* **Untrusted / Inline Task:**
  `spiffe://konflux-ci.dev/dev/cluster-01/runner/arbitrary-script`

--

<div class="highlight-box">
  <strong>Key Architectural Leap:</strong> All three tasks share <code>sa/runner</code>, but receive completely different cryptographic identities based on <em>admission-verified task code</em>!
</div>

???

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

---

layout: false

## The Implications: Cryptographic Proof of Code, Not Just Location

<span class="pill pill-blue">Maia · Identity & Auth</span>

What did we just establish?

--

### 1. We Broke the "Location = Authorization" Trap
* In microservices, knowing `default-tenant:default` was enough because the service was single-purpose.
* In CI/CD, location alone is meaningless.
* We now have **cryptographic proof of what code is executing**, certified by admission control.

--

### 2. We Preserved SPIFFE's Core Tenets
* **SPIFFE does Authentication**: Cryptographically asserts *who* the workload is.
* **Consuming Systems do Authorization**: Decides *what* that workload is allowed to do.
* We didn't mutate SPIFFE or invent custom protocols—we fed SPIRE verified admission metadata!

--

<div class="highlight-box">
  <strong>The Principle:</strong> Authorization must follow <em>Role</em>, not <em>Location</em>.
</div>

???

Maia reflects on the implications.
"This is the critical conceptual pivot. In the identity world, we always say: Authentication is identity; Authorization is policy. But if the identity only says 'Kubernetes Pod in Namespace X', downstream services have no signal to authorize. By feeding admission-verified task roles into the SPIFFE ID hierarchy, we give downstream services the exact signal they need."

---

## Generalizing Within the Namespace: Three Core Patterns

<span class="pill pill-blue">Maia · Identity & Auth</span>

Once tasks possess fine-grained cryptographic identities, how do we use them inside the tenant namespace?

--

<div style="display: flex; flex-direction: column; gap: 0.9em; margin-top: 1em;">
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

Maia outlines the three same-namespace patterns.
"We now have three immediate use cases inside the same namespace that completely eliminate ambient secrets."

---

## Patterns 1 & 2: Push Gating and Secretless Services

<span class="pill pill-purple">Maia & Andrew</span>

### Pattern 1: Zot OCI Push Gating
Zot validates bearer JWTs against SPIRE's OIDC discovery endpoint (`/keys`):
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
* **Dev/Attacker task SVID** ➔ Rejected with **`HTTP 403 Forbidden`**.
* **Vetted Builder SVID** ➔ Accepted with **`HTTP 202 Accepted`**.

--

### Pattern 2: Secretless Internal CVE Database
* Microservice mounts **zero** Kubernetes Secrets.
* Service validates caller JWT signature and subject: only `trivy-sbom-scan` can access the vulnerability feed.

???

Andrew explains Zot's access control policy: "Notice that we don't need dockerconfigjson secrets in the namespace anymore. Zot accepts the SPIFFE JWT as an OIDC bearer token and checks if the subject is the approved builder task."

---

## Pattern 3: Scoped Attestations & Separation of Duties

<span class="pill pill-red">Andrew · Pipelines & Architecture</span>

Each task produces attestations matching its specific domain:

* **Builder Task (`buildah-oci-ta`):** Signs SBOM (`https://spdx.dev/Document/v2.3`)
* **Scanner Task (`trivy-sbom-scan`):** Signs CVE report (`https://aquasecurity.github.io/trivy/report/v1`)

--

### Conforma Policy Enforcement (OPA Rego):
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

Andrew: "This is the separation of duties punchline. A signature from the cluster isn't enough. Conforma verifies that the certificate identity matches the role authorized to make that claim."

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

Andrew runs Act 3 live:
1. Zot push gating: rogue dev task attempts upload handshake -> 403 Forbidden. Vetted builder task attempts upload handshake -> 202 Accepted.
2. Secretless CVE database: dev task queries internal service -> 403 Forbidden. Scanner task queries internal service -> 200 OK with vulnerability feed.
3. Separation of duties: runs opa test proving builder forgery is blocked.
Hit Escape or click Next to return to slides.

---

class: center, middle, inverse

# Part 4: The Next Frontier
## Cross-Task Artifacts and the Managed Release Boundary

---

layout: false

## Cross-Task Data Plane: Why PVCs Undermine Task Trust

<span class="pill pill-red">Andrew · Pipelines & Architecture</span>

Does securing task identities protect the entire pipeline? **Not if tasks share a disk.**

--

### The Data Plane Loophole: Shared PersistentVolumes
* Most CI pipelines share a `PersistentVolumeClaim` (PVC) across tasks in a PipelineRun.
* `git-clone` writes source $ightarrow$ `build` compiles binary $ightarrow$ `package` builds container.
* If a linter or test task executes on that shared volume, it can **tamper with compiled binaries on disk** before packaging!

```text
Task A (build) ──────► [ Shared PVC Workspace ] ◄────── Task B (untrusted test)
                             │
                             ▼ (tampered files)
                       Task C (package & sign) ──► Cryptographically valid MALWARE!
```

--

### The Solution: OCI Trusted Artifacts
* Content-addressable, immutable storage in the registry.
* Each task produces a digest-pinned artifact; subsequent tasks fetch only immutable digests.
* Required for **SLSA Build Level 3** (tamper-resistant isolated workspaces).

???

Andrew: "Identity on the control plane is useless if your data plane is compromised. If tasks share a PVC, any task can alter the binaries before they are packaged. Trusted Artifacts replace shared PVCs with immutable OCI storage."

---

## The Managed Release Boundary: Dual-Gated Release Authority

<span class="pill pill-purple">Maia & Andrew</span>

Build-time tasks in `default-tenant` must **never** possess release authority.

--

### The Release Separation:
* Build and test happen in untrusted tenant namespaces.
* Final promotion and release execute in a hardened, managed namespace (`managed-tenant`).

--

### Model 2 Dual-Gated Release Authority:
Downstream consumers verifying a **Verification Summary Attestation (VSA)** need proof that the entire release pipeline was governed:

1. **Gate 1 (PipelineRun Classification):** Kyverno validates the managed PipelineRun definition and mutates:
   `trusted-pipeline-role: release-authority`
2. **Gate 2 (Task Selector Conjunction):** SPIRE issues the release SVID *only* if both the pipeline label AND the specific task selector (`attach-summary-attestations`) match!

```text
spiffe://konflux-ci.dev/release/demo-app/slsa-e2e-release-dual-gated
```

* Signed keylessly with Cosign into Rekor; verified via the transparency log.

???

Maia and Andrew explain dual-gating:
"In the release namespace, we don't just ask if the task is attach-summary-attestations. We ask: is this task running inside an authorized, policy-governed release pipeline? Both conditions must be met simultaneously."

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

Andrew runs Act 4 live:
1. Submits AppStudio Release CR in default-tenant referencing demo-app snapshot.
2. Watches managed-tenant release pipeline execute verify-conforma, push-snapshot, and attach-summary-attestations.
3. Shows Rekor query: extracts log entry, parses X.509 certificate SAN, verifies it matches spiffe://konflux-ci.dev/release/demo-app/...
Hit Escape or click Next to advance to conclusions.

---

## Key Takeaways

<span class="pill pill-purple">Maia & Andrew</span>

1. **Location ≠ Authorization**: Stop treating Kubernetes namespaces and generic ServiceAccounts as authorization boundaries.
2. **Shift Verification to Admission**: Intercepting task bundles at admission with Kyverno prevents untrusted code from ever gaining production identities.
3. **Task-Scoped Identity is Real Today**: Combining Tekton, Kyverno, SPIFFE/SPIRE, and Sigstore brings least-privilege cryptographic identity to every CI step.
4. **Policy Closes the Loop**: In-toto attestations signed by role-scoped SVIDs allow policy engines like Conforma to verify *who was authorized to make each claim*.

--

<div class="highlight-box" style="text-align: center; margin-top: 1.5em;">
  <strong>Working Code & Helm Charts:</strong><br>
  <code>github.com/arewm/slsa-konflux-example</code><br>
  (Branch: <code>kubecon-na-2026-your-cis-mistaken-identity</code>)
</div>

???

Maia and Andrew deliver the closing thoughts.

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

Full uninterrupted demonstration arc from pre-flight baseline to final Rekor verification.
