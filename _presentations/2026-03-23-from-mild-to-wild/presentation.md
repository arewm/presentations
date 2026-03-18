name: inverse
layout: true
class: center, middle, inverse

---

class: center, middle, title-slide

<div style="position: absolute; left: 0; top: 0; right: 0; bottom: 0; margin: -2em -4em; padding: 2em 4em; background: linear-gradient(135deg, #2e7d32 0%, #388e3c 25%, #f57c00 50%, #e65100 75%, #b71c1c 100%); color: white; display: flex; flex-direction: column; align-items: center; justify-content: center;">
<h1 style="color: white; margin: 0;">From Mild To Wild</h1>
<h2 style="color: white; margin: 0.5em 0;">How Hot Can Your SLSA Be?</h2>
<p style="margin: 0.5em 0;">Andrew McNamara (Conforma) • Adolfo "puerco" Garcia (AMPEL)</p>

<div style="margin-top: 2em;">
  <img src="/shared/logos/conforma.png" width="100" alt="Conforma logo" style="margin-right: 6em; vertical-align: middle;">
  <span style="font-size: 2.5em; vertical-align: middle; margin-right: 2em;">🔴🟡🟢</span>
  <!--img src="/shared/logos/slsa.svg" width="100" alt="SLSA logo" style="vertical-align: middle;"-->
</div>

<div style="position: absolute; bottom: 3em; font-size: 0.8em; color: rgba(255,255,255,0.9);">
  Open Source SecurityCon · March 23, 2026
</div>
</div>

???

Andrew and puerco briefly introduce themselves. "I'm Andrew, I am a SLSA maintainer and I work on Konflux, a CI system built on Tekton. We also built Conforma, a Rego-based policy engine." / "And I'm puerco, I work on AMPEL." One sentence each — get right to the talk.

---

layout: false

## Attestations in One Slide

<div style="display: flex; align-items: center; justify-content: center; gap: 0.6em; margin: 1.2em 0; flex-wrap: wrap;">
  <span style="display: inline-block; padding: 0.4em 0.8em; background: #e3f2fd; border-radius: 8px; font-size: 0.9em;">artifact</span>
  <span style="color: #666;">→</span>
  <span style="display: inline-block; padding: 0.4em 0.8em; background: #fff3e0; border-radius: 8px; font-size: 0.9em;">predicate</span>
  <span style="color: #666;">+</span>
  <span style="display: inline-block; padding: 0.4em 0.8em; background: #e8f5e9; border-radius: 8px; font-size: 0.9em;">signature</span>
  <span style="color: #666;">→</span>
  <span style="display: inline-block; padding: 0.4em 0.8em; background: #f3e5f5; border-radius: 8px; font-size: 0.9em; font-weight: bold;">attestation</span>
</div>

<div style="background: #f5f5f5; border-left: 4px solid #1976d2; padding: 0.8em 1em; border-radius: 0 8px 8px 0; margin-bottom: 1em;">
  <strong>Attestations</strong> = signed statements about an artifact (who built it, from what, how).  
  Often <strong>in-toto</strong>: predicate (e.g. SLSA provenance) + signature.
</div>

<div style="text-align: center; font-size: 1.05em; color: #c62828;">
  You get provenance and other predicates — the hard part is <em>using</em> them.
</div>

<div style="display: flex; align-items: center; justify-content: center; gap: 2em; margin-top: 1.5em; flex-wrap: wrap;">
  <img src="/shared/logos/intoto-icon.svg" width="56" height="56" alt="in-toto" style="object-fit: contain;">
  <img src="/shared/logos/slsa.svg" width="70" alt="SLSA" style="opacity: 0.9;">
  <img src="/shared/logos/spdx-logo.svg" width="100" alt="SPDX" style="object-fit: contain;">
  <img src="/shared/logos/cyclonedx-logo.svg" width="100" alt="CycloneDX" style="object-fit: contain;">
