# How to use build tooling

The purpose of this document is to provide a getting started guide for someone who wants to use build tooling for Tanzu
integrations.

If you would like to use the build tooling for a new integration, check out the `examples` directory which contains 
some seed projects.

Detailed steps on how to use Build Tooling for Integrations for building and publishing controllers are at [Steps to use the build tooling](#steps-to-use-the-build-tooling)

Detailed steps on how to use Build Tooling for Integrations for building and publishing Tanzu CLI plugins are at [Build Tooling for Tanzu CLI Plugins](#build-tooling-for-tanzu-cli-plugins)

## Steps to use the build tooling

1. Copy the contents of the Makefile
   
   This step can be skipped if using one of the seed example projects as it already contains the Makefile.
   This is the first step to consume the build tooling. The `templates` directory in this project's root directory
   contains a Makefile with a bunch of make targets. These make targets are for initializing the build tooling,
   building and publishing the images and packages etc. in a containerized environment so that the builds are
   deterministic and reproducible in any environment.
   

2. Set COMPONENTS variable

   For the build tooling to understand where your components are located, it needs the `COMPONENTS` variable to be set.
   You can set the `COMPONENTS` variable either in the makefile or as an environment variable.
   
   Build tooling supports building client library components and components that can generate binaries. Build tooling
   identifies if a component is a library or not by looking for `main.go` in the component's directory and 
   sub-directories.


   To build client library set the path of the client library component in the `COMPONENTS` variable, like below
   ```
   COMPONENTS ?= client-library-module
   ```
   
   To build a component that can generate a binary, we need to provide the component's location, default image name and 
   the package name of the component delimited by a `.` something like below:

   ```
   COMPONENTS ?= module1.module1-manager.module1
   ```
   
   Here `module1` is the path to the module1 component from project's root directory, `module1-manager`
   is the default image name, `module1` is the name of the package, this should be same as the directory name that
   holds the package definition of module1 in `packages` directory that's in the project's root directory.

   If your integration has multiple go modules, and you want to build each of the go module, you can set multiple components
   in the COMPONENTS variable. For example:

   ```
   COMPONENTS ?= module1.module1-manager.module1 client-library-module
   ```

3. Run make init

   To initialize the build tooling we need to run the `init` make target, this fetches the Dockerfile that is used for
   building the image, testing the go module etc. and other templates needed by build tooling.
   It also pulls the packaging image that is needed to build and publish package and repo bundles.

   ```
   make init
   ```

4. [Optional] For components that can generate binaries, create packages directory and add package definition in it
   
   If you are using one of the seed projects, you need to customize the existing package in that project, else check 
   this [documentation](./add-package.md) on how to add a package

5. Build the components in the integration


   To build the components and to generate the binaries of the components, run:

   ```
   make build-all
   ```

   Running the above make target generates the binaries of the components and puts them in `build/{component}` directory
   in the integration's root directory.

   To build the images of the components in your integration, run:

   ```
   make docker-build-all
   ```
   
   Following env vars should be set when running the above make target if your `COMPONENTS` variable includes components
   that are executable

   1. `OCI_REGISTRY` - remote OCI registry where you would like to push the built image.
   2. `IMG_VERSION_OVERRIDE` - image tag for the image to be built.
   
6. [Optional] Publish the images
   
   To publish the images built in the previous step, run

   ```
      make docker-publish-all
   ```

7. [Optional] Build and publish package bundles 

   To build and publish the package bundles in the integration, run

   ```
   make package-all
   ```

   Following env vars should be set when running the above make target

   1. `OCI_REGISTRY` - remote OCI registry where you would like to push the images and package bundles.
   2. `IMG_VERSION_OVERRIDE` - image tag for the image to be built.
   3. `PACKAGE_REPOSITORY` - package repository of the package bundles.
   4. `PACKAGE_VERSION` - package version of the package bundle being built.
   5. `PACKAGE_SUB_VERSION` - package subversion of the package bundle being built.
   6. `REGISTRY_USERNAME` - OCI registry username.
   7. `REGISTRY_PASSWORD` - OCI registry password.
   8. `REGISTRY_SERVER` - OCI registry server url.

## Build Tooling for Tanzu CLI Plugins

### A Temporary Solution

One day, the Tanzu team would like a one-stop-shop set of build tools that is able to build every controller, plugin, and package that goes into a Tanzu cluster.
Until that day, the build tooling will be utilizing tooling from other repositories in order to build and publish the various components.
In this part of build tooling, the temporary solution in place is to download and install Tanzu CLI Plugin Builder.
The build tooling here will wrap the Tanzu Plugin Builder commands that build and publish Tanzu CLI plugins.
Keep an eye out for the long term solution that will not require taking and using tools from various repositories, depending on which part of a Tanzu cluster is being worked on.

### What does Build Tooling Do for Tanzu CLI Plugins?

- Tanzu CLI plugin builder tool will be used to build plugin binaries and packages.
- Builder will publish plugins to an OCI registry that you specify. Supported registries are GCR, Docker, and others. GitLab container registry is not yet supported.
- By default, every plugin in the `cmd/plugin` will be processed. To exclude or include plugins, set the `CLI_PLUGINS` environment variable with names separated by spaces. All plugins must be inside the `cmd/plugin` directory.

### Preparation Steps

- Copy the `templates/Dockerfile` into your plugin directory. In our example, we would copy the Dockerfile into the `multi-module-integration` directory. This is the same location as where the Makefile is.
- Back up an existing `Makefile` in your project directory (in our example, that is the `multi-module-integration` directory), if you have one. Then, copy the `templates/Makefile` into that directory. In our example, the `simple-plugin/Makefile` is identical to the `templates/Makefile`.
- All plugin logic must be in their own directories in `cmd/plugin`. See the plugins in `examples/multi-module-integration/cmd/plugin` as an example.
- *REQUIRED*: plugin directories must be named after the plugins that they hold. For example, the `cmd/plugin/plugin-demo-bar` is named after the plugin which has the name `plugin-demo-bar`.
- If you're starting to build your plugin from scratch, copy the `simple-plugin/cm/plugin/plugin-demo-foo` directory and it contents. Update the plugin name, description and logic. Add your own [Cobra](https://github.com/spf13/cobra) commands to your plugin.

### Running Build Tooling for Integrations to Build Tanzu CLI Plugins

#### Building All Plugins in the cmd/plugins Directory

- Set an environment variable, `CLI_PLUGIN_VERSION`, with a version that meets semantic versioning standards.
- Then, run `CLI_PLUGIN_VERSION="<semantic version>" make cli-plugin-build`.

Here is an example:

```shell
CLI_PLUGIN_VERSION="v1.0.0" make cli-plugin-build
```

#### Specifying Plugins to Build in the cmd/plugins Directory

- Set an environment variable, `CLI_PLUGIN_VERSION`, with a version that meets semantic versioning standards.
- Set an environment variable, `CLI_PLUGINS`, where the names of plugins are also directory names in which they are in. The plugin names are separated by single spaces.
- Run `CLI_PLUGIN_VERSION="<semantic version>" CLI_PLUGINS="<list of plugin names separated by single spaces" make cli-plugin-build`.

Here is an example:

```shell
CLI_PLUGIN_VERSION="v1.0.0" CLI_PLUGINS="plugin-demo-bar plugin-demo-foo" make cli-plugin-build
```

You should now see plugin binaries in `build/artifacts/plugins`, and plugin packages in `build/artifacts/packages`.

### Running Build Tooling for Integrations to Publish Tanzu CLI Plugins

- Before you can publish plugin packages, you need to have built them first. So, complete the [Running Build Tooling for Integrations to Build Tanzu CLI Plugins](#running-build-tooling-for-integrations-to-build-tanzu-cli-plugins) step before doing this step.
- Select which plugins and which versions of the plugins are to be published by editing [plugin_manifest.yaml file](examples/multi-module-integration/build/artifacts/packages/plugin_manifest.yaml).
- You need to set a few environment variables: REGISTRY_USERNAME, REGISTRY_PASSWORD, OCI_REGISTRY, PUBLISHER, AND VENDOR.
   - Using the GitHub Container Registry as an example, the OCI_REGISTRY is `ghcr.io`.
   - The VENDOR is your GitHub username.
   - The PUBLISHER is your GitHub repository name.
- Run REGISTRY_USERNAME=<username> REGISTRY_PASSWORD=<password> OCI_REGISTRY=<registry> VENDOR=<organization>  PUBLISHER=<project> make cli-plugin-publish.

Here is an example:

```shell
REGISTRY_USERNAME=codegold79 REGISTRY_PASSWORD=correcthorsebatterystaple OCI_REGISTRY=ghcr.io VENDOR=codegold79 PUBLISHER=cg-examples make cli-plugin-publish
```

You should see the plugin packages uploaded to your OCI_REGISTRY.
