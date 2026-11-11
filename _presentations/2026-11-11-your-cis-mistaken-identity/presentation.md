name: inverse
layout: true
class: center, middle, inverse

---

class: center, middle, title-slide

# Your CI's Mistaken Identity

## Task-Scoped Trust in Cloud-Native Pipelines

Andrew McNamara (Red Hat) • Maia Iyer (IBM Research)

<div style="margin-top: 2em; display: flex; justify-content: center; align-items: center; gap: 2.2em;">
  <img src="/shared/logos/tekton.png" width="90" alt="Tekton logo">
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <img src="/shared/logos/intoto-icon.svg" width="90" alt="in-toto logo">
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <img src="img/spiffe-icon-color.svg" width="100" alt="SPIFFE/SPIRE logo">
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <img src="img/kyverno-icon-color.svg" width="100" alt="Kyverno logo">
  <span style="font-size: 2em; color: #94a3b8;">+</span>
  <img src="img/sigstore-icon-white.svg" width="90" alt="Sigstore logo">
</div>

.footnote[
  KubeCon + CloudNativeCon North America · November 11, 2026
]

???

Andrew and Maia introduce themselves.
Andrew: "I'm Andrew McNamara — SLSA maintainer, Konflux/Tekton contributor."
Maia: "I'm Maia Iyer from IBM Research, SPIFFE maintainer and Tornjak contributor."
Andrew: "Today: why workload identity in CI/CD has an identity crisis."

---

layout: false

## A Simple Question

> **"You wouldn't ask a plumber to sign off on your electrical work."**

Yet in nearly every Kubernetes CI/CD pipeline running today:

* One shared `ServiceAccount` runs every step in the pipeline.
* One ambient cloud credential or key signs SBOMs, scans, and release claims.
* A compromised dependency-fetch task inherits the **exact same authority** as build and release tasks.

<div class="warn-box" style="margin-top: 1.2em;">
  <strong>The Problem:</strong> Workload identity is only as granular as you configure it. In most CI/CD deployments it's configured around <em>location</em> (namespace + ServiceAccount) rather than <em>role</em> (what the workload actually is)... leaving downstream services to infer authority from a signal that doesn't carry it.
</div>

???

Speaker: Maia

Maia opens the talk.
"Think about what happens when a pipeline runs in Kubernetes. Tekton spawns a series of pods for tasks. All of them run in the same namespace, usually under the same service account. If you give that service account an IAM role or a Cosign key, any task that gets compromised can produce any attestation it wants."

---

layout: false

## From Standard Identities to Task-Scoped Trust

<div style="display: flex; flex-direction: column; gap: 0.8em; margin-top: 1.2em;">
  <div class="highlight-box">
    <strong>Part 1:</strong> Where standard practice falls short <em>(+ demo)</em>
  </div>
  <div class="highlight-box">
    <strong>Part 2:</strong> Generating task-scoped identities <em>(+ demo)</em>
  </div>
  <div class="highlight-box">
    <strong>Part 3:</strong> What task identities unlock
  </div>
  <div class="highlight-box">
    <strong>Part 4:</strong> The next frontier
  </div>
</div>

???

Speaker: Maia

Maia: "Here's the roadmap. In Part 1 we show where standard practice breaks down for CI, with a demo of
the attack it enables. In Part 2 we build task-scoped identities and demo admission-time verification.
Part 3 shows what those identities unlock once you have them, and Part 4 looks at where this is headed.
Every piece you see is in the repo."

---

layout: false

## A Quick SPIFFE Primer