</div>

???

One-line setup: we're talking about signed metadata (provenance, etc.). Don't dwell — next slide is "you have these, now what?"

---

## You Have Attestations. Now What?

You've signed your artifacts. Provenance exists.

But how do you actually *use* them to enforce policy?

<div style="margin-top: 2em; font-size: 1.1em;">
  Today: <strong>three levels</strong> of policy enforcement · <strong>two policy engines</strong> · <strong>one conclusion</strong>
</div>

<div style="text-align: center; margin-top: 3em;">
  <img src="img/heat-scale.svg" width="600" alt="Heat scale: mild, medium, wild">
</div>

???

Andrew sets up the problem space. We're not talking about *generating* attestations today — that's covered elsewhere. We're talking about what you do with them once they exist. A signed artifact with provenance is only useful if something checks that provenance. Today we walk through three levels of sophistication for that checking, and show how two different policy engines handle each level.

---

## Two Policy Engines Walk Into an Attestation...

<div style="display: flex; gap: 3em; margin-top: 2em; align-items: flex-start;">
  <div style="flex: 1; text-align: center;">
    <div style="font-size: 3em; margin-bottom: 0.2em;">🔴🟡🟢</div>
    <strong>AMPEL</strong><br>
    <small>Policy engine for in-toto attestation evaluation<br>produces VSAs</small>
  </div>
  <div style="flex: 1; text-align: center;">
    <img src="/shared/logos/conforma.png" width="120" alt="Conforma logo"><br>
    <strong>Conforma</strong><br>
    <small>Rego-based policy engine<br>incubated with Konflux</small>
  </div>
</div>

<div style="margin-top: 2.5em; border-top: 1px solid #ccc; padding-top: 1.5em; font-size: 0.9em;">
  <strong>Coming up:</strong><br>
  <span style="color: #2e7d32;">🌶 Mild</span> — simple verification &nbsp;·&nbsp;
  <span style="color: #e65100;">🌶🌶 Medium</span> — combining attestations &nbsp;·&nbsp;
  <span style="color: #b71c1c;">🌶🌶🌶 Wild</span> — digging into attestations
</div>

???

Playful framing — introduce the "game." Puerco will demo a feature with AMPEL, Andrew will show that "Conforma does that too." Then the challenger ups the ante to the next level. At mild, puerco leads and Andrew challenges. At medium, puerco leads and Andrew challenges. At wild, Andrew leads again, puerco closes. Tell the audience: at each level we'll show both engines so you see they're interchangeable; same attestations, same policies.

---

class: center, middle, inverse

# <span style="color: #2e7d32;">🌶 Mild</span>

**Verify provenance properties**

???

Puerco introduces this level. As mentioned before, an attestation is a signed statement about your software — produced by your build system, your CI pipeline, or a verification tool. At mild, we verify fundamental provenance properties: is provenance present, is the build type recognized, does it come from a trusted builder, were materials properly tracked? This is where everyone should start.

---

layout: false

## Mild: Verify Provenance Properties

class: small

**Scenario**: Consuming any OCI artifact with SLSA provenance — regardless of build system.

Checks:
1. **Provenance attestation** is present
2. **Build type** is in the accepted list
3. **Builder identity** matches expected builder
4. **Source materials** are version-controlled git repos with SHAs
5. **External parameters** are restricted

```hjson
// AMPEL policy — verify SLSA provenance properties
{ tenets: [
  { id: provenance-present, runtime: "cel@v0", code: "size(predicates) > 0",
    predicates: { types: ["https://slsa.dev/provenance/v1"] } },
  { id: vsa-meets-slsa-level, runtime: "cel@v0",
    code: "predicates.exists(p, p.data.verifiedLevels.exists(l, l == \"SLSA_BUILD_LEVEL_1\"))",
    predicates: { types: ["https://slsa.dev/verification_summary/v1"] } }
]}
```

