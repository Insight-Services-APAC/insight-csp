# How to contribute

Contribution to this repository is open to anyone and requires a Pull Request for changes to be considered for merging to `main`.

It's important to understand how to work with Bicep, so we recommend starting with learning about [best practices for Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices).

If you are adding a new workload, please consider the [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/) ensuring your solution has:

- Reliability
- Security
- Cost Optimization
- Operational Excellence
- Performance Efficiency.

## Getting Started

See [docs/wiki/GettingStarted.md](/docs/wiki/GettingStarted.md) for instructions on how to use this repository.

## Developing

The Bicep Integration patterns are separated into two folders.

- **/src/modules**: reusable Bicep modules structure by the resource namespace
- **/src/orchestration**: a Bicep deployment leveraging existing modules to implement the data platform.

### Branching

Contributing to this repository is done via branches. Create a new branch using any of the following combinations:

- [\<handle\>, feature, bug]/[\<issue id\>, feature-name, bug-name]

e.g.

- `feature/13`
- `mrsmitty/claim-check`

### Pull Requests

Create a PR to request merging changes into `main`.

### Codeowners

If you're working off this repository inside Insight's GitHub Organisation, please take note of the [CODEOWNERS file](/CODEOWNERS).

### Client Work

It's preferred that client work occurs within client repositories. Encourage creation of a GitHub or Azure DevOps org and clone/push this repository to continue work with the client.
