# Who Are You Building For: Pipelines Have a Purpose

Andrew McNamara & Julen Landa Alustiza, Red Hat

Open Source Summit North America 2025

---

# Today's Focus: The Developer Experience

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>📋 Our Journey Today</h3>
    <ol>
      <li><strong>Andrew:</strong> Progressive trust model</li>
      <li><strong>Andrew:</strong> Usable security by default</li>
      <li><strong>Andrew:</strong> Policy-driven development</li>
      <li><strong>Julen:</strong> Hands-on onboarding</li>
      <li><strong>Julen:</strong> Pipeline customization</li>
      <li><strong>Julen:</strong> Security in practice</li>
      <li><strong>Julen:</strong> Release workflow</li>
    </ol>
  </div>
  <div style="flex: 1;">
    <h3>🎯 What You'll Learn</h3>
    <ul>
      <li>Progressive trust model</li>
      <li>Usable security concepts</li>
      <li>Policy-driven development</li>
      <li>Real developer workflow</li>
      <li>Build once, release anywhere</li>
    </ul>
  </div>
</div>

<!--
Andrew: Focus on the progressive trust model, security architecture, and usable security
Julen: Focus on hands-on developer experience, demos, practical steps
20 minutes total - Andrew covers concepts, then Julen shows them in action
-->

---

# The Challenge: Security vs. Developer Experience

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>🔒 Traditional Security</h3>
    <ul>
      <li>Compliance-first approach</li>
      <li>Complex configurations</li>
      <li>Late-stage feedback</li>
      <li>Developer friction</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>🚀 What Developers Want</h3>
    <ul>
      <li>Fast iteration cycles</li>
      <li>Simple onboarding</li>
      <li>Flexible workflows</li>
      <li>Clear feedback</li>
    </ul>
  </div>
</div>

<div style="margin-top: 40px; text-align: center; font-size: 1.3em; color: #0066cc;">
  <strong>How do we achieve both simultaneously?</strong>
</div>

<!--
Andrew: Set up the fundamental tension
This is the core problem we're solving
-->

---

# Our Approach: Progressive Trust Model

<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Complete trust model stack -->
      <div style="background: #e6f3ff; border: 2px solid #0066cc; padding: 15px; text-align: center; font-weight: bold; height: 50px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        🔐 Policy-Driven Development
      </div>
      <div style="background: #fff0e6; border: 2px solid #ff8c00; padding: 15px; text-align: center; font-weight: bold; height: 50px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        📋 Observer Attestations
      </div>
      <div style="background: #f0e6ff; border: 2px solid #8c00ff; padding: 15px; text-align: center; font-weight: bold; height: 50px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        📦 Trusted Artifacts
      </div>
      <div style="background: #ffe6e6; border: 2px solid #ff4444; padding: 15px; text-align: center; font-weight: bold; height: 50px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        ✅ Trusted Tasks
      </div>
      <div style="background: #e6ffe6; border: 2px solid #00cc66; padding: 15px; text-align: center; font-weight: bold; height: 50px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        🏗️ Tekton + Kubernetes
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Building Trust Layer by Layer</h3>
    <ul>
      <li><strong>Foundation:</strong> Secure execution environment</li>
      <li><strong>Trusted Tasks:</strong> Community-vetted components</li>
      <li><strong>Trusted Artifacts:</strong> Tamper-proof data flow</li>
      <li><strong>Observer Attestations:</strong> Independent verification</li>
      <li><strong>Policy-Driven:</strong> Guidance at the right time</li>
    </ul>
  </div>
</div>

<!--
Andrew: This is the core architecture
Each layer builds on the previous one
This is what enables usable security
-->

---

