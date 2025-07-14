I'd like you to be inspired by Luca's code under vendor/genai-factory/cloud-run-single/ .
As you can see its a multi-stage setup:
* 0_projects/
* 1_apps/

I want to reach a very similar behaviour where we first create N projects based on a configuration YAML which carries
all the information we need. Example: `etc/class_2teachers_6students.yaml`

We need to create multi-stage code under `iac/terraform`, in a similar way.
A script will take in input the YAML and do something so that terraform is then ready to:
1. Set up N projects, one per `schoolbench` stanza.
   *  Ensure projects have some pseudo random alphanum/hexadecimal padding after project name, which ensures ease of create/destroy (GCP projects are unique and wyu cant keep creating/destroying the seae project id). Example with 4 alphanum chars: "riccardo" -> "riccardo-a7hx".
2. give access to those users (lets start with EDITOR then we can refine)
3. [SKIP FOR NOW] install those applications. For now, we skip (3) and just add some sort of todo and ensure its doable. We concentrate on step `0_projects/` and ensure this produces enough outputs that can be then used by the app installation module.