**Result**: pass / fail per rule. Works with any build system that produces SLSA provenance.

???

Puerco walks through the AMPEL policy for mild. This is entirely build-system-agnostic — it checks for SLSA provenance presence and verifies the VSA declares at least Build Level 1. No hardcoded builder identity or build type. These checks work with provenance from GitHub Actions, Tekton, or any other system that produces SLSA-formatted attestations.

---

## Mild: "Conforma Does That Too"

Same checks, different engine:

```rego
# Conforma policy — verify foundational provenance properties
deny contains result if {
    count(lib.slsa_provenance_attestations) == 0
    result := lib.result_helper(rego.metadata.chain(), [])
}

deny contains result if {
    some att in lib.slsa_provenance_attestations
    build_type := _build_type(att)  # handles both SLSA v0.2 and v1.0
    allowed := lib.rule_data("allowed_build_types")
    not build_type in allowed
    result := lib.result_helper(rego.metadata.chain(), [build_type])
}

# Plus upstream rules for: builder identity, source materials, external params
```

**Same checks. Different engine.**

Attestation formats follow open standards (in-toto / SLSA), so engines are substitutable.

???

Andrew's "me too." The Conforma policy does the same checks in Rego. Two custom rules: provenance must exist, build type must be in the allowed list. The allowed list is configurable — not hardcoded to any build system. Upstream rules handle builder identity, source materials, and external parameters. About 30 seconds.

---

## "But What About Multiple Attestations — and a Portable Summary?"

*Raising the bar*

> "So you verified one artifact's provenance."

> "What about its dependencies? Base image, other attestations — can you combine and verify them together?"

> "And produce a signed summary so downstream doesn't have to re-verify all of them?"

???

Puerco raises the bar. Medium does two things: combine multiple attestations (e.g. built image + base image) and verify them together, and produce a VSA so downstream consumers don't have to re-fetch and re-verify every attestation — they check the one summary. This is the transition to medium — Puerco leads with AMPEL.

---

class: center, middle, inverse

# <span style="color: #e65100;">🌶🌶 Medium</span>

**Combine multiple attestations · produce a VSA**

???

Puerco takes the lead. Medium combines and verifies multiple attestations (e.g. built image + base image), same mild-style checks, and produces a VSA that captures the combined result so downstream doesn't re-verify each attestation.

---

## Medium: AMPEL — Producing a VSA

**Scenario**: Image built with **GitHub Actions**, signed with **Sigstore keyless**. Verify the **built image** and its **base image** (multiple attestations), then produce a signed **VSA at SLSA Build Level 2**.

**Combine & verify**: Same mild-style tenets across both attestations; AMPEL produces a single VSA with verified level and dependency levels. **Portable summary**: Downstream checks the VSA instead of re-verifying each attestation.

**Result**: One VSA at L2 attached — one check for downstream.

???

Puerco leads. AMPEL policy at medium extends mild: same provenance checks, plus the engine produces a signed VSA (verifiedLevels, dependencyLevels for the base image) and attaches it. Demo: run AMPEL against the GitHub Actions–built image and base image, show the resulting VSA.

---

## Medium: AMPEL — [Placeholder]

*Policy snippet and/or demo output to be added.*

???

Placeholder: add AMPEL medium policy (hjson) and/or CLI output when ready.

---

## Medium: Verification Results as a Portable VSA (Conforma)

**Scenario**: Same — **two attestations** (built image + base). Conforma policy + `generate-vsa.sh` verify both and produce one VSA.

