# Build Tooling for Integrations
> I shouldn't need to be a Tanzu expert to create a Tanzu integration
>
> — *Unknown*

## Overview
Tanzu is highly extensible by design. This extensibility allows developers to add new capabilities to their management
or workload clusters, or introduce new types of interactions with the cluster.

This project enables developers to start building and packaging new Tanzu integrations&mdash;including cluster packages 
and custom CLI commands&mdash;without prior Tanzu experience. It does so by curating and maintaining a build environment
that produces consistent artifacts according to Tanzu’s specifications and recommendations. It allows developers to 
focus on what value they are trying to add to the cluster, rather than the tooling and processes required to make it 
available in Tanzu. A portable and validated build environment, and familiar-feeling Make targets are
provided by this project to do all the heavy lifting.

Refer to the following table to help decide if Build Tooling is right for you:
| I Want To...                                                      | Can Build Tooling Help?   |
| ---                                                               | :---:                     |
| ...create a custom command for the Tanzu CLI                      | :heavy_check_mark:        |
| ...extend the API resources and functionality of a Tanzu cluster  | :heavy_check_mark:        |
| ...package an existing service for use in a Tanzu cluster         | :heavy_check_mark:        |
| ...create a new service for Tanzu clusters                        | :heavy_check_mark:        |
| ...retire early                                                   | :x:                       |


## Try it out

### Prerequisites

1. A development machine with `make`, `docker` and `buildx` with version v0.8 or up installed. If you install Docker 
   desktop, then it is not explicitly needed to install `buildx` as it is included by default.
2. A project directory for your Tanzu integration code

### Build & Run

The [Getting Started documentation](docs/build-tooling-getting-started.md) provides a getting started guide and 
information about building tooling.

## Project Structure

templates - contains templates such as Dockerfile, Makefile to get started with build tooling.

package-tools - contains a go module that can be used to build package and repo bundles.

package-tooling-image - contains Dockerfile and other needed files to build package tooling image to use package tooling
in a containerized environment.

## Contributing

The build-tooling-for-integrations project team welcomes contributions from the community. If you wish to contribute
code and you have not signed our [Contributor License Agreement](https://cla.vmware.com/cla/1/preview), our bot will
update the issue when you open a Pull Request. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE)
