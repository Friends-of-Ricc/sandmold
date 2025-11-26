---
# this article will go to Medium once finished.
# TF: b/463586009
title: A GCP Terraform Classroom for hackathons: my personal learning with Gemini CLI
author: Riccardo Carlesso
description: Riccardo lessons learnt on Terraform, Sandmold and SaaS Runtime.
medium_article_url: TODO
slides: https://docs.google.com/presentation/d/1JkWncwizk7qUnBfnKCBy-wnHQ5uswtB_U2iThrKsxeU/edit
---

# A Terraform Classroom for hackathons on GCP: my personal learning with Gemini CLI

This summer, I was given the time to do some profound learning on the Ops side. My mission? To sharpen my Terraform skills and explore the frontiers of Google Cloud's SaaS Runtime, all while pair-programming with the Gemini CLI. My project, which I affectionately named "**Sandmold**", was born from a simple need: to create ephemeral, sandboxed Google Cloud environments for **workshops** and **hackathons**.

![GCP and Terraform classroom](images/page1_img5.jpeg)


The idea is simple: **pre-provision a class for N students who (alone or in pairs) can solve a generic exercise in a sandboxed environment. Here, teachers would have automatic observability over people**.

This article describes my journey. As someone not expert of Terraform, there were many lessons to be learned; I hope that by sharing my failures and successes, I can help others build on this (or similar) work.

* Code: https://github.com/Friends-of-Ricc/sandmold - 
 Multi-stage architecture strongly inspired by [Fabric FAST](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric) and  Luca's [GenAI Factory](https://github.com/GoogleCloudPlatform/genai-factory).

![Multiple apps in multiple desks](images/page4_img2.jpeg)


<!-- this is for a 
![Multiple apps in multiple desks](image.png)
-->

## Sandmold? Why this horrible name?

