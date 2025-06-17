# Let devs be devs without sacrificing security

Andrew McNamara; Red Hat


---


# Devs need to be protected from threats

<img src="../shared/diagrams/slsa-supply-chain-threats.png" width="600" alt="SLSA supply chain threats">

<small>Source: https://slsa.dev/spec/v1.1/threats-overview</small>


---


# What does it mean to be a developer?

Build off of open source software

Troubleshoot their builds

Explore new problem spaces and solutions

Use tooling that is supportive not disruptive

<!--

Background: this is the journey that we have been making at Red Hat, we extensively use open source software

These are some of the key metrics that I see for developers. This isn't always the case though, especially when open source software is being consumed in more closed environments. I want to share some lessons which are grounded in some of my experiences.
-->

---


# Devs want to easily build artifacts

<div style="display: flex; align-items: center; gap: 20px;">
  <img src="img/dev-workflow-icon.png" width="400" alt="Developer workflow icon">
  <img src="img/dev-build-process-chain.png" width="400" alt="Build process chain">
</div>

<!--

Building software artifacts can be easy (i.e. project maintainer). Securely building software artifacts is much harder (i.e. enterprise support). Requirements imposed are different: what works vs. what meets compliance policy

Graphics: committing code; github actions; release -> chain of events in build process

Call out the different ownership, pipeline changes are usually made by someone else with their own priorities
-->

---


# Devs want to troubleshoot builds

<div style="display: flex; align-items: center; gap: 20px;">
  <img src="img/dev-workflow-icon.png" width="400" alt="Developer workflow icon">
  <img src="img/dev-troubleshoot-system.png" width="400" alt="Troubleshoot system">
</div>

<!--

What if you need to troubleshoot a build in the build system?

Modify the build command locally, resubmit job
Vs. 
Hope that there is sufficient logging? Try to replicate the build system locally?
-->



---


# Devs want to explore new tech

<div style="display: flex; align-items: center; gap: 20px;">
  <img src="img/dev-workflow-icon.png" width="400" alt="Developer workflow icon">
  <img src="img/dev-explore-pipelines.png" width="400" alt="Explore pipelines">
</div>

<!--

What happens if you want to explore something new?

Fork, reconfigure for build configuration, commit

More pipelines, waiting for someone else to complete the work. - wait, does this pipeline have support? Is it compliant? How do we audit all of these pipelines or deprecate the old ones?
-->




---


# Devs don't need to be this unhappy

SLSA Build L3:

Harden the build platform

Generate provenance

![](../shared/images/slsa-favicon.png)

<!--

Who has heard of SLSA build track? I have been asked many questions about what to do with transparency into the build process whether provenance or SBOMs. Producing provenance might be helpful for consumers. SBOMs might be helpful for meeting regulations.  But why not take advantage of it for yourself with detailed provenance?
-->


---


<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Empty placeholders for future layers -->
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <!-- Foundation layer -->
      <div style="background: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        K8s + Tekton
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Foundation Platform</h3>
    <p>Kubernetes provides RBAC, containerization, and namespace isolation. Tekton provides the pipeline execution framework.</p>
    <img src="../shared/logos/tekton.png" width="200" alt="Tekton" style="margin-top: 20px;">
  </div>
</div>


---


<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Empty placeholders for future layers -->
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <!-- Trusted Task Library layer -->
      <div style="background: #ffcccc; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Task Library
      </div>
      <!-- Foundation layer -->
      <div style="background: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        K8s + Tekton
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Secure Task Library</h3>
    <p>A library of tasks providing common and critical functions which need to be secure and auditable.</p>
    <img src="img/konflux-trusted-tasks.png" width="400" alt="Konflux trusted tasks" style="margin-top: 20px;">
  </div>
</div>


---


<img src="img/konflux-architecture-overview.png" width="700" alt="Konflux architecture overview">


---


<img src="img/konflux-trusted-tasks.png" width="600" alt="Konflux trusted tasks">


---


<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Empty placeholders for future layers -->
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <!-- Trusted Artifacts layer -->
      <div style="background: #ff9999; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Artifacts
      </div>
      <!-- Trusted Task Library layer -->
      <div style="background: #ffcccc; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Task Library
      </div>
      <!-- Foundation layer -->
      <div style="background: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        K8s + Tekton
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Trusted Artifacts</h3>
    <p>A method of sharing data between tasks which allows detection of data alterations.</p>
    <img src="img/konflux-trusted-artifacts.png" width="400" alt="Konflux trusted artifacts" style="margin-top: 20px;">
  </div>
</div>

<!--

Konflux does not directly implement any security checks. Instead it uses tasks that call established tools like Snyk, Clair, ACS, ClamAV etc. The task library is where tool integrations happen and are the main path for user customization and potentially even commercial partnerships.
-->

---


<img src="img/konflux-trusted-artifacts.png" width="600" alt="Konflux trusted artifacts">


---


<img src="img/konflux-observer-attestations.png" width="600" alt="Konflux observer attestations">


---