```text
   ┌────────────┐    1. request for SVID         ┌──────────────┐    public trust bundle
   │            │ ─────────────────────────────► │              │ ───────────────────────●
   │    Pod     │                                │    SPIFFE    │
   │  (your     │    3. SVID (x509 cert / JWT    │  local agent │
   │  workload) │ ◄──── carrying a SPIFFE ID)─── │  on the node │
   │            │                                │              │
   └─────▲──────┘                                └──────┬───────┘
         │                                              │
         │                             2. out-of-band   │
         │                                attestation   ▼
         │                                       ┌──────────────┐
         └────────────────────────────────────── │   kubelet    │
                                                 │  on the node │
                                                 └──────────────┘

   Example SPIFFE ID:  spiffe://konflux-ci.dev/trusted/kind-konflux/default/buildah-oci-ta
```

???

Speaker: Maia

Maia: "Quick primer before we go deeper. SPIFFE gives workloads a cryptographic identity with no static credential mounted into the pod. The pod asks a local agent for an SVID over a Unix socket. Out-of-band, the agent attests the caller — on Kubernetes it takes the caller's PID and asks the local kubelet which pod that process belongs to, which gives it the namespace, ServiceAccount, labels, and image. From that, it decides which SPIFFE ID this pod is entitled to and returns an SVID: an X.509 cert or a JWT that carries that SPIFFE ID. The ID itself is a URI-shaped name; treat the path as opaque. What makes it trustworthy is the attestation that bound it to this specific pod — not anything you can read off the path. Hold onto that: attestation inputs are the lever we're going to pull later in the talk."

---

layout: false

## Why the Standard Deployment Model Fails Us

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

Maia: "From the identity community's perspective, SPIFFE was a huge leap forward. We eliminated static credentials. We gave workloads cryptographically verifiable identities based on kernel and kubelet attestation. SPIFFE itself lets you encode whatever identity you need — but the deployment patterns the community defaulted to lean on namespace and ServiceAccount, and that configuration choice is what collapses in CI/CD."

---

layout: false

## Ephemeral CI vs. Microservices

SPIFFE was designed with **long-running microservices** in mind:

* **Microservices Model:**
  * Predictable, homogeneous workloads (`service-a` talking to `service-b`).
  * The ServiceAccount boundary *is* the application boundary.
  * Location implies identity.

* **CI/CD Pipeline Reality:**
  * Ephemeral DAGs of wildly heterogeneous tools.
  * Anyone who can add a task to the pipeline — one PR away — runs with **one tenant identity**: the PR checkout, the dependency downloader, the compiler toolchain, the scanner, the release signer, and whatever a compromised PR injects beside them.

<div class="highlight-box" style="margin-top: 1em;">
  <strong>In CI/CD:</strong> ServiceAccount ≈ The entire factory. Location alone no longer tells you who is calling.
</div>

???

Speaker: Maia

In CI/CD, where we are concerned with not just one but a whole factory of pods, being able to distinguish among those pods is key to enforcing least privilege and mitigating risk upon compromise of one pod.

---

layout: false

## Confused Deputies in CI

When identity is coarse, every pipeline step becomes a potential **Confused Deputy**:

```text
PipelineRun: build-and-test
  ├── Task 1: git-clone         [SA: runner]  ◄── PR-controlled
  ├── Task 2: fetch-deps        [SA: runner]  ◄── Dynamic package downloads
  ├── Task 3: build-container   [SA: runner]  ──► Needs builder authority
  ├── Task 4: registry-mirror   [SA: runner]  ◄── INJECTED by a compromised PR
  └── Task 5: trivy-scan        [SA: runner]  ──► Needs scanner authority
```

* All five tasks share `sa/runner` in `default-tenant`.
* The pipeline definition is **PR-controlled** — a compromised PR doesn't need to exploit a step, it simply *adds one*: plausible-looking, same ServiceAccount, indistinguishable from real work, with the full authority of every other task.
* Provenance + policy verification catches a forged *artifact*... but the hijacked step's authority abuse (secrets, tag pushes, service access) happens outside the provenance channel, before any verifier sees it.

???

Speaker: Maia & Andrew