<img src="image-3.png" alt="Sandmold etymology" width="30%" style="float: right;"> Well, take a person who is thinking in 🇮🇹 Italian, querying Google Images in a 🇩🇪 German speaking region, and then Google translating to 🇬🇧 English, and double-checking with a 🇷🇺 Russian colleague. There you have it: "formine per sabbia" -> "Gill Förmchen" > "Da" > "Sandmold". Once my American colleagues came for the rescue, the repo was registered, [go links](https://golinks.github.io/golinks/) saved, there was no going back.

## What's a Classroom?

The ClassRoom analogy is simple:

* A **classroom** corresponds to a [GCP Folder](https://docs.cloud.google.com/resource-manager/docs/creating-managing-folders).
* A **bench** is a [Cloud Project](https://developers.google.com/workspace/guides/create-project) (usually, 1-2 students per bench).
* A project can have N **apps**, each appearing at most once (eg, one [Bank of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos) and one [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo), but *not* two [Banks of Anthos](https://github.com/GoogleCloudPlatform/bank-of-anthos)).



## The Vision: from YAML to a working Playground

As a Rubyist, I love YAMLs. This is the promise of my project:

![From YAML to Cloud Console..](image-2.png)

And to do so, you *just* (literally) run a `just` script which calls terraform and creates a Markdown file with the results (`REPORT.md`):

![just classroom up](images/page30_img3.jpeg)




<img src="images/page30_img1.jpeg" alt="Sandmold etymology" width="30%" style="float: right;">  Which creates, after some terraforming, a clean `output.tf`:

Note that a succesfully destroyed classroom *also* leaves a report.md with a link to the destroyed resources.

<!-- ![output2](images/page30_img2.jpeg) -->



## The Vision: A Cloud Playground with SaaS Offerings

My vision for Sandmold was to create a modular, open-source playground, easily spinning up complex environments like Online Boutique or Bank of Anthos as self-contained "SaaS" offerings. This would allow teachers to provision entire classrooms and personal labs for students with simple commands. 

After a talk with my Terraform expert Roberto, this pursuit naturally led me to Google Cloud's [SaaS Runtime](https://cloud.google.com/products/saas-runtime) — a powerful, yet new, product for multi-tenant SaaS. 
![SaaS Runtimes](images/page40_img1.jpeg)

It seemed perfect, but as with any new frontier, there were **beasts** to slay first!

![SaaS Runtimes](images/page1_img8.jpeg)



## Part 1: Terraform and Gemini CLI

[Gemini CLI](https://github.com/google-gemini/gemini-cli) was launched on June 25th when I was working at this project. I was incredibly lucky to have Gemini write the Terraform code for me, and being able to rectify the mistakes by just doing `terraform plan` and `terraform apply`. It was beautiful to see it iterate through mistakes (sometimes very narrow and arcane), fixing them, retrying and getting them fixed. 
Given that Terraform needs to check resources to exist in the cloud, this feedback loop would be slow at times, sometimes taking up to 15min, but I would have  lunch, or simply I could check emails or do meetings, while Gemini CLI was meticulously trying to fix my code.

## My Journey into the SaaS Runtime Rabbit Hole

[SaaS Runtime](https://cloud.google.com/products/saas-runtime) has its own vocabulary and a specific order of operations. Think of it like making a proper Italian dinner: you can't just throw everything in the pot at once! You have the *antipasto*, the *primo*, the *secondo*. It's a process.

Here are the key concepts I had to wrap my head around:

*   **SaaS Offering:** This is the big picture, the entire dish. It represents your SaaS product, like "Bank of Anthos as a Service."
*   **Unit Kind:** This is a specific component of your offering, like the GKE cluster or the database. It's an ingredient in your recipe.
*   **Release:** A specific, versioned snapshot of your Unit Kind. Think of it as a specific version of your tomato sauce recipe.
*   **Unit:** An actual, running instance of a Unit Kind. This is the final, plated dish, ready to be served to a customer (or, in our case, a student).

Understanding this hierarchy was the first, and perhaps most crucial, lesson of my journey. Now, let's get our hands dirty and see how these concepts translate into actual code.

## Our First SaaS Offering: A Humble "Hello World" VM

Every great journey begins with a single step, and in the world of software, that step is often a "Hello, World!". My first SaaS offering was no different. I created a simple Terraform module to provision a single Google Compute Engine virtual machine. This served as the perfect, low-stakes test case to ensure the entire SaaS Runtime pipeline was working correctly.

The module itself is a standard, no-frills Terraform setup:

*   **`variables.tf`**: This file defines the inputs for our module. Think of these as the knobs and dials for our VM. We can specify things like the `instance_name`, `machine_type`, and the `tenant_project_id` where the VM will live.
*   **`main.tf`**: This is the heart of the operation. It contains the `google_compute_instance` resource block that tells Terraform what to build. It takes the variables from `variables.tf` and uses them to configure the VM, from its boot disk to its network interface.
*   **`outputs.tf`**: After the VM is created, we need a way to get information about it. This file defines the outputs, such as the `instance_external_ip` and the `instance_name`.

In the language of SaaS Runtime, this humble Terraform module is our **Blueprint**. We package it up (as we'll see later, this had its own set of adventures) and use it to define a **Unit Kind** called `simple-vm`. When we want to create an actual VM, we provision a **Unit** of this kind.



With this simple foundation in place, I was ready to move on to the more complex and exciting offerings: Bank of Anthos and Hipster Shop.

## What went wrong

1. 🚔 [GCP Org Policies](https://docs.cloud.google.com/resource-manager/docs/organization-policy/overview) are tough - *really* tough. This makes it very hard to terraform anything cross-orgs, if your org is well protected (like my Company org).

2. 📁 **Folders are hard**. While it’s easy to ask people for a `PROJECT_ID`, it's hard to ask people for a `FOLDER_ID`: they need an `ORGANIZATION_ID` and all the 🚔 Org Policy shenanigans kick in. A project can be orgless, a folder cannot.

3. 💛 **Riccardo likes his scripts, others don’t**. I've reviewed extensively Friction Logs from two colleagues, and I realized that what works for me doesn't necessarily work for all. My reliance on scripts like `justfile`, `jq`, `yq`, `lolcat` extenuated their code reproductions. A big lesson learnt for me: minimize dependencies on external scripts. Rule of the thumb: Note to self: if a script is not on [Cloud Shell](https://docs.cloud.google.com/shell/docs/launching-cloud-shell), do without or document it as an explicit dependency. Yes, `ruby` is in Cloud Shell, along with `terraform`, `gemini` CLI, `docker`, `gcloud`, `npm` and many others!


## What went well

1. Vibecoding setup scripts works really well. So a `bin/check-setup.sh` can yield a friendly:

![check-setup is cool](images/page23_img1.jpeg)

The friendliness of this command got me compliments from multiple colleagues, while I didn't write a line of this... and it's `bash`!

2. **SaaS Runtimes are amazing!**. If you're planning Terraform building blocks with well-defined input/output relarionships, and ever-evolving code, Saas runtime will change your life! In a nutshell, this is *Change Management + Terraform at Google scale*!

![SaaS Runtimes](images/page40_img1.jpeg)