
## Code structure

I expect all the IAC code to be under iac/technology/ `iac/pulumi/` or `iac/terraform/`.

The system allows some pluggable applications. Every app should have some standard blueprint k8s-like yaml.

## Architecture

* a Lab has metadata and multiple seats. A lab maps to a Cloud Folder.
* a Seat has multiple Principals (users) and Applications.
* An applicaion can participate in a seat in max cardinality of 1.

For instance, 

## Seat

A seat is the atom of appplication + user

## Applications

Every application maps to a single project. So a lab can have 10 "seat" instances.


## Terraform vs Pulumi

Terraform is the idustry standard, so we'd lean into using TF. However, if we see that our use cases are too complex (too many if/then/else) in TF, we can defer to a more solid Pulumi (language of choice would be `Python`).




## Example

When the `./setup_lab.sh --yaml config.yaml` script is called with a YAML like this:

```yaml
# yaml dammit YAML support!!!!!
folder:
  org_id: 3462375241231423
  parent_folder_id: 3462375241231423 # same as org_id - root folder
  name: class_2teachers_6students
  description: Class with 2 teachers and 6 students
  #billing_account: 012345-678901-234567 # dummy billing account
#  labels:
#    class: class_2teachers_6
  domain: google.com
apps:
  - app: heapster_shop
    project: teacherz  # will be padded by some random hex/numb
    users:
    - leoy@google.com
    - ricc@google.com
  - app: bank_of_anthos
    project: boa01  # will be padded by some random hex/numb
    users:
    - student01@gmail.com
    - student02@gmail.com
  - app: bank_of_anthos
    project: boa02
    users:
    - student03@gmail.com
    - student04@gmail.com
  - app: cheap_jss
    project: boa03
    users:
    - student05@gmail.com
    - student06@gmail.com
```

we expect the following to happen:

1.