```bash
$ generate-vsa.sh \
    --image ghcr.io/puerco/mild-to-wild-samples@sha256:7add... \
    --policy 2-medium/conforma/policy.yaml \
    --certificate-identity '...build-push.yaml@refs/heads/main' \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    --base-image-policy 1-mild/conforma/policy.yaml \
    --base-image-key cosign-provenance.pub \
    --base-image-release-key cosign-release.pub \
    --vsa-signing-key vsa.key

=== Verifying ghcr.io/puerco/mild-to-wild-samples@sha256:7add... ===
--- Pass 1: Verifying base image ubi-minimal@sha256:3d6e...
  Release signature: OK
  Provenance: OK
--- Pass 2: Verifying built image
  Policy evaluation: PASSED
  Built image level: SLSA_BUILD_LEVEL_2
  Base image: ubi-minimal@sha256:3d6e... -> SLSA_BUILD_LEVEL_2

=== VSA predicate ===
{ "verifiedLevels": ["SLSA_BUILD_LEVEL_2"],
  "dependencyLevels": {"SLSA_BUILD_LEVEL_2": 1}, ... }

VSA attached to ghcr.io/puerco/mild-to-wild-samples@sha256:7add...
```

???

Andrew: "Conforma does that too." The script extracts the base image from the OCI manifest annotations, verifies the base image release signature and provenance (pass 1), then verifies the built image's provenance using keyless Sigstore verification against the GitHub Actions OIDC identity (pass 2). It generates a SLSA VSA at Build Level 2 with the base image as a dependency. The VSA decouples "who evaluates" from "who enforces" — downstream consumers check the VSA instead of re-verifying provenance. The same script works with Tekton Chains (key-based) by swapping `--certificate-*` flags for `--public-key`.

---

## Medium: "Conforma Does That Too"

The policy doesn't care whether the image was built by GitHub Actions or Tekton:

```yaml
# policy.yaml accepts both build systems
ruleData:
  allowed_builder_ids:
    - "https://github.com/arewm/.../tekton-build"
    - "https://github.com/puerco/...build-push.yaml@refs/heads/main"
  allowed_build_types:
    - "https://tekton.dev/chains/v2/slsa"
    - "https://actions.github.io/buildtypes/workflow/v1"
```

The `generate-vsa.sh` script works with either build system — swap `--certificate-*` for `--public-key` when using Tekton Chains. Same VSA output either way.

Both engines verify the same properties and can produce VSAs for downstream enforcement. The VSA format is standardized (in-toto), so the output is portable across policy engines.

???

Andrew's "me too." The key insight: the same Conforma policy accepts provenance from either build system because the SLSA format is standardized. The ruleData lists both builder IDs and build types. The generate-vsa.sh script handles key-based or keyless verification — just different CLI flags. The VSA format is standardized, so either engine can produce VSAs that any consumer can verify. About 45 seconds.

---

## "But Here's What Keeps Me Up at Night"

*Raising the bar*

> "We can verify what the provenance says and produce a VSA at L2."

> "But did the tasks recorded in the provenance actually *produce* this artifact?"

> "Tekton Chains records tasks accurately — but pipelines are user-customizable. Any task could have injected a different artifact."

> "If we verify the tasks themselves were pinned and trusted, can we upgrade to L3?"

???

Andrew raises the deeper trust question. This is the distinction between recording what ran and knowing that what ran *actually produced* the artifact. We're already producing VSAs at L2. The question for wild is: can we verify the tasks were trusted and upgrade to L3? Tekton Chains accurately records the tasks that ran, but because Tekton pipelines are user-customizable, the provenance can't on its own prove the artifact is the genuine output of those tasks. This motivates wild: use policy to inspect the Tekton provenance and verify that specific pinned trusted task bundles were used.

---

class: center, middle, inverse

# <span style="color: #b71c1c;">🌶🌶🌶 Wild</span>

**Upgrade from L2 to L3 with trusted task verification**

???

Andrew introduces the wild level. Wild does the same thing as medium but for Tekton, where we have trusted tasks and isolation guarantees that let us upgrade to L3. Tekton Chains records task references in the provenance. Wild policy verifies every task is a known, pinned bundle or git reference. If all tasks are trusted, the build environment's isolation guarantees are established, and the VSA declares L3. If any are untrusted, warnings are produced and the VSA stays at L2.

