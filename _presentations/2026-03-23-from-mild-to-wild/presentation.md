name: inverse
layout: true
class: center, middle, inverse

---

class: center, middle, title-slide

# From Mild To Wild
## How Hot Can Your SLSA Be?

Andrew McNamara (Conforma) • Adolfo "puerco" Garcia (AMPEL)

<div style="margin-top: 2em;">
  <span style="font-size: 2.5em; vertical-align: middle; margin-right: 2em;">🔴🟡🟢</span>
  <img src="/shared/logos/conforma.png" width="100" alt="Conforma logo" style="margin-right: 2em; vertical-align: middle;">
  <img src="/shared/logos/slsa.svg" width="100" alt="SLSA logo" style="vertical-align: middle;">
</div>

.footnote[
  Open Source SecurityCon · March 23, 2026
]

???

Andrew and puerco briefly introduce themselves. "I'm Andrew, I work on Konflux, a CI system built on Tekton. We also built Conforma, a Rego-based policy engine." / "And I'm puerco, I work on AMPEL." One sentence each — get right to the talk.

---

layout: false

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

## Two Policy Engines Walk Into a Bar...

<div style="display: flex; gap: 3em; margin-top: 2em; align-items: flex-start;">
  <div style="flex: 1; text-align: center;">
    <img src="/shared/logos/conforma.png" width="120" alt="Conforma logo"><br>
    <strong>Conforma</strong><br>
    <small>Rego-based policy engine<br>built around Tekton / Konflux</small>
  </div>
  <div style="flex: 1; text-align: center;">
    <div style="font-size: 3em; margin-bottom: 0.2em;">🔴🟡🟢</div>
    <strong>AMPEL</strong><br>
    <small>Policy engine for in-toto attestation evaluation<br>produces VSAs</small>
  </div>
</div>

<div style="margin-top: 2.5em; border-top: 1px solid #ccc; padding-top: 1.5em;">
  We show each level with <strong>both engines</strong>.<br>
  The engines are interchangeable. <em>Your policies are not your lock-in.</em>
</div>

???

Playful framing — introduce the "game." Puerco will demo a feature with AMPEL, Andrew will say "Conforma does that too." Then the challenger ups the ante to the next level. At mild, puerco leads and Andrew challenges. At medium, puerco leads and Andrew challenges. At wild, Andrew leads again, puerco closes. This slide explains the structure so the audience can follow along.

---

class: center, middle, inverse

# 🌶 Mild

**Verify provenance properties**

???

Puerco introduces this level. Brief context for the audience: an attestation is a signed statement about your software — produced by your build system, your CI pipeline, or a verification tool. At mild, we verify fundamental provenance properties: is provenance present, is the build type recognized, does it come from a trusted builder, were materials properly tracked? This is where everyone should start.

---

layout: false

## Mild: Verify Provenance Properties

**Scenario**: Any OCI artifact with SLSA provenance — regardless of build system.

Checks:
1. **Provenance attestation** is present
2. **Build type** is in the accepted list
3. **Builder identity** matches expected builder
4. **Source materials** are version-controlled git repos with SHAs
5. **External parameters** are restricted

```hjson
// AMPEL policy — verify SLSA provenance properties
{
    tenets: [
        {
            id: provenance-present
            runtime: "cel@v0"
            code: "size(predicates) > 0"
            predicates: { types: ["https://slsa.dev/provenance/v1"] }
        }
        {
            id: vsa-meets-slsa-level
            runtime: "cel@v0"
            code: '''
                predicates.exists(p,
                    p.data.verifiedLevels.exists(l, l == "SLSA_BUILD_LEVEL_1")
                )
            '''
            predicates: { types: ["https://slsa.dev/verification_summary/v1"] }
        }
    ]
}
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

## "But What About Producing a Portable Summary?"

*Andrew raises the bar*

> "So you verified the provenance locally."

> "What if downstream consumers need to know it passed verification?"

> "Can you produce a signed summary they can check without re-running all the policy checks?"

???

Andrew raises the bar. The natural next question after local verification is portability: how do you communicate verification results to downstream systems? VSAs solve this: they're signed summaries that say "I verified this artifact at SLSA level X." An admission controller can check the VSA instead of re-verifying the provenance. This is the transition to medium.

---

class: center, middle, inverse

# 🌶🌶 Medium

**Same checks + produce a VSA**

???

Puerco takes the lead. Medium takes an image built with GitHub Actions, verifies its SLSA properties (the same checks from mild), verifies the base image too, and produces a VSA that captures both results. Downstream consumers check the VSA instead of re-running verification.

---

## Medium: Verification Results as a Portable VSA

**Scenario**: Image built with **GitHub Actions**, signed with **Sigstore keyless**. We verify both the built image and its base image, then produce a signed **VSA at SLSA Build Level 2** — including the base image's properties so they don't need to be recomputed.

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

Puerco demos the medium workflow live. The script extracts the base image from the OCI manifest annotations, verifies the base image release signature and provenance (pass 1), then verifies the built image's provenance using keyless Sigstore verification against the GitHub Actions OIDC identity (pass 2). It generates a SLSA VSA at Build Level 2 with the base image as a dependency. The VSA decouples "who evaluates" from "who enforces" — downstream consumers check the VSA instead of re-verifying provenance. The same script works with Tekton Chains (key-based) by swapping `--certificate-*` flags for `--public-key`.

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

*Andrew raises the bar*

> "We can verify what the provenance says and produce a VSA at L2."

> "But did the tasks recorded in the provenance actually *produce* this artifact?"

> "Tekton Chains records tasks accurately — but pipelines are user-customizable. Any task could have injected a different artifact."

> "If we verify the tasks themselves were pinned and trusted, can we upgrade to L3?"

???

Andrew raises the deeper trust question. This is the distinction between recording what ran and knowing that what ran *actually produced* the artifact. We're already producing VSAs at L2. The question for wild is: can we verify the tasks were trusted and upgrade to L3? Tekton Chains accurately records the tasks that ran, but because Tekton pipelines are user-customizable, the provenance can't on its own prove the artifact is the genuine output of those tasks. This motivates wild: use policy to inspect the Tekton provenance and verify that specific pinned trusted task bundles were used.

---

class: center, middle, inverse

# 🌶🌶🌶 Wild

**Upgrade from L2 to L3 with trusted task verification**

???

Andrew introduces the wild level. Wild does the same thing as medium but for Tekton, where we have trusted tasks and isolation guarantees that let us upgrade to L3. Tekton Chains records task references in the provenance. Wild policy verifies every task is a known, pinned bundle or git reference. If all tasks are trusted, the build environment's isolation guarantees are established, and the VSA declares L3. If any are untrusted, warnings are produced and the VSA stays at L2.

---

## Wild: Trusted Task Verification for L3

Tekton provenance records task references — **bundle digests** (PipelineRun) or **git SHAs** (TaskRun):

```json
// PipelineRun provenance (SLSA v0.2)
{ "buildConfig": { "tasks": [{
    "name": "buildah",
    "ref": { "bundle": "quay.io/konflux-ci/tekton-catalog/task-buildah@sha256:..." }
}]}}