<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Empty placeholders for future layers -->
      <div style="height: 50px;"></div>
      <div style="height: 50px;"></div>
      <!-- Observer Generated Attestations layer -->
      <div style="background: #ff6666; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Observer Generated Attestations
      </div>
      <!-- Trusted Artifacts layer -->
      <div style="background: #ff9999; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Artifacts
      </div>
      <!-- Trusted Task Library layer -->
      <div style="background: #ffcccc; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Task Library
      </div>
      <!-- Foundation layer -->
      <div style="background: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        K8s + Tekton
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Observer Generated Attestations</h3>
    <p>Attestations are generated separately from the pipeline (by an 'observer') so they cannot be influenced by the user.</p>
    <img src="img/konflux-observer-attestations.png" width="400" alt="Konflux observer attestations" style="margin-top: 20px;">
  </div>
</div>

<!--

Tekton Chains was the first attestation generation service to use the 'observer' pattern, and this heavily influenced the design of Konflux. There is no reason this cannot be implemented for other CI / pipeline systems as well, but to date it has not been done.
-->

---


![](../shared/diagrams/tekton-chains-how-it-works.png)

# https://tekton.dev/docs/chains/slsa-provenance/#how-does-tekton-chains-work


---


<img src="img/konflux-policy-engine.png" width="600" alt="Konflux policy engine">


---


<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Empty placeholder for future layer -->
      <div style="height: 50px;"></div>
      <!-- Policy Engine layer -->
      <div style="background: #ff3333; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Policy Engine
      </div>
      <!-- Observer Generated Attestations layer -->
      <div style="background: #ff6666; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Observer Generated Attestations
      </div>
      <!-- Trusted Artifacts layer -->
      <div style="background: #ff9999; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Artifacts
      </div>
      <!-- Trusted Task Library layer -->
      <div style="background: #ffcccc; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Task Library
      </div>
      <!-- Foundation layer -->
      <div style="background: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        K8s + Tekton
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Policy Engine</h3>
    <p>A policy engine is used to compare the attestations against required policy (we use <a href="https://conforma.dev/">Conforma</a>).</p>
    <img src="../shared/logos/conforma-screenshot.png" width="400" alt="Conforma screenshot" style="margin-top: 20px;">
  </div>
</div>

<!--

Policies can precisely define things which need to be true about pipeline runs that produce artifacts. For example, that a specific task must be included, and optionally what the result of that task was. That specific tasks must not be included, that trusted artifacts are not modified before being input to specific tasks, that designated dependencies are not used, or are newer than a specified version… lots and lots of possibilities. 
-->

---


<div style="display: flex; align-items: center; gap: 20px;">
  <img src="img/policy-base-images-example.png" width="300" alt="Policy base images example">
  <img src="../shared/logos/conforma-screenshot.png" width="300" alt="Conforma screenshot">
  <img src="img/base-images-icon.png" width="300" alt="Base images icon">
</div>

Allowed base images


---


<div style="display: flex; align-items: center; gap: 20px;">
  <img src="img/policy-violations-screenshot.png" width="300" alt="Policy violations screenshot">
  <img src="img/base-images-icon.png" width="300" alt="Base images icon">
  <img src="img/base-images-icon-3.png" width="300" alt="Base images icon variant">
</div>

Allowed base images


---


<div style="display: flex; gap: 40px; align-items: flex-start;">
  <div style="flex: 1;">
    <div style="display: flex; flex-direction: column; justify-content: center; height: 400px; gap: 10px;">
      <!-- Release Service layer (complete model) -->
      <div style="background: #cc0000; color: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Release Service
      </div>
      <!-- Policy Engine layer -->
      <div style="background: #ff3333; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Policy Engine
      </div>
      <!-- Observer Generated Attestations layer -->
      <div style="background: #ff6666; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Observer Generated Attestations
      </div>
      <!-- Trusted Artifacts layer -->
      <div style="background: #ff9999; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Artifacts
      </div>
      <!-- Trusted Task Library layer -->
      <div style="background: #ffcccc; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        Trusted Task Library
      </div>
      <!-- Foundation layer -->
      <div style="background: white; border: 2px solid #333; padding: 15px; text-align: center; font-weight: bold; width: 100%; height: 50px; display: flex; align-items: center; justify-content: center;">
        K8s + Tekton
      </div>
    </div>
  </div>
  <div style="flex: 1;">
    <h3>Release Service</h3>
    <p>Release service gates access to protected destinations based on policy evaluation.</p>
    <img src="../shared/logos/konflux.png" width="300" alt="Konflux logo" style="margin-top: 20px;">
  </div>
</div>


---


# Devs can easily build artifacts

![](img/onboard-repository-screenshot.png)

<!--

Onboard the source repository and customize the pipeline parameters.

If the policy required the onboarded pipeline, you can release right away. Otherwise, you can customize the parameters and/or repository to get the policies in-compliance with the help of the EC policy violations. Policy-driven-development.

Screenshot: PR of PAC changes being proposed

Talking points: 
Start with a sample pipeline
Iteration with policy-driven development based on target (show two checks, each for a different policy?)
-->



---


![](img/pac-changes-pr-proposal.png)

<!--

Onboard the source repository and customize the pipeline parameters.

