
## Code structure

I expect all the IAC code to be under `iac/terraform/`.

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

Terraform is the industry standard, so we'd lean into using TF. However, if we see that our use cases are too complex (too many if/then/else) in TF, we can defer to a more solid Pulumi (language of choice would be `Python`).

Let's start with Terraform for now.

## Multi-vs-single mode (**IMPORTANT**)

The setup needs to be modular enough so we can both run it in FOLDER + N_projects mode and in "single user, single project mode".

So we need to both be able to have:
* **CUJ001** (folder mode, pre-created). In this mode, we create a folder, and we provision N projects under a folder based on a YAML. This is good when you want to pre-provision the classroom before meeting with those people. Student X finds themselves they have access to project X with their pre-known user account.
* **CUJ002** (single mode, BYOI). In this mode, we do not provision anything beforehand. The user is given the isntructions and configuration needed to create a project with credit under their own org. In this case, we
  * This is useful when we don't know the identity of the student so they "bring your own identity".
  * In this case, we need for this to be VERY easy and simple for users to create project and install apps on top of it. Some functionalities (like shared observability) will NOT be available.


## Outputs

We need to see projects created and students associated in the final output variable.
Would be nice to have an output README.md which contains a markdown table of projects / students/ apps associations.

## Example

When the `./setup_lab.sh --yaml config.yaml` script is called with a YAML like this:

```yaml
# yaml dammit YAML support!!!!!
folder:
  org_id: 3462375241231423
  parent_folder_id: 3462375241231423 # same as org_id - root folder
  name: class_2teachers_6students
  description: Class with 2 teachers and 6 students
  billing_account: 012345-678901-234567 # dummy billing account
#  labels:
#    class: class_2teachers_6
  domain: sredemo.dev
  teachers:
  - leoy@google.com
  - ricc@google.com
apps:
  - app: heapster_shop
    project: teacherz  # will be padded by some random hex/numb
    description: This is just for the teachers to demo the app before students do the codelab.
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

We expect the following to happen:

1. A folder is setup, WITH INFO FROM `folder` stanza.
2. 4 projects are created with proper name and users. If some users dont exist, it should throw an error.
3. Each project should have teachers under `folder.teachers` as additional owners. This can be implemented at project level or folder level - you choose. Folder level seems DRYer.
4. Apps are installed on top of each project. This is done at a future stage. If an app fails, project stays.
5. A final report should show what worked and what didn't (eg "project boa03 couldnt be created since student06@gmail.com doesnt exist", and "bank_of_anthos couldnt be installed on boa2 project because ERROR_OF_INSTALL").
