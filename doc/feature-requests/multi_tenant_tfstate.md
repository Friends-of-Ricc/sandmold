## FR001 - Make TFSTATE multi-tenant

Now, if I call `just setup-classroom CLASSROOM1.YAML` it all works.
But when I then call `just setup-classroom CLASSROOM2.YAML` , terraform sees a different states and probably tries to destroy the old and create the new, like I've edited the existing yaml.

We need to have some sort of naming convention, so that every time I call the script with a dfifferent YAML file it should have a different tfstate.
* As long as tfstate is in LOCAL FILE , the best idea seems to create a folder with a field which is unique in the yaml (eg `folder/name`).
* When we'll move to GCS, we could also have same bucket and different folder.

Make sure to migrate existing tfstate to the migrated one (subfolder or workflow).

Make a plan before implementing, and wait for user to confirm its good.


## Output and TFVARS and Report

All these files need to be multi tennant.

1. iac/terraform/1a_classroom_setup/terraform_output.json
2. iac/terraform/1a_classroom_setup/terraform.tfvars.json
3. REPORT.md