---

## Wild: Trusted Task Verification for L3

Tekton provenance records remote task references including bundle digests or git SHAs.

```json
// TaskRun provenance (SLSA v1.0)
{ "buildDefinition": { "resolvedDependencies": [{
    "name": "task",
    "uri": "git+https://github.com/arewm/mild-to-wild-samples",
    "digest": { "sha1": "e2c6ae7358fd68399787d322347a95ccd7bbb2f8" }
}]}}
```

**Policy**: verify every task against a **trusted allowlist**. `warn` rule, not `deny` → untrusted → **L2**; all trusted → **L3**.

```rego
# Conforma — warn on untrusted task refs
warn contains result if {
    some att in lib.pipelinerun_attestations
    tasks := tekton.tasks(att)
    untrusted := tekton.untrusted_task_refs(tasks, manifests)  # allowlist check
    count(untrusted) > 0
    result := lib.result_helper(rego.metadata.chain(), [bundle_ref])
}
```

???

Andrew explains the wild approach. Tekton Chains records task bundle references (for PipelineRun) or git resolver references (for TaskRun) in the provenance. Wild policy collects the bundle refs, fetches their OCI manifests (for version constraint checking), and verifies each task against a trusted task allowlist. Crucially, this is a `warn` rule, not `deny` — the policy always passes. Untrusted tasks produce warnings, which means the VSA stays at L2. If all tasks are trusted (no warnings), the VSA upgrades to L3. This is the "trusted task" model that Konflux uses: pinned tasks with known digests behave deterministically.

---

## Wild: Trusted Task Data Format

The allowlist specifies which task references are trusted:

```yaml
# For PipelineRun: trusted_task_rules (OCI bundle patterns)
# Loaded from quay.io/konflux-ci/tekton-catalog/data-acceptable-bundles

# For TaskRun: trusted_task_refs (git URI + digest)
trusted_task_refs:
  - uri: "git+https://github.com/arewm/mild-to-wild-samples"
    digest:
      sha1: "e2c6ae7358fd68399787d322347a95ccd7bbb2f8"
```

Policy checks the provenance task references against this data. Matching = trusted. Warnings = untrusted → L2. No warnings = all trusted → L3.

<div style="text-align: center; margin-top: 1em;">
  <img src="img/wild-flow.svg" width="580" alt="Tekton provenance → policy checks tasks → VSA at L2 or L3">
</div>

???

