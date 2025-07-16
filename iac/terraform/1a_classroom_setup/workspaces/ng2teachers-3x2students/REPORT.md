# ✅ Classroom Provisioning Successful

## Class Details

- **Workspace Name:** `ng2teachers-3x2students`
- **Folder Name:** [ng2teachers-3x2students](https://console.cloud.google.com/cloud-resource-manager?folder=115314039773)
- **Folder ID:** `115314039773`
- **Description:** Class with 2 teachers and 6 students,
2 students per bench (in team).

- **Teachers:** leoy@google.com, ricc@google.com
- **Student Count:** 6
- **Project Count:** 4

## ⚡ Handy Commands

```bash
# To tear down this specific classroom:
just teardown-classroom etc/samples/class_2teachers_6students.yaml

# To re-provision this specific classroom:
just setup-classroom etc/samples/class_2teachers_6students.yaml

# To run a preflight check on this classroom:
just preflight-check etc/samples/class_2teachers_6students.yaml
```

## 🧑‍🎓 Student & Project Assignments

| Student Email | Project ID | Assigned Apps |
|---------------|------------|---------------|
| student01@gmail.com | [`N/A`](https://console.cloud.google.com/home/dashboard?project=N/A) | - |
| student02@gmail.com | [`N/A`](https://console.cloud.google.com/home/dashboard?project=N/A) | - |
| student03@gmail.com | [`N/A`](https://console.cloud.google.com/home/dashboard?project=N/A) | - |
| student04@gmail.com | [`N/A`](https://console.cloud.google.com/home/dashboard?project=N/A) | - |
| student06@gmail.com | [`N/A`](https://console.cloud.google.com/home/dashboard?project=N/A) | - |
| palladiusbonton@gmail.com | [`N/A`](https://console.cloud.google.com/home/dashboard?project=N/A) | - |

## 🛠️ Project Details

| Project Name | Project ID | Users | Applications (Planned) |
|--------------|------------|-------|------------------------|
| std-heapster01 | [`std-heapster01-nw4m`](https://console.cloud.google.com/iam-admin/iam?project=std-heapster01-nw4m) | N/A | - |
| std-heapster02 | [`std-heapster02-322n`](https://console.cloud.google.com/iam-admin/iam?project=std-heapster02-322n) | N/A | - |
| std-heapster03 | [`std-heapster03-l0mo`](https://console.cloud.google.com/iam-admin/iam?project=std-heapster03-l0mo) | N/A | - |
| tch-teacherz | [`tch-teacherz-lqij`](https://console.cloud.google.com/iam-admin/iam?project=tch-teacherz-lqij) | N/A | - |

---

## ✏️ TODO: Next Steps

The core infrastructure for your classroom is now ready. The next step is to deploy the applications to the student projects.

1.  **Review the application blueprints** in the `applications/` directory.
2.  **Run the application deployment stage** (currently under development).
