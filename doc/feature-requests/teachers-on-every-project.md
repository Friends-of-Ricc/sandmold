## Feature Request

Extend the capabilities of the code.

1. Allow the folder: stanza to have teachers under it.

```yaml
folder:
  ...
  teachers:
  - teacher1@example.com
  - teacher2@example.com
```

2. If that's the case, ensure the teachers are embedded in EVERY other project.

3. Their IAM profiles is described in `etc/project_config.yaml`. In particular:
    1. Use IAM roles in  `teacher_roles_in_teacher_project` for teachers project.
    2. Use IAM roles in  `teacher_roles_in_tenant_project` for all students (tenant) project.