Show the trusted task data format. For PipelineRun provenance, the trusted task rules come from an OCI bundle (Konflux's tekton-catalog). For TaskRun provenance using the git resolver, we maintain a list of trusted git URI prefixes and digests. The policy matches the task references in the provenance against this data. Any untrusted task produces a warning, which signals the VSA generator to stay at L2. All trusted means no warnings, so the VSA can declare L3.

---

## Wild: "AMPEL Can Verify That Too"

```hjson
// AMPEL — all tasks from allowed bundle prefix
{ context: { allowed_bundle_prefix: { type: "string", default: "quay.io/konflux-ci/tekton-catalog/" } }
  tenets: [{
    id: all-tasks-trusted, runtime: "cel@v0",
    code: "predicates.exists(p, p.data.buildConfig.tasks.all(task, has(task.ref.bundle) && task.ref.bundle.startsWith(context.allowed_bundle_prefix)))",
    predicates: { types: ["https://slsa.dev/provenance/v0.2"] }
  }]
}
```

Same idea: trusted allowlist, substitutable engines. Untrusted → L2; all trusted → L3.

???

Puerco's final "me too." The payoff of the running gag: even for the most nuanced policy use case — trusted task verification with warn-level rules — both engines can do it. The attestation standard is the key, not the engine. Keep it brief — about 30 seconds. Then segue directly into takeaways.

---

## Which Heat Level Are You?

<table style="margin-top: 1.5em; width: 100%; font-size: 0.95em;">
  <tr>
    <th style="width: 15%;">Level</th>
    <th style="width: 30%;">You check…</th>
    <th style="width: 30%;">Produces…</th>
    <th style="width: 25%;">Start here if…</th>
  </tr>
  <tr>
    <td>🌶 <strong>Mild</strong></td>
    <td>Provenance present, build type, builder identity, source materials, external params</td>
    <td>Pass/fail verification</td>
    <td>Just getting started</td>
  </tr>
  <tr>
    <td>🌶🌶 <strong>Medium</strong></td>
    <td>Same as mild</td>
    <td>VSA at SLSA Build Level 2</td>
    <td>You want portable summaries for admission control</td>
  </tr>
  <tr>
    <td>🌶🌶🌶 <strong>Wild</strong></td>
    <td>Same as medium + trusted task verification (Tekton-specific)</td>
    <td>VSA at L2 (warnings) or L3 (all tasks trusted)</td>
    <td>You want end-to-end trust</td>
  </tr>
</table>

<div style="margin-top: 2em; border-top: 1px solid #ccc; padding-top: 1.5em;">
  Policy engines are <strong>interchangeable</strong>. Pick the one that fits your stack.<br>
  <em>Attestation standards are open.</em>
</div>

???

Both speakers together. Quick summary. The three key messages:
1. Start at mild with foundational provenance checks. Medium adds VSA output at L2 for portable verification. Wild upgrades to L3 by verifying trusted tasks.
2. Policy engines are interchangeable because the attestation standards are open.
3. Wild-level trust is Tekton-specific but follows the same pattern: verify properties in standardized attestations.

---

## Resources

<div style="display: flex; flex-direction: column; gap: 2.5em; margin-top: 2em;">
  <div style="display: flex; justify-content: space-around; flex-wrap: wrap; gap: 2em;">
    <div style="text-align: center;">
      <img src="/shared/qr-codes/conforma.png" width="140" alt="Conforma QR code"><br>
      <strong><a href="https://conforma.dev">conforma.dev</a></strong>
    </div>
    <div style="text-align: center;">
      <div style="width: 140px; height: 140px; border: 2px solid #333; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 2em;">
        🔴🟡🟢
      </div><br>
      <strong><a href="https://github.com/carabiner-dev/ampel">github.com/carabiner-dev/ampel</a></strong>
    </div>
    <div style="text-align: center;">
      <img src="/shared/qr-codes/slsa.png" width="140" alt="SLSA QR code"><br>
      <strong><a href="https://slsa.dev">slsa.dev</a></strong>
    </div>
  </div>
  <div style="display: flex; justify-content: space-around; flex-wrap: wrap; gap: 2em;">
    <div style="text-align: center;">
      <div style="width: 140px; height: 140px; border: 2px solid #333; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 2em;">
        📊
      </div><br>
      <strong><a href="https://slides.arewm.com">slides.arewm.com</a></strong>
    </div>
    <div style="text-align: center;">
      <div style="width: 140px; height: 140px; border: 2px solid #333; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 2em;">
        💻
      </div><br>
      <strong><a href="https://github.com/arewm/mild-to-wild-samples">github.com/arewm/mild-to-wild-samples</a></strong>
    </div>
  </div>
</div>

???

Quick close. "Scan, follow along, try it yourself." The AMPEL QR and slides QR will be added once the project link and slides URL are confirmed.

---

class: center, middle, inverse

# Thank You

Questions?

<div style="margin-top: 2em;">
  Andrew McNamara · <strong>arewm@redhat.com</strong><br>
  Adolfo "puerco" Garcia · <strong>AMPEL</strong>
</div>

.footnote[
  <a href="https://slides.arewm.com/presentations/2026-03-23-from-mild-to-wild">slides.arewm.com/presentations/2026-03-23-from-mild-to-wild</a>
]

???

Open for Q&A. Roughly 7 minutes. Both speakers take questions.