# Usable Security: Konflux's Design Philosophy

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>🎯 Security by Default</h3>
    <ul>
      <li><strong>Immediate protection:</strong> SLSA Build Level 3 from day one</li>
      <li><strong>Zero configuration:</strong> Secure defaults work out of the box</li>
      <li><strong>Progressive enhancement:</strong> Add security as you learn</li>
      <li><strong>Transparent operation:</strong> See what's happening</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>🔄 Feedback Loops</h3>
    <ul>
      <li><strong>Early detection:</strong> Find issues in development</li>
      <li><strong>Clear guidance:</strong> Actionable remediation steps</li>
      <li><strong>Learning opportunities:</strong> Violations become education</li>
      <li><strong>Continuous improvement:</strong> Policies evolve with team</li>
    </ul>
  </div>
</div>

<div style="margin-top: 30px; text-align: center; font-size: 1.2em; color: #0066cc;">
  <strong>Security that helps, not hinders</strong>
</div>

<!--
Andrew: Explain the usable security philosophy
This is different from traditional security approaches
-->

---

# Policy-Driven Development in Practice

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🚨 Traditional Approach</h3>
    <ul>
      <li>Security team creates policies</li>
      <li>Developers find out at release time</li>
      <li>"Why did my release fail?"</li>
      <li>Scramble to fix issues</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>✅ Policy-Driven Approach</h3>
    <ul>
      <li>Policies integrated into workflow</li>
      <li>Immediate feedback in PRs</li>
      <li>Clear violation descriptions</li>
      <li>Suggested remediation steps</li>
    </ul>
  </div>
</div>

<div style="margin-top: 30px; padding: 15px; background: #e8f5e8; border-left: 4px solid #4caf50;">
  <strong>The goal:</strong> Turn policy violations into learning opportunities, not roadblocks
</div>

<!--
Andrew: Explain the shift from reactive to proactive security
This is what makes security usable
-->

---

# From Theory to Practice

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>🎓 What Andrew Covered</h3>
    <ul>
      <li>Progressive trust model architecture</li>
      <li>Usable security principles</li>
      <li>Policy-driven development approach</li>
      <li>Why this matters for developers</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>🛠️ What Julen Will Show</h3>
    <ul>
      <li>How this looks in practice</li>
      <li>Actual developer workflow</li>
      <li>Real onboarding experience</li>
      <li>Security without friction</li>
    </ul>
  </div>
</div>

<div style="margin-top: 40px; text-align: center; font-size: 1.3em; color: #0066cc;">
  <strong>Let's see the trust model in action!</strong>
</div>

<!--
Andrew: Transition to Julen
Set expectations for what's coming next
-->

---

# Hands-On: Quick Onboarding - From Zero to Building

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🚀 Getting Started</h3>
    <ul>
      <li>Point Konflux at your repository</li>
      <li>Get a default build pipeline</li>
      <li>See your first build succeed</li>
      <li>Understand what happened</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <img src="img/onboarding.png" width="400" alt="Onboarding UI">
  </div>
</div>

<div style="margin-top: 30px; padding: 15px; background: #f0f8ff; border-left: 4px solid #0066cc;">
  <strong>Demo:</strong> Julen will show the actual onboarding process with a real repository
</div>

---

# Hands-On: Quick Onboarding - From Zero to Building

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <img src="img/onboarding-pr.png" width="400" alt="Onboarding pull request">
  </div>
  <div style="flex: 1;">
    <img src="img/onboarding-pipeline-on-repo.png" width="400" alt="Onboarding tekton pipeline">
  </div>
</div>

---

# Hands-On: Quick Onboarding - From Zero to Building

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <img src="img/onboarding-pipeline-ui.png" width="800" alt="Onboarding pull request">
  </div>
</div>

<!--
Julen: Show the UI for onboarding a repository
Show how Konflux auto-detects the project type
Show the generated Pipelines-as-Code configuration
Emphasize how this "just works" for most projects

img/onboarding*
-->

---

# The Magic: Secure by Default

