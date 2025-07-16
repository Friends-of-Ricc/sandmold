# ✅ Classroom Provisioning Successful

## Class Details

- **Workspace Name:** `class-2teachers-6students`
- **Folder Name:** [2 teachers and 3x2 students](https://console.cloud.google.com/cloud-resource-manager?folder=294669364638)
- **Folder ID:** `294669364638`
- **Description:** Class with 2 teachers and 6 students,
2 students per bench (in team).

- **Teachers:** leoy@google.com, ricc@google.com
- **Student Count:** 6
- **Project Count:** 4

## ⚡ Handy Commands

```bash
# To tear down this specific classroom:
just classroom-down etc/samples/class_2teachers_6students.yaml

# To re-provision this specific classroom:
just classroom-up etc/samples/class_2teachers_6students.yaml

# To run a preflight check on this classroom:
just classroom-inspect etc/samples/class_2teachers_6students.yaml
```

## 🧑‍🎓 Student & Project Assignments

| Student Email | Project ID | Assigned Apps |
|---------------|------------|---------------|
| student01@gmail.com | [`heapster01-yswf`](https://console.cloud.google.com/home/dashboard?project=heapster01-yswf) | - |
| student02@gmail.com | [`heapster01-yswf`](https://console.cloud.google.com/home/dashboard?project=heapster01-yswf) | - |
| student03@gmail.com | [`heapster02-o8cs`](https://console.cloud.google.com/home/dashboard?project=heapster02-o8cs) | - |
| student04@gmail.com | [`heapster02-o8cs`](https://console.cloud.google.com/home/dashboard?project=heapster02-o8cs) | - |
| student06@gmail.com | [`heapster03-rpsr`](https://console.cloud.google.com/home/dashboard?project=heapster03-rpsr) | - |
| palladiusbonton@gmail.com | [`heapster03-rpsr`](https://console.cloud.google.com/home/dashboard?project=heapster03-rpsr) | - |

## 🛠️ Project Details

| Project Name | Project ID | Users | Applications (Planned) |
|--------------|------------|-------|------------------------|
| heapster01 | [`heapster01-yswf`](https://console.cloud.google.com/iam-admin/iam?project=heapster01-yswf) | student01@gmail.com, student02@gmail.com | - |
| heapster02 | [`heapster02-o8cs`](https://console.cloud.google.com/iam-admin/iam?project=heapster02-o8cs) | student03@gmail.com, student04@gmail.com | - |
| heapster03 | [`heapster03-rpsr`](https://console.cloud.google.com/iam-admin/iam?project=heapster03-rpsr) | student06@gmail.com, palladiusbonton@gmail.com | - |
| teacherz | [`teacherz-zbpc`](https://console.cloud.google.com/iam-admin/iam?project=teacherz-zbpc) | leoy@google.com, ricc@google.com | bank-of-anthos, sandmold-web |

---

## ✏️ TODO: Next Steps

The core infrastructure for your classroom is now ready. The next step is to deploy the applications to the student projects.

1.  **Review the application blueprints** in the `applications/` directory.
2.  **Run the application deployment stage** (currently under development).
