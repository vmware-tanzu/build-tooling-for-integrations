# How to use build tooling

The purpose of this document is to provide a getting started guide for someone who wants to use build tooling for Tanzu
integrations.

If you would like to use the build tooling for a new integration, check out the `examples` directory which contains 
some seed projects.

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

3. Update `.dockerignore` and `.gitignore` files

   This is needed so that the generated component-specific Dockerfiles are not added to version-control or docker build context.
   Add following to the `.dockerignore` and `.gitignore`
   ```
   # Build files related to build-tooling
   *.Dockerfile
   ```

4. Run make init

   To initialize the build tooling we need to run the `init` make target, this fetches the Dockerfile that is used for
   building the image, testing the go module etc. and other templates needed by build tooling.
   It also pulls the packaging image that is needed to build and publish package and repo bundles.

   ```
   make init
   ```

5. [Optional] For components that can generate binaries, create packages directory and add package definition in it
   
   If you are using one of the seed projects, you need to customize the existing package in that project, else check 
   this [documentation](./add-package.md) on how to add a package

6. Build the components in the integration


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
   
7. [Optional] Publish the images
   
   To publish the images built in the previous step, run

   ```
      make docker-publish-all
   ```

8. [Optional] Build and publish package bundles 

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
