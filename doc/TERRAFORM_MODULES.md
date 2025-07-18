# Terraform Modules Overview

This document provides a high-level overview of the Terraform modules used in the Sandmold project. These modules are designed to be modular and composable, allowing for flexible setup of Google Cloud environments.

## Core Workflow

The Terraform workflow is divided into two main stages:

1.  **Infrastructure Setup**: Provisioning of Google Cloud projects and folders.
2.  **Application Deployment**: Deployment of applications into the provisioned projects.

The infrastructure setup can be done in two ways:

*   **`1a_classroom_setup`**: For setting up a full classroom environment with multiple students.
*   **`1b_single_user_setup`**: For a single user to set up a single project.

The output of both `1a` and `1b` is a consistent data structure that is used as input for the `2_apps_deployment` stage.

### Conceptual Execution Flow

The execution flow starts with a choice between two alternative setup methods, which both produce a common data structure that is used for the subsequent deployment stage.

#### **Stage 1: Infrastructure Setup (Choose A or B)**

<table>
  <tr>
    <th><code>1a_classroom_setup</code> (Alternative A)</th>
    <th><code>1b_single_user_setup</code> (Alternative B)</th>
  </tr>
  <tr>
    <td valign="top">A <code>classroom.yaml</code> file defining a folder, billing, and multiple "schoolbenches" (projects).
      <pre><code># INPUT for 1a (classroom.yaml)
folder:
  parent_folder_id: "123456789012"
  billing_account_id: "012345-67890A-BCDEF0"
schoolbenches:
  - name: "student-project-01"
    owners:
    - student1@example.com
    - prof@example.com
    apps:
    - app1
    - app2
  - name: student-project-01
    owners:
    - student2@example.com
    - prof@example.com
    apps:
    - app3
</code></pre>
    </td>
    <td valign="top">A simple <code>terraform.tfvars</code> file or equivalent YAML defining a single project.
      <pre><code># Sample INPUT for module 1b (single-user.yaml)
billing_account_id: "012345-67890A-BCDEF0"
project_id_suffix: "my-single-project"
user_email: "workshop-single-user@example.com"
applications:
- app1
- app4
</code></pre>
    </td>
  </tr>
</table>


#### **Common Output (from Stage 1) / Input (for Stage 2)**

Both `1a` and `1b` produce a structured map of the created projects. This serves as the common input for the next stage.

```yaml
# This is the common data structure passed to Stage 3
projects:
  student-project-a1b2:
    project_id: "student-project-a1b2"
    project_number: "112233445566"
    user_emails: ["student1@example.com"]
    applications: ["app1", "app2"]
  research-project-c3d4:
    project_id: "research-project-c3d4"
    project_number: "778899001122"
    user_emails: ["student2@example.com", "prof@example.com"]
    applications: ["app3"]
```
---

#### **Stage 2: Application Deployment**

**Module: `2_apps_deployment`**

This module receives the `projects` map from the previous stage and orchestrates the deployment of the specified applications into each project.

---

#### **Stage 4: Final Output**

The final output is a report detailing the deployment status for each application in each project.

```yaml
# Final deployment status report
deployment_status:
  student-project-a1b2:
    app1: "SUCCESS"
    app2: "FAILED: Timeout"
  research-project-c3d4:
    app3: "SUCCESS"
```

This modular design allows for a clear separation of concerns between infrastructure provisioning and application deployment. The consistent interface between the setup and deployment stages ensures that application deployment logic can be reused regardless of the initial setup method.

## Open points

* [Riccardo] I'm considering adding a step 0 to set up Terraformm properly. See https://github.com/Friends-of-Ricc/sandmold/issues/22 CUJ01
* [Riccardo] I'm still unsure if step 2 should be TF, bash, or a mix of the 2 (`local-exec`).
* [Riccardo] The 1 -> 2 is not mirroring the FAST approach described and auspicated in https://github.com/Friends-of-Ricc/sandmold/issues/22 CUJ02
