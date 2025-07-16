# ✅ Classroom Provisioning Successful

## Class Details

- **Workspace Name:** `class-2teachers-4realstudents`
- **Folder Name:** [Three teachers 4 real students](https://console.cloud.google.com/cloud-resource-manager?folder=725738882201)
- **Folder ID:** `725738882201`
- **Description:** Class with 3 teachers and 4 real students

- **Teachers:** ricc@google.com, leoy@google.com, stamer@google.com
- **Student Count:** 4
- **Project Count:** 5

## ⚡ Handy Commands

```bash
# To tear down this specific classroom:
just teardown-classroom etc/samples/class_2teachers_4realstudents.yaml

# To re-provision this specific classroom:
just setup-classroom etc/samples/class_2teachers_4realstudents.yaml

# To run a preflight check on this classroom:
just preflight-check etc/samples/class_2teachers_4realstudents.yaml
```

## 🧑‍🎓 Student & Project Assignments

| Student Email | Project ID | Assigned Apps |
|---------------|------------|---------------|
| leoy@google.com | [`project-leo-ttq6`](https://console.cloud.google.com/home/dashboard?project=project-leo-ttq6) | - |
| stamer@google.com | [`daniel-7300`](https://console.cloud.google.com/home/dashboard?project=daniel-7300) | - |
| babenko@google.com | [`babenko-1eq2`](https://console.cloud.google.com/home/dashboard?project=babenko-1eq2) | - |
| palladiusbonton@gmail.com | [`ricc-personal-m6ow`](https://console.cloud.google.com/home/dashboard?project=ricc-personal-m6ow) | - |

## 🛠️ Project Details

| Project Name | Project ID | Users | Applications (Planned) |
|--------------|------------|-------|------------------------|
| babenko | [`babenko-1eq2`](https://console.cloud.google.com/iam-admin/iam?project=babenko-1eq2) | babenko@google.com | - |
| daniel | [`daniel-7300`](https://console.cloud.google.com/iam-admin/iam?project=daniel-7300) | stamer@google.com | - |
| project-leo | [`project-leo-ttq6`](https://console.cloud.google.com/iam-admin/iam?project=project-leo-ttq6) | leoy@google.com | - |
| ricc-personal | [`ricc-personal-m6ow`](https://console.cloud.google.com/iam-admin/iam?project=ricc-personal-m6ow) | palladiusbonton@gmail.com | - |
| teacherz | [`teacherz-oxst`](https://console.cloud.google.com/iam-admin/iam?project=teacherz-oxst) | ricc@google.com, palladiusbonton@gmail.com | - |

---

## ✏️ TODO: Next Steps

The core infrastructure for your classroom is now ready. The next step is to deploy the applications to the student projects.

1.  **Review the application blueprints** in the `applications/` directory.
2.  **Run the application deployment stage** (currently under development).
