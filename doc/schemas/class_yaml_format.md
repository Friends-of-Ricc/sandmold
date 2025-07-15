# Classroom YAML Schema Definition (sandmold.io/v1alpha1)

To ensure consistency, versioning, and clarity, classroom configuration files follow a Kubernetes-style object structure. Every classroom YAML must contain the following top-level fields:

- `apiVersion`: The version of the schema. For now, this must be `sandmold.io/v1alpha1`.
- `kind`: The type of object. This must be `Classroom`.
- `metadata`: Data that helps uniquely identify the object, such as its name and labels.
- `spec`: The detailed specification for the desired state of the classroom.

---

## Example

```yaml
apiVersion: sandmold.io/v1alpha1
kind: Classroom
metadata:
  name: class-2teachers-6students
  labels:
    class: class_2teachers_6
    author: ricc
spec:
  folder:
    # ... folder details ...
  schoolbenches:
    # ... schoolbenches details ...
  common:
    # ... common details ...
```

---

## 1. `apiVersion` (string, mandatory)

The API version for this object.
- **Value**: Must be `sandmold.io/v1alpha1`.

## 2. `kind` (string, mandatory)

The kind of object this file represents.
- **Value**: Must be `Classroom`.

## 3. `metadata` (object, mandatory)

Contains metadata for the classroom.
- `name` (string, mandatory): The name of the classroom. This should be unique and is used for identification.
- `labels` (object, optional): A map of key-value pairs to apply as labels to the classroom resources.

## 4. `spec` (object, mandatory)

The specification for the classroom setup. This contains all the configuration details.

### `spec.folder` (object, mandatory)

Contains the high-level classroom fields.
- `org_id` (numeric, mandatory): The numeric ID of the Google Cloud organization.
- `domain` (string, mandatory): The domain of the organization (e.g., `sredemo.dev`).
- `parent_folder_id` (string, mandatory): The ID of the folder or organization under which the classroom will be created.
- `billing_account_id` (string, mandatory): The billing account ID to associate with the projects.
- `description` (string, mandatory): A user-friendly description of the classroom's purpose.
- `teachers` (list of strings, mandatory): A list of teacher email addresses.
- `env` (list of objects, optional): A list of environment variables to set. Each object must have `name` and `value` string keys.
- `labels` (list of objects, optional): A list of labels to apply. Each object must have `key` and `value` string keys.

### `spec.schoolbenches` (list of objects, mandatory)

Contains an array of "school benches," where each bench represents one or more students sharing a project.
- `project` (string, mandatory): The base name for the Google Cloud project. A random suffix will be added to ensure uniqueness. Must not contain underscores.
- `desk-type` (string, optional): The type of desk. Can be `student` (default) or `teacher` (for the "cattedra").
- `seats` (list of strings, mandatory): A list of student email addresses for this bench.
- `apps` (list of strings, optional): A list of application names to deploy for this bench.
- `app` (string, optional): Syntactic sugar for a single application in the `apps` list.

### `spec.common` (object, optional)

A convenience stanza to apply common configuration to all schoolbenches, reducing repetition.
- `schoolbenches`:
  - `foreach_project`:
    - `applies_to` (string, mandatory): Specifies which benches to apply the common config to. Must be `ALL_STUDENTS` or `ALL`.
    - `apps` (list of strings, optional): A list of apps to add to every bench.
    - `seats` (list of strings, optional): A list of users to add to every bench.