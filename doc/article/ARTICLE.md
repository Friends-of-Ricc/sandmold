---
# this article will go to Medium once finished.
title: A GCP Terraform Classroom for hackathons: my personal learning with Gemini CLI
author: Riccardo Carlesso
description: Riccardo lessons learnt on Terraform, Sandmold and SaaS Runtime.
---

This summer, I was given the time to do some profound learning on the Ops side. My mission? To sharpen my Terraform skills and explore the frontiers of Google Cloud's SaaS Runtime, all while pair-programming with the Gemini CLI. My project, which I affectionately named "Sandmold," was born from a simple need: to create ephemeral, sandboxed Google Cloud environments for workshops and hackathons.

This article describes my journey. As someone not deeply steeped in the world of Terraform, there were many lessons to be learned, obstacles to overcome, and moments of triumph. I hope that by sharing my failures and successes, I can help others build on this work and navigate their own cloud adventures.

## The Vision: A Playground in the Cloud

Before we dive into the technical weeds, let's talk about the dream. The goal of Sandmold was to create a modular, open-source playground that anyone—Googlers, customers, students—could use. I envisioned a system that could spin up complex environments, like the popular Hipster Shop or Bank of Anthos microservices demos, as self-contained "SaaS" offerings. A teacher could provision an entire classroom (a Google Cloud Folder) and then instantiate a personal lab for each student with a few simple commands.

This led me down the path of Google Cloud's SaaS Runtime, a powerful (and very new!) product designed to help developers build and manage multi-tenant SaaS solutions. It was the perfect tool for the job, but as with any new frontier, the map was still being written.

## My Journey into the SaaS Runtime Rabbit Hole

SaaS Runtime has its own vocabulary and a specific order of operations. Think of it like making a proper Italian dinner: you can't just throw everything in the pot at once! You have the *antipasto*, the *primo*, the *secondo*. It's a process.

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

*(Here would be a great place to insert an image! Perhaps one of the diagrams from slide 46 of your presentation?)*

With this simple foundation in place, I was ready to move on to the more complex and exciting offerings: Bank of Anthos and Hipster Shop.