// TaskRun provenance (SLSA v1.0)
{ "buildDefinition": { "resolvedDependencies": [{
    "name": "task",
    "uri": "git+https://github.com/arewm/mild-to-wild-samples",
    "digest": { "sha1": "e2c6ae7358fd68399787d322347a95ccd7bbb2f8" }
}]}}
```

**Wild policy**: verify every task against a **trusted task allowlist**. This is a `warn` rule, not `deny`:
- Untrusted tasks → warnings → VSA declares **L2**
- All tasks trusted (no warnings) → VSA declares **L3**

```rego
# Conforma — verify task references (warn, not deny)
warn contains result if {
    some att in lib.pipelinerun_attestations
    tasks := tekton.tasks(att)
    bundle_refs := {ref | some t in tasks; ref := tekton.task_ref(t).bundle; ref != ""}
    manifests := ec.oci.image_manifests(bundle_refs)
    untrusted := tekton.untrusted_task_refs(tasks, manifests)
    count(untrusted) > 0
    some task in untrusted
    ref := tekton.task_ref(task)
    bundle_ref := object.get(ref, "bundle", ref.key)
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
// AMPEL — evaluate task bundle digests
{
    context: {
        allowed_bundle_prefix: {
            type: "string"
            required: true
            default: "quay.io/konflux-ci/tekton-catalog/"
        }
    }

    tenets: [{
        id: all-tasks-trusted
        runtime: "cel@v0"
        code: '''
            predicates.exists(p,
                p.data.buildConfig.tasks.all(task,
                    has(task.ref) && has(task.ref.bundle) &&
                    task.ref.bundle.startsWith(context.allowed_bundle_prefix)
                )
            )
        '''
        predicates: { types: ["https://slsa.dev/provenance/v0.2"] }
    }]
}
```

Same interchangeability point: standardized Tekton provenance format, substitutable engines.

Warnings from untrusted tasks → L2 in VSA. All tasks trusted → L3.

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
  <em>Attestation standards are open. Your policies travel with you.</em>
</div>

???

Both speakers together. Quick summary. The three key messages:
1. Start at mild with foundational provenance checks. Medium adds VSA output at L2 for portable verification. Wild upgrades to L3 by verifying trusted tasks.
2. Policy engines are interchangeable because the attestation standards are open.
3. Wild-level trust is Tekton-specific but follows the same pattern: verify properties in standardized attestations.

---

## Resources

<div style="display: flex; justify-content: space-around; margin-top: 2em; flex-wrap: wrap; gap: 2em;">
  <div style="text-align: center;">
    <img src="/shared/qr-codes/conforma.png" width="140" alt="Conforma QR code"><br>
    <strong>conforma.dev</strong>
  </div>
  <div style="text-align: center;">
    <div style="width: 140px; height: 140px; border: 2px solid #333; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 2em;">
      🔴🟡🟢
    </div><br>
    <strong>github.com/carabiner-dev/ampel</strong>
  </div>
  <div style="text-align: center;">
    <img src="/shared/qr-codes/slsa.png" width="140" alt="SLSA QR code"><br>
    <strong>slsa.dev</strong>
  </div>
  <div style="text-align: center;">
    <div style="width: 140px; height: 140px; border: 2px solid #333; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 2em;">
      📊
    </div><br>
    <strong>slides.arewm.com</strong>
  </div>
  <div style="text-align: center;">
    <div style="width: 140px; height: 140px; border: 2px solid #333; display: flex; align-items: center; justify-content: center; margin: 0 auto; font-size: 2em;">
      💻
    </div><br>
    <strong>Sample policies</strong>
  </div>
</div>

???

Quick close. "Scan, follow along, try it yourself." The AMPEL QR and slides QR will be added once the project link and slides URL are confirmed.

---

class: center, middle, inverse

# Thank You

Questions?

<div style="margin-top: 2em;">
  Andrew McNamara · <strong>conforma.dev</strong><br>
  Adolfo "puerco" Garcia · <strong>AMPEL</strong>
</div>

???

Open for Q&A. Roughly 7 minutes. Both speakers take questions.