Maia: "This isn't hypothetical. Most modern supply chain compromises don't break crypto; they abuse legitimate credentials running in the wrong context."
Andrew: "When every task shares one identity, the least trusted step has the authority of the most trusted step."
Andrew (if asked about provenance): "Full PipelineRun provenance plus policy verification catches a forged artifact at the consumer... but that's a consumption-side control, and it only works if every consumer verifies every time. Task identity is generation-side — the rogue step never holds the authority in the first place. They compose."

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
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code> &middot; No demo terminal? Run locally: <code>git clone github.com/arewm/slsa-konflux-example</code> (branch <code>kubecon-na-2026-your-cis-mistaken-identity</code>), then the same command — see <code>demo/README.md</code></span>
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

Andrew starts Part 2:
"So how do we fix this? Tekton primitives plus Kubernetes admission control."

---

layout: false

## Tekton Architecture: Tasks, TaskRuns, and Resolvers

How do pipelines execute in cloud-native Kubernetes?

* **`Task`**: Reusable definition containing container steps (commands, env vars, image).
* **`TaskRun`**: Execution instance that instantiates a Kubernetes `Pod` to run the steps.
* **`Pipeline` & `PipelineRun`**: Directed Acyclic Graph (DAG) orchestrating multiple TaskRuns.

```text
TaskRun ──creates──► Pod        (labeled tekton.dev/task)
  Step  ──maps───►  Container  (image + command defined by the Task)
```

### The Problem: Where Do Tasks Come From?
* Historically, tasks were pasted inline into YAML or installed cluster-wide.
* If developers write inline bash in `TaskRun.spec.taskSpec`, they can execute arbitrary, unvetted binaries.
* **Tekton Resolvers**: Remote, pluggable task resolution (`git`, `cluster`, and `bundles`).

???

Speaker: Andrew

Andrew: "To fix identity we need to know what code runs before the pod starts. Tekton Resolvers give us that hook."

---

layout: false

## Tekton Resolvers: Pinned OCI Bundles

A **Tekton Bundle** is a Tekton `Task` packaged inside an OCI container image layer:

* The bundle pins the **exact container images, commands, and scripts** each step will run — verifying the bundle verifies the code **before any Pod is scheduled**.

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

Task definitions become verifiable *before execution*:

1. **Immutable by Digest**
   * A TaskRun pins the exact task definition (`@sha256:...`).
   * The cluster knows *precisely what code will run* — no tag drift, no silent mutation.

2. **Signable like any OCI Artifact**
   * Stored in existing registries, signed with Cosign / Fulcio keyless.
   * "Trusted catalog" = a signing key, not a curated source.

3. **Visible at Admission — Before Any Pod Exists**
   * `taskRef.params.bundle` is inspectable by webhooks the moment the TaskRun is submitted.
   * Verify signature → classify role → *then* the Pod is created. Unverified code never receives a **trusted** identity — it runs, but identified only as what it was verified to be.

???

Speaker: Andrew

Andrew: "Because the bundle is an OCI artifact pinned by digest, task definitions work like container images: sign them with Cosign, verify with Kyverno at admission."

---

layout: false

## Kyverno at the Gate: Admission-Time Verification

When a `TaskRun` is submitted, Kyverno intercepts it **before any Pod is scheduled**. The policy works in the same order you will see in the live demo — scope first, then the checks, then the outcome:

1. **Scope** — the policy only *fires* for TaskRuns referencing a bundle from the trusted catalog paths (resolver param or direct `taskRef.bundle`). Everything else never reaches these checks — and can never be promoted either.
2. **Pin** — every in-scope bundle must be `@sha256:` digest-pinned. Floating tags can never be trusted.
3. **Sign** — every in-scope bundle must carry a valid Cosign signature from the trusted catalog key.
4. **Outcome** — failing either check **denies the whole TaskRun at admission**: no TaskRun, no Pod, nothing scheduled. Out-of-scope tasks (inline scripts, git tasks, unknown registries) are *not blocked* — they just **never get promoted**.

