This Google Cloud project is about setting up an Operator-focused Sandbox with the following business purposes:

1. Showcase Operator CUJs. This is focused on Operators! But if we can please also devs, all the better.
2. Allow easy "terraforming" of Lab environemnts which are adapt for Hackathons, workshops, et all. Both customers (with
   billing enabled) and free (low cost, onramp-enabled) are foreseen.
3. Every Lab corresponds to a Google Cloud Folder


## In other words

A Sandboxed, OSS Playground which anyone can use (Googlers and customers!), which can be easily setup for Classrooms and stuff.
Can be configured for expensive long-running workshops (weeks, months) or short-lived, cheap onramp-compliant mini-demos.
We will use this to demonstrate Google Cloud Assist within these sandboxes.
The architecture is incredibly modular, allowing for more people to add more scripts/modus operandi for this.

**IMPORTANT!**. The high level Terraform vision is maintained in `doc/TERRAFORM_MODULES.md`.

## Other readings

* Use `REQUIREMENTS.md` for this repo.
* **plan before executing**. Write your plan in `PLAN.md` and make sure user reviews, edits, before executing.
  * Plan should have a short steps list which we can mark as done as we proceed.
* before coding anything. We need to ensure our solution respects 100% `REQUIREMENTS.md` and `PLAN.md`.
* If a decision is made, a succinct rationale (the WHAT and the WHY) needs to be there. Eg, "we chose Pulumi vs Terraform because.."

## Terminology

Technically, every lab setup consists in a `classroom` will need two inputs:
* a small "TFvars" for project/folder/nilling setup
* a bigger YAML for the folder/project config (**classroom** config). See `etc/samples` for some inspiration.

## About the user

Two people are maintaining this project. Read additiona user constants as follows:

* At startup, check username with `whoami`.
* If the username (`$USER`) is `ricc`, then read further instructions in "RICCARDO.md".
* If the username is `leoy`, then read further instructions in "LEONID.md".

## GCP and Terraform

GCP and Terraform have some limitation. These are described in `doc/billing/CRM_LIMITS.md`.

* Use "Project Factory" to create projects!
* https://github.com/GoogleCloudPlatform/genai-factory/blob/master/cloud-run-single/0-projects/main.tf has an example with `source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project-factory"`
* This terraform setup is intrinsically ephemeral - so disable any Deletion Protection. Destroying resources created hereby should be EASY.

## Github interaction

Use `gh` to interact with issues.
* ensure there are 5 priority labels: `P0`,.., `P4`.
* FRs need "type": "Feature".
* Bugs need "Type": 'bug'.
* Mark each of them with a priority. If unsure, use "P3".

### Github issue fixing

If users asks you to review https://github.com/Friends-of-Ricc/sandmold/issues/XXX, please do the following:

1. propose a plan to solve the issue.
2. When user agrees on it, please write this "## Plan" on the issue itself. Since with `gh` you'll look as the human user, sign yourself with " -- Your Saint Gemini-CLI no-saga little helper" in the end. Do this for any interaction inside the issue, so people know you're a "bot". Use emojis both in signature and in your speaking, particularly the Gemini emoji at the very beginning.
3. GO and implement it on a Feature Branch.
4. Commit and add to the commit message the issue "https://github.com/Friends-of-Ricc/sandmold/issues/XXX".
5. Open a Pull Request.
6. Wait for user et al. to review it. When done, close the Merge request and add a final comment to the issue. We close it if we're done, otherwise we point out the next steps.
