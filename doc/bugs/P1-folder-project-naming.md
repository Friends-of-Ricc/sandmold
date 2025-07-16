I think we need to change the behaviour of folder naming.

Currently, with this config:

```yaml
apiVersion: sandmold.io/v1alpha1
kind: Classroom
metadata:
  name: ng2teachers-4realstudents
spec:
  folder:
    parent_folder_id: "194703823593"
    displayName: 2 Teachers 4 Real Students NG
```
 we have 2 things:

* TErraform naming is anchored to the `metadata.name` which is GOOD.
* Folder name is anchored to the `spec.folder.displayName` which is BAD.

## why BAD?

1. If I change anything but the metadata name, I expect TF to just rename things around, possibly even destroy projects in folder OLD and recreate them under folder "NEW". However, this is not what happens: while new folder is easily created, projects cant be created because they already exist with this name, which violates GCP project name unicity. This is against POLA as you think of a file in a folder and it's perfectly ok to copy/move/recreate a equally-named file in another folder. Well, NOT HERE.

## Solutions

1. **Better, complex** Either we output the folder_id somewhere (so "displayName: 2 Teachers 4 Real Students NG" becomes anchored to a "folderId: 12345") and we use folder_id - this would elegantly solve this by renaming folder when you rename the displayName
2. **Easier** maybe we just obsolete the `displayName` and just use the id. This would make it more solid, and we're Operators.
