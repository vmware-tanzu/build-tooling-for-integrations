# Build Tooling for Integrations
> I shouldn't need to be a Tanzu expert to create a Tanzu integration
>
> — *Unknown*

## Overview
Tanzu is highly extensible by design. This extensibility allows developers to add new capabilities to their management
or workload clusters, or introduce new types of interactions with the cluster.

This project enables developers to start building and packaging new Tanzu integrations&mdash;including cluster packages and
custom CLI commands&mdash;without prior Tanzu experience. It does so by curating and maintaining a build environment that
produces consistent artifacts according to Tanzu’s specifications and recommendations. It allows developers to focus on
what value they are trying to add to the cluster, rather than the tooling and processes required to make it available
in Tanzu. A portable and validated build environment, and familiar-feeling Make targets are
provided by this project to do all the heavy lifting.

Refer to the following table to help decide if Build Tooling is right for you:
| I Want To...                                                      | Can Build Tooling Help?   |
| ---                                                               | :---:                     |
| ...create a custom command for the Tanzu CLI                      | :heavy_check_mark:        |
| ...extend the API resources and functionality of a Tanzu cluster  | :heavy_check_mark:        |
| ...package an existing service for use in a Tanzu cluster         | :heavy_check_mark:        |
| ...create a new service for Tanzu clusters                        | :heavy_check_mark:        |
| ...retire early                                                   | :x:                       |


## Quick Start

### Prerequisites

* A development machine with `make` and `docker` installed
* A project directory for your Tanzu integration code

### Build & Run

1. Copy the [`Makefile`](./templates/Makefile) into your project directory
2. Run `make init`
3. Write your code
4. Use the built in make targets for building, testing, and packaging your Tanzu integration

## Documentation

## Contributing

The build-tooling-for-integrations project team welcomes contributions from the community. If you wish to contribute
code and you have not signed our [Contributor License Agreement](https://cla.vmware.com/cla/1/preview), our bot will
update the issue when you open a Pull Request. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE)