<div class="highlight-box" style="margin-top: 0.6em;">
  <strong>Scope → Pin → Sign → Outcome:</strong> the path pattern is the trust grant; the pin and signature
  are mandatory for <em>every</em> bundle on that path.
</div>

???

Speaker: Andrew

Andrew: "Kyverno uses CEL image validation to check the bundle digest referenced in the TaskRun is signed by the trusted catalog key. Not signed? Denied on the spot."

---

layout: false

## Policy Enforcement: Dynamic Role Promotion

How admission policy categorizes tasks before execution:

* **Dev by default** — every TaskRun is labeled `trusted-task-role: dev`; trust is opt-in, never assumed.
* **Prod is earned** — digest-pinned, signed catalog bundles are promoted to `prod` at admission.
* **Labels are locked** — pods cannot self-assign the label, and it is immutable once stamped.

<div class="highlight-box" style="margin-top: 1.2em;">
  <strong>Result:</strong> identity follows cryptographically verified provenance — re-checked fail-closed on every write.
</div>

???

Speaker: Andrew

Andrew: "Note the separation of concerns: Kyverno inspects the TaskRun before scheduling. If the bundle is signed by our catalog key, Kyverno promotes the label to 'prod'. An anti-spoofing policy keeps pods from grabbing the label themselves."

---

layout: false

## Step 2: SPIRE Mints the Role SVID

*(SVID: SPIFFE Verifiable Identity Document — the cryptographically verifiable
credential SPIRE issues to a workload.)*

`ClusterSPIFFEID` evaluates the Kyverno-verified pod labels:

```yaml
apiVersion: spire.spiffe.io/v1alpha1
kind: ClusterSPIFFEID
metadata:
  name: konflux-trusted-prod
spec:
  spiffeIDTemplate: >-
    spiffe://konflux-ci.dev/trusted/kind-konflux/
    {{ .PodSpec.ServiceAccountName }}/
    {{ index .PodMeta.Labels "tekton.dev/task" }}
  podSelector:
    matchLabels:
      trusted-task-role: "prod"
```

* SPIRE node agent attests the Pod against the Kubernetes API.
* Only Pods possessing the verified `trusted-task-role: "prod"` label receive the production SVID template.

???

Speaker: Andrew

Andrew: "Now SPIRE. The ClusterSPIFFEID uses a podSelector to match the Kyverno-verified label. Pod has trusted-task-role: prod? SPIRE issues an SVID that includes the specific task role."

---

layout: false

## Cryptographic Task Roles in Practice

Three tasks sharing `sa/default`, but minted distinct cryptographic identities:

```text
# Scanner Task (Verified Catalog Bundle)
spiffe://konflux-ci.dev/trusted/kind-konflux/default/trivy-sbom-scan

# Builder Task (Verified Catalog Bundle)
spiffe://konflux-ci.dev/trusted/kind-konflux/default/buildah-oci-ta

# Untrusted Task (Inline Script or Unsigned Bundle)
spiffe://konflux-ci.dev/dev/kind-konflux/default/arbitrary-script
```

<div class="highlight-box" style="margin-top: 0.8em;">
  <strong>Key Architectural Leap:</strong> All three tasks share <code>sa/default</code>, but receive completely different cryptographic identities based on <em>admission-verified task code</em>!
</div>

???

Speaker: Andrew

