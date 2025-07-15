
## as ricc


```bash
$ just open-baids
🔎 Searching for open, non-Google billing accounts...
ACCOUNT_ID            NAME                                         PARENT
016828-2CF7FA-17B3DD  SREDemo Billing Account                      organizations/791852209422
01C588-4823BC-27F650  Google Cloud Platform Trial Billing Account
01D25F-B9D075-CD7A61  Cloud Deploy billing                         organizations/372096757005
```


## as PBT


As admin@sredemo.dev i need to execute this:

```bash
 gcloud resource-manager folders add-iam-policy-binding 1000371719973 \
      --member="user:palladiusbonton@gmail.com" \
      --role="roles/resourcemanager.folderAdmin"

gcloud resource-manager folders add-iam-policy-binding 1000371719973 \
 --member="user:palladiusbonton@gmail.com" \
 --role="roles/resourcemanager.projectCreator"

#   Command: Grant Billing Account User Role
gcloud billing accounts add-iam-policy-binding 0103D2-91481A-505127 \
--member="user:palladiusbonton@gmail.com" \
    --role="roles/billing.user"

```
