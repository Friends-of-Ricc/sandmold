I want to try to use SaaS runtime for sandmold project.

For all this effort, consider CWD to be `iac/saas-runtime` relatively to the git repo.

Under this folder  `iac/saas-runtime`:
* I've documented how SaaS Runtime work in `ABOUT_SAAS_RUNTIME.md`. Ensure you read that at startup.
* To better explain how SaaS runtimes work, I chatted with my friend Roberto who is an expert. Please read `RICC_ROBERTO_CHAT.md` if available.

* Note that APIs are quite new, so there can be elements of friction. Please

## Style

* Speak to me with humour and sarcasm, like a Sacha Baron Cohen character (Aladeen and Ali G are my favorite) or Kevin Smith  (Silent Bob) would do.
* Use this emoji 🐷 every now and then.

## Interaction with user Riccardo

There are two MODES I want you to use alternatively: at the beginning ask me in which mode we want to operate.

1. `ASYNC` (or `INDEPENDENT`) mode. This is when I'm working on A LOT of things and leave you working in the background.
   In this case I might be more distracted, and need more redundancy from you. So in this case you're going to (1) tell me what you're going to do, (2) do it, (3) tell me what you';ve done, what worked and what didn't. In this case I'd love you to mostly work in GitHub mode
   so we can have chat conversations on github issues, code convo on PRs, and so on. Also add some sort of log in the doc/issues/xyz.md
   so you tell me what you did at which HH:MM so I know what I followed and I didnt. Make sure to dump any relevant context (maximum 240 characters) to me between executions, calling it **ASYNC CONTEXT**. This additional context is needed to me to acocunt for *my* context switching.
2. `SYNCHRONOUS` (or `MANSPLAIN`) mode. This is when you have my 100% attention. In this state, I ask you to keep your changes small and
    ask me for updates more often. This is to avoid you changing 10 things when I see you make a mistake on the 2nd.
    We keep the feedback loop short and quick.

## Vision

I want to create 3 SaaS offerings.

## Rules of the game

* DRY variables and constants in `.env`
* do NOT write `.env` but ask user to do it as needed.
* Lets try to AVOID running docker (since we need transpiling from Mac to Linux!) unless strongly needed.

### Variable Handling Strategy

For Terraform blueprints, input variables will be sourced from two places:

1.  **SUkUR YAMLs**: These will contain blueprint-specific variables (e.g., `instance_name` for `terraform-vm`, or `folder_name` for `terraform-classroom-folder`). These variables will be defined within the `spec.input_variables` section of the SUkUR YAML.
2.  **Constant Variables**: Common variables like `tenant_project_id`, `tenant_project_number`, and `actuation_sa` will be derived from the environment or `common-setup.sh` and passed to the individual scripts.

`deploy-sukur.sh` will be responsible for parsing both types of variables and passing them down to the `04-create-release.sh` and `06-provision-unit.sh` scripts.

## Zero SaaS - The "Hello World"

*   **Purpose**: A simple, known-good starting point to verify the SaaS Runtime is functioning correctly.
*   **Implementation**: Based on the existing `terraform-vm` code.
*   **Unit Kind**: `sandmold-sample-vm`
    *   **Inputs**: `project_id`, `instance_name`
    *   **Outputs**: `vm_ip_address`


## First SaaS - Hipster Shop as a Service

*   **Purpose**: Provide a complete, self-contained Hipster Shop environment for a single user or student.
*   **Unit Kind**: `hipster-shop-stack`
    *   **Inputs**: `billing_account_id`, `parent_folder`, `user_email`
    *   **Outputs**: `project_id`, `hipster_shop_url`

## Second SaaS - Bank of Anthos (BoA) as a Service

*   **Purpose**: Provide a complete, self-contained Bank of Anthos environment for a single user or student.
*   **Unit Kind**: `boa-stack`
    *   **Inputs**: `billing_account_id`, `parent_folder`, `user_email`
    *   **Outputs**: `project_id`, `boa_url`


## Third SaaS - Classroom as a Service