<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 300px; gap: 8px;">
      <!-- Progressive trust model - foundation -->
      <div style="background: #e6f3ff; border: 2px solid #0066cc; padding: 10px; text-align: center; font-weight: bold; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        🔐 Secure-by-Default Pipeline
      </div>
      <div style="background: #fff0e6; border: 2px solid #ff8c00; padding: 10px; text-align: center; font-weight: bold; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        📦 Trusted Artifacts
      </div>
      <div style="background: #f0e6ff; border: 2px solid #8c00ff; padding: 10px; text-align: center; font-weight: bold; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        ✅ Trusted Tasks
      </div>
      <div style="background: #e6ffe6; border: 2px solid #00cc66; padding: 10px; text-align: center; font-weight: bold; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 5px;">
        🏗️ Tekton + Kubernetes
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Instant Security Benefits</h3>
    <ul>
      <li><strong>Observer attestations:</strong> Tekton Chains generates SLSA provenance</li>
      <li><strong>Tamper detection:</strong> Artifacts signed and verified</li>
      <li><strong>Audit trail:</strong> Every step recorded</li>
      <li><strong>Policy compliance:</strong> Built-in security checks</li>
    </ul>
  </div>
</div>

<!--
Julen: Show what the developer gets automatically
This is Andrew's trust model in action
-->

---

# Hands-On: Making Your First Pipeline Changes

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🛠️ Customization</h3>
    <ul>
      <li>Pipeline lives in **your** repo</li>
      <li>Modify `.tekton/` directory</li>
      <li>Add custom build args</li>
      <li>Test changes in PRs</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <img src="img/pac-pipeline-in-repo.svg" width="400" alt="Pipeline-as-Code in repository">
  </div>
</div>

```yaml
# .tekton/build-pipeline.yaml
spec:
  params:
    - name: build-platforms
      value:
      - linux/x86_64
      - linux/arm64
    - name: build-source-image
      value: 'true'
```

<!--
Julen: Show how the pipeline configuration lives in the developer's repository
Show making a simple change like adding build arguments
Emphasize developer ownership and control
-->

---

# Hands-On: Enabling Security Tasks

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🔍 Security Integration</h3>
    <ul>
      <li>Vulnerability scanning with Snyk</li>
      <li>SAST analysis</li>
      <li>Container image scanning</li>
      <li>License compliance</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <img src="img/enable-security-tasks.svg" width="400" alt="Enabling security tasks">
  </div>
</div>

<div style="margin-top: 20px; padding: 15px; background: #fff8e1; border-left: 4px solid #ffa000;">
  <strong>Key Insight:</strong> These tasks are from the trusted task library - vetted by the community, configured by you
</div>

<!--
Julen: Show the practical configuration
These are the trusted tasks from Andrew's model
-->

---

# Hands-On: Hermetic Builds + Prefetch

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🔒 Supply Chain Hardening</h3>
    <ul>
      <li><strong>Hermetic:</strong> No network access during build</li>
      <li><strong>Prefetch:</strong> Dependencies downloaded once</li>
      <li><strong>Reproducible:</strong> Same inputs = same outputs</li>
      <li><strong>Auditable:</strong> Complete dependency record</li>
    </ul>
  </div>
</div>

```yaml
# Enable hermetic builds and prefetch
spec:
  params:
    - name: hermetic
      value: "true"
    - name: prefetch-input
      value: '{"type": "gomod", "path": "."}'
```

<!--
Julen: Demonstrate enabling hermetic builds
Show the prefetch configuration for different package managers
This is SLSA Build Level 3 in practice
-->

---

# Hands-On: Hermetic Builds + Prefetch

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <img src="img/prefetch-transient-deps.png" width="800" alt="Prefetching logs">
  </div>
</div>

---

# What Hermetic + Prefetch Gives You

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>🛡️ Security Benefits</h3>
    <ul>
      <li>No surprise downloads</li>
      <li>Complete dependency manifest</li>
      <li>Protection from typosquatting</li>
      <li>Reproducible builds</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>📊 Compliance Benefits</h3>
    <ul>
      <li>Full SBOM generation</li>
      <li>License analysis</li>
      <li>Vulnerability scanning</li>
      <li>Audit trail</li>
    </ul>
  </div>
