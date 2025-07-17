Moevd to https://github.com/Friends-of-Ricc/sandmold/issues/13
# Overall idea

Ok now its time to start implementing the Classroom -> App functionality.
Let's move to PLAN mode. Please identify the gaps, and how are you gonna fill them.

## Current status

We have a folder setup with N student projects. And now we want to:
* for each application we want to install in a project, check prerequisites.
  * does folder have a `start.sh`, stop.sh, status.sh? If not, installation of that app will fail and this will be reflected in the report.(err `_APP_MALFORMED_`).
  * Does the app have all the ENVs available to it (eg GOOGLE_PROJECT, FOO and BAR) as per `spec.variables` in the Blueprint?

Note that ENV can be setup at Class level, at Project level and each project created shall export autopmatically these additional ENVs:
* GOOGLE_CLOUD_PROJECT:
* SANDMOLD_DESK_TYPE: "student" / "teacher"

## Desired status

* Note: All the ENV plumbing is currently not there and needs implementing.
* I expect only `foobar` to succeed. I will inject in the sample YAML a project "" with AUTO_FAIL so one app will fail.
* The module 2 (app installation) should be executed with terraform according to `doc/TF_INTERFACES.md` . So for every project we need the proper TF VARs setup correctly (which is the hard part).
  * I presume the bash scripts can be executed with some sort of local exec?
  * In the future, every app will have some sort of terraform code to execute, which is WHY the interface between 1a/1b and 2 is SO important. We need to ensure the interface is bulletproof to then integrate with 1b in the future.

## Execution

1. Do NOT write any code. First, make a plan and put it in `doc/application/gemini-plan.md`
2. Have me review it and dicuss
3. Move to execution mode.

Let's also do more things.

a. Create a feature branch for this implementation
b. discuss the current plan highlevel in https://github.com/Friends-of-Ricc/sandmold/issues/13 . Since you'll likely appear as me, use A LOT of emojis, use a british accent/humour, and sign yourself as "-- your friendly neighbourhood Gemini CLI"
c. The commit should become a Pull Request linked to this GitHub Issue.
