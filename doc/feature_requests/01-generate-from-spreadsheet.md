
I got this idea of a zero-sweat Sandmold installation for a classroom.

Imagine you want to terraform a classroom of 15-20 people. But you don't know exactly who they are.
So I thought, how cool would you be to have a trix like

## Sample Trix

Imagine a spreadsheet with people names, work emails, and Google Email (needed for IAM - can be gmail, Workspace or any Googlified account).

Sheet tab: `default-class`.

```yaml
rows:
- name: Riccardo Carlesso
    work_email: ricc@mycompany.com
    google_email: palladiusbonton+test1@gmail.com
    team: alpha # Using tags to see who belongs to which
    cost-center: CC001 # Who pays for it
    teacher: true # Gives additional powers, like Viewer of projects.
- name: Jane Doe
    work_email: jane@mycompany.com
    google_email: palladiusbonton+test2@gmail.com
    team: bravo # Using tags to see who belongs to which
    cost-center: CC001 # Who pays for it
    teacher: false
- ...
```


## v1.0

* One project id per user.
* `team` and `cost-center` become project_id labels:
  * `sandmold-team`: ...
  * `sandmold-cost-center`: ...
* Some sort of sanitization of the input is needed (spaces, uppercases, ..)



## Future enhancements (non-goals)

I foresee some possible enhancements which should NOT be part of the v1.0:

1. A class configuration boolean would allow us to specify things like: one project per team vs one project per person.

These might be sub-issues but should NOT be implemented for v1.