Andrew: "All three tasks share the exact same ServiceAccount... but not the same cryptographic identity. The identity is bound to the verified catalog code."

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
      • Inline untrusted tasks are classified into the unprivileged <code>dev</code> role — trust is earned from the task's bundle, never claimed.<br>
      • The catalog path pattern is the trust grant: <code>tekton-catalog/*</code> + digest pin ⇒ eligible for <code>prod</code>.<br>
      • Signature verification (Kyverno ImageValidatingPolicy) is mandatory for <em>every</em> bundle from that path — an unsigned spoof is denied admission outright, not just downgraded.<br>
      • Cosign-signed catalog bundle verified, promoted to <code>prod</code>, and minted a production SVID.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 2</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code> &middot; No demo terminal? Run locally: <code>git clone github.com/arewm/slsa-konflux-example</code> (branch <code>kubecon-na-2026-your-cis-mistaken-identity</code>), then the same command — see <code>demo/README.md</code></span>
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

Maia starts Part 3:
"So what do fine-grained task identities get you inside the pipeline namespace?"

---

layout: false

## Breaking the Location Trap

So what did we actually get?

### 1. We Broke the "Location = Authorization" Trap
* In microservices, knowing `default-tenant:default` was enough because the service was single-purpose.
* In CI/CD, location alone is meaningless.
* We now have **cryptographic proof of what code is executing**, certified by admission control.

### 2. We Preserved SPIFFE's Core Tenets
* **SPIFFE does Authentication**: Cryptographically asserts *who* the workload is.
* **Consuming Systems do Authorization**: Decides *what* that workload is allowed to do.
* We didn't change SPIFFE... we just fed SPIRE verified admission metadata.

<div class="highlight-box" style="margin-top: 1em;">
  <strong>The Principle:</strong> Authorization must follow <em>Role</em>, not <em>Location</em>.
</div>

???

Speaker: Maia

Maia: "This is the conceptual pivot. In the identity world we always say: authentication is identity, authorization is policy. But if the identity only says 'Kubernetes Pod in Namespace X', downstream services have no signal to authorize against. Feeding admission-verified task roles into the SPIFFE ID hierarchy gives them the signal they need."

---

layout: false

## Generalizing Within the Namespace: Three Core Patterns

Once tasks have fine-grained cryptographic identities, how do we use them inside the tenant namespace?

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
"We now have three immediate use cases inside the same namespace that eliminate ambient secrets for these flows."

---

layout: false

## Pattern 1: Federated OCI Push Gating

Zot OCI registry validates bearer JWTs against SPIRE's OIDC discovery endpoint (`/keys`):

```json
{
  "repositories": {
    "slsa-e2e-test": {
      "policies": [{
        "users": ["spiffe://konflux-ci.dev/trusted/kind-konflux/default/buildah-oci-ta"],
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

Andrew: "Notice we don't need dockerconfigjson secrets in the namespace anymore. Zot takes the SPIFFE JWT as an OIDC bearer token and checks the subject is the approved builder task."

---

layout: false

## Pattern 2: Portable Secretless Service Access

Internal cluster services authenticate callers using SPIRE JWTs directly:

* **Zero Static Secrets:** No API keys or database tokens mounted into pipeline pods.
* **Direct JWKS Validation:** Services validate bearer JWT signatures against SPIRE's `/keys` endpoint.
* **Role-Based Authorization:**
  * Only `default/trivy-sbom-scan` is permitted to query the CVE vulnerability feed.
  * Inline tasks or unauthorized builders receive **`HTTP 403 Forbidden`**.
* **Legacy Services Without OIDC:**
  * A broker (e.g. Vault) trusts SPIRE's OIDC endpoint and exchanges a
    JWT-SVID for a static credential — issued only to specific SPIFFE IDs.
  * The pod still holds **no long-lived secret**; the exchange is per-run
    and role-scoped.

<div class="highlight-box" style="margin-top: 1.2em;">
  <strong>Benefit:</strong> Secrets cannot leak from compromised containers because the secrets simply do not exist in the tenant pod.
</div>

<div class="highlight-box" style="margin-top: 0.8em;">
  <strong>Example use case — <a href="https://www.ibm.com/products/lightwell">Project Lightwell</a>:</strong>
  the IBM + Red Hat remediated-package / vulnerability-remediation feed that pipelines pull from.
  Instead of mounting a long-lived subscription token in every build pod, only the task roles
  authorized to consume Lightwell (scanners, builders) present their JWT-SVID — the broker pattern
  above exchanges it for the Lightwell credential, scoped per-run and per-SPIFFE-ID.
</div>

???

Speaker: Andrew & Maia

Andrew: "In Pattern 2, internal services like our CVE database validate caller JWTs directly against SPIRE's JWKS. There are no secrets in the pod to steal."
Andrew: "And when a service can't speak OIDC at all — say a legacy content repository that only takes a static API token — you don't fall back to mounting that token everywhere. A broker like Vault trusts SPIRE's OIDC endpoint and exchanges the task's JWT-SVID for the static credential, only for the specific SPIFFE IDs authorized to have it. We use this at Red Hat for pipeline access to our Pulp-based content repositories."
Maia (plug): "Concrete example of this pattern in the wild — Project Lightwell, the IBM/Red Hat remediated-package feed announced last May. Pipelines consume it as a trusted package source; the broker pattern we just described is exactly how you'd gate access without pinning a long-lived subscription token in every tenant namespace."

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

Andrew: "A classic pipeline weakness: any task with a signing key can sign any claim, so a compromised build step can forge a clean vulnerability report. That's why we need Separation of Duties."

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
                 "spiffe://konflux-ci.dev/trusted/kind-konflux/default/trivy-sbom-scan")
  
  msg := sprintf("CVE scan signed by unauthorized role: %s", [attestation.certificate.uri])
}
```

<div class="highlight-box" style="margin-top: 0.8em;">
  <strong>The Guarantee:</strong> Even if a builder signs a zero-CVE report, Conforma rejects it because the builder is not an authorized scanner!
</div>

???

Speaker: Andrew

Andrew: "Conforma evaluates the in-toto attestation against this Rego policy. It checks the certificate SAN URI. The signature can be mathematically valid — but if it wasn't signed by trivy-sbom-scan, it's rejected."

---

layout: false

## What Identity Alone Doesn't Solve

Does securing task identities protect the pipeline? **Not if tasks share a disk.**

```text
Task A (build) ──────► [ Shared PVC Workspace ] ◄────── Task B (untrusted test)
                             │
                             ▼ (tampered files)
                       Task C (package & sign) ──► Cryptographically valid MALWARE!
```

**OCI Trusted Artifacts** close the loophole: each task packages its output into an immutable, digest-pinned OCI layer; downstream tasks fetch strictly immutable digests, never shared mutable volumes (required for SLSA Build Level 3).

<div class="highlight-box" style="margin-top: 1.0em;">
  <strong>Key Principle:</strong> Control plane identity (SPIRE) + Data plane immutability (OCI Trusted Artifacts) = End-to-End Pipeline Integrity.
</div>

???

Speaker: Andrew

Andrew: "Control plane identity is useless if your data plane is compromised. If tasks share a PVC, any task can alter the binaries before packaging. Trusted Artifacts replace shared volumes with immutable, digest-pinned OCI layers — that's a requirement for SLSA Build Level 3. Keep this mechanism in mind though... immutable OCI handoffs between tasks come back at the release boundary."

---

class: center, middle, inverse

# Part 4: The Next Frontier
## The Managed Release Boundary

???

Speaker: Andrew & Maia

Andrew starts Part 4:
"Now the boundaries past a single task: data plane isolation and the cross-namespace release boundary."

---

layout: false

## The Managed Release Boundary

**Dual-gating.** The release SVID is minted only when **three conditions all hold**:

1. An operator-designated **release namespace**
2. The **one sanctioned release pipeline** — classified at admission time
3. The **designated signing task** within it

Every other step in that pipeline — including the steps *before* policy verification —
is denied an identity entirely. Keyless-signed with Cosign into Rekor.

```text
spiffe://konflux-ci.dev/release/demo-app/slsa-e2e-release-dual-gated
```

**Guaranteeing policy before privilege** *(the next step — designed in the repo, not yet implemented)*.
The dual-gate you just saw is implemented and running in the repo. But it still *assumes* the
pipeline orders verification before signing. The next design removes that assumption: on a passing run, the policy task materializes a **short-lived,
run-scoped signing capability**
that only the sanctioned signer *in that same run* can obtain — no passing policy, no capability,
no signature. "Policy passed" becomes a **verified fact**, not a pipeline-ordering assumption.

<div class="highlight-box" style="margin-top: 0.8em;">
  From <em>structural</em> trust to <em>cryptographic</em> trust. Find out more in the demo repo.
</div>

???

Speaker: Maia & Andrew

Maia: "Build tasks should never have release authority. We separate tenant build namespaces from managed release namespaces."
Andrew: "Each condition alone fails differently: namespace-only makes every pod in the release namespace a signer; pipeline-only makes every step a signer; task-only lets anyone invoke the signing task from an unsanctioned pipeline. The conjunction makes exactly one pod, in one pipeline, the signer."
Andrew: "One honest caveat: the dual-gate you saw in the demo is what runs today. The run-scoped signing capability is a design documented in the repo. Trust moves from structure to cryptography."

---

layout: false

## Key Takeaways

1. **Location ≠ Role**: Stop treating Kubernetes namespaces and generic ServiceAccounts as authorization boundaries.
2. **Shift Verification to Admission**: Intercepting task bundles at admission with Kyverno prevents untrusted code from ever gaining production identities.
3. **Task-Scoped Identity is Real Today**: Combining Tekton, Kyverno, SPIFFE/SPIRE, and Sigstore brings least-privilege cryptographic identity to every CI step.
4. **Policy Closes the Loop**: In-toto attestations signed by role-scoped SVIDs allow policy engines like Conforma to verify *who was authorized to make each claim*.

???

Speaker: Maia & Andrew

Maia and Andrew close out.
Maia: "Workload identity is still evolving. Admission control plus task resolvers bring zero-trust straight to CI/CD."
Andrew: "Everything we showed today runs in our open-source repo on Kind."

---

class: center, middle, inverse

# Thank You!

### Questions & Discussion

**Andrew McNamara** (amcnamar@redhat.com) • **Maia Iyer** (maia.iyer@ibm.com)

<div style="margin-top: 2em; display: flex; justify-content: center; gap: 4em;">
  <div style="text-align: center;">
    <img src="img/qr-demo-repo.png" width="150" alt="QR code: demo repo branch"><br>
    <strong>Working Demo & Helm Charts</strong><br>
    <code>arewm/slsa-konflux-example</code><br>
    <span style="font-size: 0.75em; color: #64748b;">branch: kubecon-na-2026-your-cis-mistaken-identity</span>
  </div>
  <div style="text-align: center;">
    <img src="img/qr-slides.png" width="150" alt="QR code: view slides online"><br>
    <strong>View These Slides</strong><br>
    <code>slides.arewm.com</code>
  </div>
</div>

???

Speaker: Maia & Andrew

Open the floor for questions from the audience.

---

layout: false

## Explore the Repo: The Full Demonstration Arc

Everything we didn't have time to run live is in the demo repo:

* **Act 3 — Same-Namespace API Gating & Separation of Duties:**
  Zot OCI push gating (rogue task `403`, vetted builder `202`), secretless CVE database, OPA tests proving builder forgery is blocked.
* **Act 4 — The Managed Release Boundary:**
  Managed-tenant release pipeline, dual-gated release SVID, keyless VSA signing into Rekor,
  transparency-log verification.
* **The complete arc:** `./demo/run-demo.sh` runs Acts 0 through 4 end-to-end —
  pre-flight baseline, ambient breakdown, admission, API gating, and dual-gated release.
* **Also in the repo:** Helm charts for every policy (`charts/admission-policy/`, `charts/spiffe-spire/`),
  the Conforma separation-of-duties policy, and an idempotent `setup-demo.sh` for a
  KinD + Konflux + SPIRE + Sigstore cluster.
* **Going further:** the legacy-service token exchange and policy-gated release signing
  designs are in the repo, alongside everything else we showed today.

```bash
git clone https://github.com/arewm/slsa-konflux-example
git checkout kubecon-na-2026-your-cis-mistaken-identity
./demo/run-demo.sh              # full arc, or --act N for a single act
```

<div class="highlight-box" style="margin-top: 0.8em; display: flex; align-items: center; gap: 1.5em;">
  <img src="img/qr-demo-repo.png" width="110" alt="QR code: demo repo branch" style="flex-shrink: 0;">
  <div><strong>Scan to clone:</strong> github.com/arewm/slsa-konflux-example<br>
  <span style="font-size: 0.8em; color: #64748b;">branch <code>kubecon-na-2026-your-cis-mistaken-identity</code> &middot; full setup guide in <code>demo/README.md</code></span></div>
</div>

???

Speaker: Andrew

Andrew: "We ran Acts 1 and 2 live. Acts 3 and 4 — and the complete end-to-end arc — are all runnable from the repo. Clone the branch, run setup-demo.sh once, and run-demo.sh takes you through everything we showed today and more."

---

layout: false

## Backup: Live Demo — Act 3 (Same-Namespace API Gating & Vault Exchange)

<div class="demo-slide-container" data-port="7683">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Act 3</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>Task-Scoped Registry, Service &amp; Broker Access</strong><br>
      • OCI push gating: the rogue task's own push handshake is rejected (<code>403</code>); the vetted builder's succeeds (<code>202</code>) — zero <code>regcred</code> mounted.<br>
      • Secretless service access: the scanner task queries the CVE database with its own SVID (<code>200</code>); the dev task is refused (<code>403</code>).<br>
      • Separation of duties: Conforma/OPA denies a builder forging a clean CVE scan.<br>
      • Vault token exchange: the scanner exchanges its JWT-SVID for the legacy static credential — the dev-tier identity is denied by <code>bound_subject</code>.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 3</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code> &middot; No demo terminal? Run locally: <code>git clone github.com/arewm/slsa-konflux-example</code> (branch <code>kubecon-na-2026-your-cis-mistaken-identity</code>), then the same command — see <code>demo/README.md</code></span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Backup slide for Q&A: Act 3 live terminal (port 7683). Every task performs its own
work with its own identity — no relay pods. ~5 minutes to run live; the preserved
scrollback also walks well after a pre-run.

---

layout: false

## Backup: Live Demo — Act 4 (Managed Release Boundary)

<div class="demo-slide-container" data-port="7684">
  <div class="demo-offline-fallback">
    <div class="demo-fallback-header">
      <h3 class="demo-fallback-title">🖥️ Live Demo: Act 4</h3>
      <span class="demo-badge-offline">ttyd offline</span>
    </div>
    <div class="demo-fallback-desc">
      <strong>Dual-Gated Release Authority</strong><br>
      • A hand-crafted 'managed' release PipelineRun is denied by <code>guard-managed-labels</code> — location ≠ authorization.<br>
      • The release-service controller creates the legitimate managed PipelineRun; only <code>attach-summary-attestations</code> receives the release authority SVID.<br>
      • Keyless VSA signing into Rekor; OCI 1.1 referrers on the released image digest.
    </div>
    <div class="demo-cmd-box">
      <span class="demo-cmd-code">./demo/run-demo.sh --act 4</span>
      <button class="demo-btn demo-copy-btn">Copy</button>
    </div>
    <div class="demo-fallback-footer">
      <span class="demo-fallback-instructions">To run live in slide: <code>./demo/serve-slides.sh start</code> &middot; The release PipelineRun takes several minutes (EC verification retries) — prefer walking the preserved scrollback of a pre-run session.</span>
      <button class="demo-btn demo-retry-btn">Retry Connection</button>
    </div>
  </div>
  <div class="demo-terminal-frame" style="display: none;"></div>
</div>

???

Speaker: Andrew

Backup slide for Q&A: Act 4 live terminal (port 7684). The release pipeline takes
several minutes — best shown by scrolling a pre-run session (the terminal
preserves everything by design).
