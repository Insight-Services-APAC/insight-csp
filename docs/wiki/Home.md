<!-- markdownlint-disable -->

## Azure Landing Zones Bicep Repo - Wiki

<!-- markdownlint-restore -->

![Bicep Logo](.media/bicep-logo.png)

Welcome to the wiki of the Azure Landing Zones Bicep repo. This repository contains the Azure Landing Zone Bicep modules that help you create and implement the [Azure Landing Zone Conceptual Architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/#azure-landing-zone-conceptual-architecture) in a modular, repeatable fashion.

## Overview

The Azure Landing Zone - Platform repository provides an approach for deploying and managing the core data platform capabilities using an approach that aligns with Cloud Adoption Framework conceptual architecture.

## Getting Started

To get started with Azure Landing Zone - Platform, start with the guided [Code Tours](https://marketplace.visualstudio.com/items?itemName=vsls-contrib.codetour), [Getting Started](GettingStarted.md), [Local Development](LocalDev.md) and [deployments/deployments-pre-deploy.md](./deployments/Deployments-pre-deploy.md) for:

- Getting a baseline understanding of how to develop code, commit with Git, branch and merge, configure Bicep, YAML and more.
- Completing the prerequisites and dependencies for the overall implementation.
- High-level deployment flow.
- Links to more detailed instructions on individual modules.

> **Note:** _Minimum skill requirements to get started_
>
> At minimum, you should be familiar with using VSCode and have some coding experience with YAML, Bicep and PowerShell.

## Repository Details

The following section outlines the contents and specific set up for this repository.

### Folder Structure

The structure of the repository is outlined below.

- **.azdo** - Folder for Azure DevOps pipelines for the solution.
- **.github** - Folder for GitHub Action pipelines for the solution.
- **.local** - Insight's local dev experience.
- **.tours** - Guided code tours.
- **.vscode** - Folder for user and workspace settings for VS Code.
- **docs** - Folder for markdown files for the repository.
- **scripts** - Folder for generic scripts for the repository.
- **src** - Folder for Bicep IaC modules and parameter files for the Azure Landing Zone Platform solution.
  - **configuration** - Folder for all associated parameter files, segregated into the associated deployment area.
  - **modules** - Folder for all associated Bicep modules, segregated into the associated deployment area.`
  - **orchestration** - Folder for all orchestration Bicep files, that help deploy the solution using modules and resource deployments.

### Branch Policies

A Branch policy is _always_ be in place to prevent authoring and pushing changes to the `main` branch directly, this needs to be raised through a _Pull Request_. Settings for this policy include:

- Minimum of 1 reviewers
- Optionally check for linked work items on Pull Requests
- Ensure all comments are resolved on Pull Requests
- Automatically include the `Cloud Engineering/Platform/Administrator` team as reviewers using the CODEOWNERS file.