If the policy required the onboarded pipeline, you can release right away. Otherwise, you can customize the parameters and/or repository to get the policies in-compliance with the help of the EC policy violations. Policy-driven-development.

Screenshot: PR of PAC changes being proposed

Talking points: 
Start with a sample pipeline
Iteration with policy-driven development based on target (show two checks, each for a different policy?)
-->



---


# Devs can troubleshoot builds

![](img/troubleshoot-pr-screenshot.png)

<!--

Screenshot of PR customizing the build

Talking points: 
You have your pipeline, you can see the tasks that are run
Change from a tekton resolver to in-line the task
Iterate on the failing step to troubleshoot
Don't worry – these will fail EC if the build or critical tests are modified


Modify the build command locally, resubmit job

If any of the critical tasks have been modified, potentially compromising the guarantees, the artifacts won't be able to be released
-->



---


__$ oras manifest fetch \-\-pretty quay\.io/konflux\-ci/tekton\-catalog/task\-buildah\-remote\-oci\-ta:0\.4 | jq \.annotations__

__\{__

__  "dev\.konflux\-ci\.task\.previous\-migration\-bundle": "",__

__  "org\.opencontainers\.image\.description": "Buildah task builds source code into a container image and pushes the image into container registry using buildah tool\.",__

__  "org\.opencontainers\.image\.documentation": "https://github\.com/konflux\-ci/build\-definitions/tree/75741ae0dbd0e3ffa0414acc7fbc950740e889ae/task/buildah\-remote\-oci\-ta/0\.4/README\.md",__

__  "org\.opencontainers\.image\.revision": "75741ae0dbd0e3ffa0414acc7fbc950740e889ae",__

__  "org\.opencontainers\.image\.source": "https://github\.com/konflux\-ci/build\-definitions",__

__  "org\.opencontainers\.image\.url": "https://github\.com/konflux\-ci/build\-definitions/tree/75741ae0dbd0e3ffa0414acc7fbc950740e889ae/task/buildah\-remote\-oci\-ta/0\.4",__

__  "org\.opencontainers\.image\.version": "0\.4"__

__\}__

<!--

Screenshot of PR customizing the build

Talking points: 
You have your pipeline, you can see the tasks that are run
Change from a tekton resolver to in-line the task
Iterate on the failing step to troubleshoot
Don't worry – these will fail EC if the build or critical tests are modified


Modify the build command locally, resubmit job

If any of the critical tasks have been modified, potentially compromising the guarantees, the artifacts won't be able to be released
-->



---


# Devs can explore new tech

![](img/explore-custom-tasks-screenshot.png)

<!--

Talking points: 
You have your pipeline, you can customize it with your own tasks
Don't worry – these will fail EC if the build or critical tests are modified
Functionality can be expanded by adding to the trusted tasks … and performing necessary reviews of those additions. Tasks need to adhere to naming conventions (i.e. parameter/results)


Fork the project, reconfigure for build environment (maybe create a new Task or two), commit. Push this to your own registries, use it in personal or dev deployments. It won't get to production until the pipelines are approved
-->



---


# Devs don't need to be this unhappy

<div style="display: flex; align-items: center; justify-content: center; gap: 30px; margin-bottom: 20px;">
  <img src="../shared/logos/tekton.png" width="200" alt="Tekton">
  <img src="../shared/logos/tekton-chains.png" width="200" alt="Tekton Chains">
  <img src="../shared/logos/pipelines-as-code.png" width="200" alt="Pipelines as Code">
  <img src="../shared/logos/conforma.png" width="200" alt="Conforma">
</div>

<div style="text-align: center; margin: 30px 0;">
  <div style="font-size: 8em; transform: rotate(90deg) scaleY(6); color: #666; line-height: 0.1; font-weight: lighter;">}</div>
</div>

<div style="text-align: center;">
  <img src="../shared/logos/konflux-banner.png" width="500" alt="Konflux">
</div>


---


# Thank you!

<div style="text-align: center; margin: 40px 0;">
  <div style="display: flex; justify-content: center; align-items: center; gap: 5px; margin-bottom: 20px;">
         <img src="../shared/logos/github.png" width="50" alt="GitHub" style="margin: 0;"><span style="font-size: 1.5em; font-weight: bold; ">@arewm</span>
  </div>
  <div style="font-size: 1.2em;">
    arewm@redhat.com
  </div>
</div>

<div style="display: flex; justify-content: center; align-items: center; gap: 60px; margin-top: 50px;">
  <div style="text-align: center;">
    <img src="../shared/qr-codes/konflux-ci.png" width="200" alt="Konflux CI QR Code">
    <div style="margin-top: 15px; font-size: 0.9em;">konflux-ci.dev</div>
  </div>
  <div style="text-align: center;">
    <img src="../shared/qr-codes/hermeto.png" width="200" alt="Hermeto QR Code">
    <div style="margin-top: 15px; font-size: 0.9em;">hermetoproject.github.io/hermeto</div>
  </div>
  <div style="text-align: center;">
    <img src="../shared/qr-codes/conforma.png" width="200" alt="Conforma QR Code">
    <div style="margin-top: 15px; font-size: 0.9em;">conforma.dev</div>
  </div>
</div>

