# SaaS Runtime Entity Relationship Diagram

This diagram illustrates the relationships between the core components of the SaaS Runtime.

## Key Entities

*   **SaaS Offering**: The top-level service being offered. It acts as a container for different kinds of units.
*   **Unit Kind (UK)**: Defines a *type* of resource or service that can be provisioned (e.g., a VM, a database, a full application stack).
*   **Release**: A specific, immutable, versioned snapshot of the configuration (the "Blueprint") for a Unit Kind. You deploy a specific release.
*   **Blueprint**: The package containing the Infrastructure-as-Code (IaC) configuration, typically built from a Terraform module. It's the "how-to" guide for creating a resource.
*   **Unit**: An actual, running instance of a Unit Kind, provisioned from a specific Release.
*   **Terraform Module**: The source code (Terraform `.tf` files) that defines the infrastructure to be created.

## Mermaid ER Diagram

```mermaid
erDiagram
    SAAS_OFFERING {
        string name "The name of the overall service"
        string location "The primary location of the offering"
        string supported_locations "List of locations for units"
    }
    UNIT_KIND {
        string name "e.g., 'sandmold-sample-vm'"
        string default_release "The default release for new units"
    }
    RELEASE {
        string version "e.g., 'v1.0.0'"
    }
    BLUEPRINT {
        string source "Path to Terraform code"
    }
    UNIT {
        string name "e.g., 'my-test-vm'"
    }
    TERRAFORM_MODULE {
        string path "e.g., 'terraform-modules/terraform-vm'"
    }

    SAAS_OFFERING ||--o{ UNIT_KIND : "Defines"
    UNIT_KIND ||--o{ RELEASE : "Has"
    UNIT_KIND ||--o{ UNIT : "Instantiates"
    RELEASE }|..|{ BLUEPRINT : "Is created from"
    BLUEPRINT }|..|{ TERRAFORM_MODULE : "Is built from"
    UNIT }|..|| RELEASE : "Is provisioned from"
```

## Dependencies and Caveats

The relationships imply the following dependencies:

*   A **Unit** depends on a **Unit Kind** (to define its type) and a **Release** (to define its versioned configuration).
*   A **Release** depends on a **Unit Kind** (it's a release *of* that kind) and a **Blueprint** (which contains the configuration).
*   A **Blueprint** depends on a **Terraform Module** (the source code).
*   A **Unit Kind** depends on a **SaaS Offering** (its parent container).

### ⚠️ Circular Dependency between Unit Kind and Release

There is a potential for a confusing circular relationship:

*   A **Unit Kind** can have a `default_release`.
*   A **Release** must belong to a **Unit Kind**.

This can create a "chicken-and-egg" problem during initial setup. You can't create a Release without a Unit Kind, and you can't set the default release on a Unit Kind until the Release exists.

```mermaid
graph TD
    A[Unit Kind] -- has a default --> B(Release);
    B -- belongs to --> A;
```

The solution is to first create the Unit Kind *without* a default release, then create the Release, and finally, update the Unit Kind to set the newly created release as the default.