</div>

<div style="margin-top: 30px; text-align: center; font-size: 1.2em; color: #0066cc;">
  <strong>This is SLSA Build Level 3 in action!</strong>
</div>

<!--
Julen: Show the practical developer benefit
This is where Andrew's usable security philosophy pays off
-->

---

# Hands-On: Responding to Policy Violations

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🚨 Policy Guidance</h3>
    <ul>
      <li>Violations shown in PRs</li>
      <li>Clear remediation steps</li>
      <li>Progressive enforcement</li>
      <li>Learn as you go</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <img src="img/policy-violation-pr.svg" width="400" alt="Policy violation in PR">
  </div>
</div>

<div style="margin-top: 20px; padding: 15px; background: #fce4ec; border-left: 4px solid #e91e63;">
  <strong>Gone are the days of:</strong> "I didn't know I had to do that!"
</div>

<!--
Julen: Show a real policy violation in a PR
Show how the feedback is actionable
This is Andrew's policy-driven development in practice
-->

---

# Hands-On: Automated Dependency Updates

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🤖 Mintmaker</h3>
    <ul>
      <li>Automated security updates</li>
      <li>Policy-compliant changes</li>
      <li>Tested before merging</li>
      <li>Policy-compliant updates</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <img src="img/mintmaker-pr.svg" width="400" alt="Mintmaker PR">
  </div>
</div>

```yaml
# Mintmaker finds security issues
CVE-2024-1234: High severity in dependency xyz
# Creates PR with tested fix
Updates xyz from 1.2.3 -> 1.2.4
✅ All security checks pass
✅ Policy compliance verified
```

<!--
Julen: Show a real Mintmaker PR
Explain how it's different from basic dependabot
This is proactive security maintenance
-->

---

# Hands-On: Triggering Releases

<div style="display: flex; gap: 30px; align-items: center;">
  <div style="flex: 1;">
    <h3>🚀 Release Service</h3>
    <ul>
      <li>Build once, release everywhere</li>
      <li>Environment-specific policies</li>
      <li>Automated promotion gates</li>
      <li>Complete audit trail</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <img src="img/release-promotion.svg" width="400" alt="Release promotion flow">
  </div>
</div>

<div style="margin-top: 20px; padding: 15px; background: #e8f5e8; border-left: 4px solid #4caf50;">
  <strong>The payoff:</strong> Your artifact passes all dev/staging policies? It can automatically go to production.
</div>

<!--
Julen: Show the developer experience of creating a release
This is where all the trust building pays off
-->

---

# The Complete Developer Journey

<div style="display: flex; gap: 20px; align-items: center; justify-content: center;">
  <div style="text-align: center; padding: 15px; background: #f0f8ff; border-radius: 10px; flex: 1;">
    <strong>1. Onboard</strong><br>
    Point & click
  </div>
  <div style="font-size: 2em; color: #666;">→</div>
  <div style="text-align: center; padding: 15px; background: #fff8e1; border-radius: 10px; flex: 1;">
    <strong>2. Customize</strong><br>
    Your repo, your rules
  </div>
  <div style="font-size: 2em; color: #666;">→</div>
  <div style="text-align: center; padding: 15px; background: #fce4ec; border-radius: 10px; flex: 1;">
    <strong>3. Secure</strong><br>
    Enable protections
  </div>
  <div style="font-size: 2em; color: #666;">→</div>
  <div style="text-align: center; padding: 15px; background: #e8f5e8; border-radius: 10px; flex: 1;">
    <strong>4. Release</strong><br>
    Deploy with confidence
  </div>
</div>

<div style="margin-top: 40px; text-align: center; font-size: 1.3em; color: #0066cc;">
  <strong>Security and compliance, built into your development workflow</strong>
</div>

<!--
Julen: Tie this back to the complete journey
This is the complete developer experience
-->

