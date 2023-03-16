# Build Tooling for Tanzu CLI Plugins

## A Temporary Solution

One day, the Tanzu team would like a one-stop-shop set of build tools that is able to build every controller, plugin, and package that goes into a Tanzu cluster.
Until that day, the build tooling will be utilizing tooling from other repositories in order to build and publish the various components.
In this part of build tooling, the temporary solution in place is to download and install Tanzu CLI Plugin Builder.
The build tooling here will wrap the Plugin Builder commands that builds and publishes Tancu CLI plugins.
Keep an eye out for the long term solution that will not require taking and using tools from various repositories, depending on which part of a Tanzu cluster is being worked on.

## What does Build Tooling Do for Tanzu CLI Plugins?

- Tanzu CLI plugin builder tool will be used to build plugin binaries and packages.
- Builder will publish plugins to an OCI registry that you specify. Supported registries are GCR, Docker, and others. GitLab container registry is not yet supported.
- Every plugin in the `cmd/plugin` will be processed. To exclude or include, you must move plugin directories in or out of the `cmd/plugin` directory.

## Preparation Steps

- Copy the `templates/Dockerfile` into your plugin directory. In our example, we would copy the Dockerfile into the `simple-plugin` directory. This is the same location as where the Makefile is.
- Back up an existing `Makefile` in your plugin directory, if you have one. Then, copy the `templates/Makefile` into that directory. In our example, the `simple-plugin/Makefile` is identical to the `templates/Makefile`.
- All plugin logic must be in their own directories in `cmd/plugin`. See the plugins in `examples/simple-plugin/cmd/plugin` as an example.
- If you're starting to build your plugin from scratch, copy the `simple-plugin/cm/plugin/plugin-demo-foo` directory and it contents. Update the plugin name, description and logic. Add your own [Cobra](https://github.com/spf13/cobra) commands to your plugin.

## Running Build Tooling to Build Tanzu CLI Plugins

- You need to set an environment variable, `PACKAGE_VERSION`, with a version that meets semantic versioning standards.
- Then, run `PACKAGE_VERSION="<semantic version>" make cli-plugin-build`.

```shell
PACKAGE_VERSION="v.1.0.0" make cli-plugin-build
```

## Running Build Tooling to Publish Tanzu CLI Plugins

- Before you can publish plugin packages, you need to have build them first. So, complete the [Running Build Tooling to Build Tanzu CLI Plugins](#running-build-tooling-to-build-tanzu-cli-plugins) step before doing this step.
- You need to set a few environment variables: REGISTRY_USERNAME, REGISTRY_PASSWORD, OCI_REGISTRY, PUBLISHER, AND VENDOR.
- Then, run REGISTRY_USERNAME=<username> REGISTRY_PASSWORD=<password> OCI_REGISTRY=<registry> PUBLISHER=<your organization> VENDOR=<plugin author> make cli-plugin-publish.

```shell
REGISTRY_USERNAME=codegold79 REGISTRY_PASSWORD=correcthorsebatterystaple OCI_REGISTRY=ghcr.io PUBLISHER=cgExamples VENDOR=codegold79 make cli-plugin-publish
```
