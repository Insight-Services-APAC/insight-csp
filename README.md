# Hero Asset Template

The following repository was built, curated and cared for by the wonderful teammates at Insight. 💗

<!-- markdownlint-disable -->

<img src="/docs/wiki/.media/insight-logo.svg" width="200" />

<!-- markdownlint-restore -->

## Lorem ipsum

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Contributing

For information on how to contribute to this project, please see the [contribution guide](/CONTRIBUTING.md).

## Acknowledgements

This repository uses Intellectual Properties (IP) from several other repositories in the open-source community. For more information on these authors and their licenses, please see the [/NOTICE.txt](/NOTICE.txt) file.

## License

GNU GENERAL PUBLIC LICENSE - Version 3, 29 June 2007

See [License](/LICENSE).

## Local Development

For information of how to build and deploy this Infrastructure as Code using VSCode (F5/Run and Debug) functionality, please see the [docs/wiki/LocalDev.md](/docs/wiki/LocalDev.md) file.

<!-- markdownlint-disable MD013 -->

> **IMPORTANT:** The below example requires you have cloned/downloaded the entire repo and have it available at run-time on the machine running the below commands. It is also expected you are in the root of the cloned/extracted repository; otherwise paths will need to be changed in the below example.The parameter file is an example and should be changed to reflect what you need.

<!-- markdownlint-enable -->

## Getting Started with a Customer Deployment

> **NOTE:**
> These instructions are very important to prevent accidental IP oversharing so please follow these instructions fully.

Please follow these instructions to copy/clone this repository to a customer site.

1. Download this artefact/repository as a ZIP archive
1. Open and export the ZIP archive to local disk.
1. Delete the entire folders:
   - `.local`, and
   - `.git` (this is a hidden folder in the root `/`).
1. Delete the following files:
   - [.tours/localdev.tour](.tours/localdev.tour) file.
   - [/docs/wiki/LocalDev.md](./docs/wiki/LocalDev.md) file.
1. Delete these instructions under this heading `## Getting Started with a Customer Deployment`
1. Delete the instructions under this heading also `## Local Development`.
1. Modify [/docs/wiki/Home.md](./docs/wiki/Home.md) and remove references to the [/docs/wiki/LocalDev.md](./docs/wiki/LocalDev.md) file.
1. Upload this modified artefact to the customer site.
