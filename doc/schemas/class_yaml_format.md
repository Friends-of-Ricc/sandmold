Every Class (1a stage) stanza YAML will have the following fields:

## Main

* `folder`: contains the high level classroom fields.
* `schoolbenches`: contains info re array of seats
* `common`: contains common information to all schoolbenches. Info here will be "UNIONed" to the existing one (apps for bench 1 will become "apps )

## "folder" stanza

* org_id (mandatory): numeric org id
* domain (mandatory): string org domain. They need to coincide.
* parent_folder_id: folder_id or org_id under which the classroom will be constructed.
*  billing_account_id  (mandatory): Who pays for it. Example: "01C588-4823BC-27F650"
*  name (mandatory): The folder name. Make this sticky and dont change often, since this is the workspace too.
*  workspace_id (optional): the workspace name. If omitted, defaults to the name.
*  description (mandatory): user way to document what this is for.
*  env (optional): an ARRAY of (name: string, value: string). Example:
```yaml
    env:
    - name: GOOGLE_CLOUD_REGION
      value: europe-west4
```
* labels (optional): an array of  (key: string, value: string). Exmaple:
```yaml
    env:
    - key: cost-center
      value: hhgttg-0042
```
* `teachers` (mandatory): An array of teachers emails. These will be created

## "schoolbenches" stanza

This contains an array of School Benches. Each bench contains 1+ students, 0+ apps. the metaphor is that you can have 1/2 students per bench. This is ideal for workshops where sometimes you want to pair-program to overcome the limitations of a single human (speed + teamwork over completeness).

A schoolbench is an array with following fields:
*  `project` (mandatory - for now): used to create a project. Given project creation/deletion stickiness on GCP, a padding of pseudorandom alphanums will be added to the end of it.
* `type` (optional): "teacher" or "student". Default: "student".
  * "student": default behaviour, for 1+ students.
  * "teacher": there should be at most 1 but this is not enforced for now. This is de facto a "cattedra".
* `apps` (optional): array of 0+ application names. This is important for stage 2. Note a desk with NO apps might still make sense.
* `app` (optional): a single application name. This is just syntactic sugare. These are equivalent:
```yaml
    apps:
    - heapster_shop
     app: heapster_shop
```
* `seats` (mandatory): array of emails.

## "Common" stanza

Common stanza is a convenience place in order NOT to repeat ourselves too much.

Example:

```yaml
schoolbenches:
  - app: jss
    project: prj1
    seats:
    - user1@gmail.com
  - app: heapster_shop
    project: prj2
    seats:
    - user2@gmail.com
  - ...
common:
  schoolbenches:
    foreach_project:
      applies_to: ALL_STUDENTS
      apps:
      - heapster_shop
      seats:
      - user1@gmail.com
```

Will produce the equivalent config as this:


```yaml
schoolbenches:
  - apps:
    - jss
    - heapster_shop
    project: prj1
    seats:
    - user1@gmail.com # twice, ignore the second.

  - apps:
    - heapster_shop # twice, ignore the second.
    project: prj2
    seats:
    - user1@gmail.com
    - user2@gmail.com
  - ...
```

Note: the *applies_to* can apply to
* ALL_STUDENTS (all students and teachers)
* ALL (both students and teachers)



# Future extensions

Ignore these for now, it's mortly for vision and documentation.

== IGNORE START ==

In the future we might want:

1. Make project non-mandatory.
2. Make schoolbenches non mandatory, just set up a single schoolbench template and have terraform iterate through a number of them.
3. Same as 2 - maybe by just giving a list of - say - 51 emails and define the bench size (in this case, if size is "2", it will be 26 benches, the last being single occupant).

== /IGNORE END ==