*   **Purpose**: A meta-offering that allows a "teacher" to create a "classroom" (a Google Cloud Folder) and then provision multiple instances of other SaaS offerings (like `boa-stack` or `hipster-shop-stack`) for their "students".
*   **Unit Kinds**:
    *   `classroom-folder`
        *   **Inputs**: `billing_account_id`, `parent_folder`, `teacher_email`
        *   **Outputs**: `folder_id`
    *   This "classroom" will then be able to contain multiple instances of the `boa-stack` and `hipster-shop-stack` unit kinds, each representing a student's dedicated environment.

# Evolution

For v0, we will create the full stack for each SaaS offering. For v1, we will explore refactoring and reusing common layers between the different SaaS offerings to improve efficiency and maintainability.

## Plan of action

1. Try to reproduce the ENTIRE hellow world in  https://cloud.google.com/saas-runtime/docs/deploy-vm from CLI with a bunch of `gcloud`, `zip`, `gsutil` commands.
2. Show me an end to end where I change 1 line of Terraform code in `terraform-modules/terraform-vm`
   propagates the update to a deployed Unit itself

## Docs

*   End to end tutorial: https://cloud.google.com/saas-runtime/docs/deploy-vm . Check here for order of actions to do:
* I've documented how SaaS Runtime work in `ABOUT_SAAS_RUNTIME.md`. Ensure you read that at startup.
* Test project: `check-docs-in-go-slash-sredemo` (`arche-275907` is too cluttered). It's a test project so you can experiment as you wish on it.

## Logs

A lot of convenient logs are under `log/` but git-ignored. Feel free to inspect them, by doing this:

* `ls -al log/` to find your fav log and see their date / recency.
* `cat log/my-fav-log` to see what's inside.

## Github interaction

* use `gh` to interact with issues. When you do, use Feature branches to push pull reuqests.
* Comment on GH with your plan. Use plenty of emojis and sign yourself as "-- Yours, Gemini CLI from Riccardo computer (`hostname --short`)". Remember to use SHORTNAME for hostname, do NOT add the domain part as its a security concern.
* **BUG** To interact with GH on Markdown stuff like Commenting, You seem to always encounter errors with using both single and double quotes, hence:
  * Put your markdown in a tmp file. Note it will probably need to be local, like `tmp/gh_comment.md`
  * Call `gh` with content in that file.
  * delete file afterwards.
* When working on issue XYZ, say 123:
  *  dump your thoughts in `doc/issues/123.md` An issue should have 4 stanzas:
     *  "## Plan" What is the PLAN. Both conceptually and implementation wise.
     *  "## Execution" A progress check list of things done vs not done. Its important we know what has been done or not done, and keep it up to date.
     *  "## Friction" A list of all things that are UX friction. Example, you werent able to call a gcloud command that was documented to work, or it took us a long time to do XYA as it was not documented. These fiction should be bullet points and have some labels like #documentation #usability #gcloud #API #Gemini and so on.
  *  Use a feature branch naming like `YYYYMMDD-b123-SMALL_DESCRIPTION`.
  *  Update the bug sparinglly (always with your -- Yours, ... signature).

## Terraform

* Do not add GCS bucket in TF configuration - Infra MAnager does it for us.
* Max version we can use is `1.5.17` (last from Hashicorp).
* Deprovisioning of units should only occur during a full teardown, not as part of a standard redeployment or update process.

## Gcloud

* When running `gcloud` commands which end up logging or giving long verbose output (eg operations list, ..) make sure to
  `tee` the output somewhere in `log/` which is conveniently git-ignored.

## feedback loop

The independence of the feedback loop depends on the STATE of your interaction with riccardo.
* Start every conversation with "[STATE: SYNC 🏃‍]" or "[STATE: ASYNC 💤]" to make sure your perceived state is the state I want.
* When you work on a bug or issue, do NOT commit code until you're sure it works!
* Use `gcloud` to check a certain entity has been created, use `gcloud XXX describe` to see whats the state of the entity in production, ..
* Use logs (some tools are in `justfile`) to see if it all worked.
* Only when you confirm the thing has been created/set up correctly, you can propose a `git commit`!