---

# Key Takeaways for Developers

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>🎯 What We Achieved</h3>
    <ul>
      <li><strong>Quick start:</strong> Working pipeline in minutes</li>
      <li><strong>Full control:</strong> Pipeline lives in your repo</li>
      <li><strong>Progressive security:</strong> Add protections incrementally</li>
      <li><strong>Guided compliance:</strong> Policy violations help you learn</li>
      <li><strong>Automated maintenance:</strong> Security updates handled</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>🔗 Connection to Trust Model</h3>
    <ul>
      <li>Every step builds more trust</li>
      <li>Community-contributed tasks</li>
      <li>Observer-generated attestations</li>
      <li>Policy-driven development</li>
      <li>Build once, release everywhere</li>
    </ul>
  </div>
</div>

<!--
Both: Connect the developer experience to the bigger picture
This is what it looks like when security and developer experience align
-->

---

# What's Next? Community Day Talk (June 26)

<div style="display: flex; gap: 40px; align-items: center;">
  <div style="flex: 1;">
    <h3>🔍 Deeper Dive Topics</h3>
    <ul>
      <li>Progressive trust model architecture</li>
      <li>Community contribution workflow</li>
      <li>Task promotion and sharing</li>
      <li>Policy engine implementation</li>
      <li>Real-world examples at scale</li>
    </ul>
  </div>
  <div style="flex: 1;">
    <h3>📅 Same Speakers, Different Angle</h3>
    <p>Today: <strong>Developer experience</strong></p>
    <p>Thursday: <strong>Architecture & community</strong></p>
    <br>
    <p style="background: #e3f2fd; padding: 15px; border-radius: 5px;">
      <strong>Perfect complement!</strong> See how the user experience you saw today maps to the technical architecture.
    </p>
  </div>
</div>

<!--
Set expectations for the Community Day talk
Make sure people understand these are complementary, not repetitive
-->

---

# Thank you!

<div style="text-align: center; margin: 40px 0;">
  <div style="display: flex; justify-content: center; align-items: center; gap: 60px;">
    <div style="text-align: center;">
      <div style="display: flex; align-items: center; justify-content: center; gap: 5px; margin-bottom: 10px;">
        <img src="../shared/images/github-logo.png" width="50" alt="GitHub" style="margin: 0;">
        <span style="font-size: 1.5em; font-weight: bold;">@arewm</span>
      </div>
      <div style="font-size: 1.1em;">arewm@redhat.com</div>
    </div>
    <div style="text-align: center;">
      <div style="display: flex; align-items: center; justify-content: center; gap: 5px; margin-bottom: 10px;">
        <img src="../shared/images/github-logo.png" width="50" alt="GitHub" style="margin: 0;">
        <span style="font-size: 1.5em; font-weight: bold;">@Zokormazo</span>
      </div>
      <div style="font-size: 1.1em;">julen@redhat.com</div>
    </div>
  </div>
</div>

<div style="display: flex; justify-content: center; align-items: center; gap: 100px; margin-top: 50px;">
     <div style="text-align: center;">
     <img src="../shared/images/qr-konflux-ci.png" width="250" alt="Konflux CI QR Code">
     <div style="margin-top: 10px; font-size: 0.8em;">konflux-ci.dev</div>
   </div>
   <div style="text-align: center;">
     <img src="../shared/images/qr-hermeto.png" width="250" alt="Hermeto QR Code">
     <div style="margin-top: 10px; font-size: 0.8em;">hermetoproject.github.io/hermeto</div>
   </div>
   <div style="text-align: center;">
     <img src="../shared/images/qr-conforma.png" width="250" alt="Conforma QR Code">
     <div style="margin-top: 10px; font-size: 0.8em;">conforma.dev</div>
   </div>
</div>

<!--
Questions and discussion
Connect with us for more details about implementation
Join us Thursday at OpenSSF Community Day for the architectural deep-dive!
-->
