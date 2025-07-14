This Google Cloud project is about setting up an Operator-focused Sandbox with the following business purposes:

1. Showcase Operator CUJs. This is focused on Operators! But if we can please also devs, all the better.
2. Allow easy "terraforming" of Lab environemnts which are adapt for Hackathons, workshops, et all. Both customers (with
   billing enabled) and free (low cost, onramp-enabled) are foreseen.
3. Every Lab corresponds to a Google Cloud Folder
4. Let's start building incrementally, leveraging `IaC`.

## In other words

A Sandboxed, OSS Playground which anyone can use (Googlers and customers!), which can be easily setup for Classrooms and stuff.
Can be configured for expensive long-running workshops (weeks, months) or short-lived, cheap onramp-compliant mini-demos.
We will use this to demonstrate Google Cloud Assist within these sandboxes.
The architecture is incredibly modular, allowing for more people to add more scripts/modus operandi for this.

## Other readings

* Use `REQUIREMENTS.md` for this repo
* **plan before executing**. Write your plan in `PLAN.md` and make sure user reviews, edits, before executing.
* before coding anything. We need to ensure our solution respects 100% `REQUIREMENTS.md` and `PLAN.md`.
* If a decision is made, a succinct rationale (the WHAT and the WHY) needs to be there. Eg, "we chose Pulumi vs Terraform because.."

## Terminology

Technically, every lab setup consists in a `classroom` will need two inputs:
* a small "TFvars" for project/folder/nilling setup
* a bigger YAML for the folder/project config (**classroom** config). See `etc/samples` for some inspiration.

## About the user

Two people are maintaining this project. Read additiona user constants as follows:

* If the username (`$USER`) is "ricc", then read further instructions in "RICCARDO.md"
* If the username is "leoy", then read further instructions in "LEONID.md"

