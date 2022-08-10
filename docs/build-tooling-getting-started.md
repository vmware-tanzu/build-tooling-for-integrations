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
   You can set the `COMPONENTS` variable either in the makefile or as an environment variable. We need to provide the
   component's location, default image name and the package name of the component delimited by a `?` something like
   below:

   ```
   COMPONENTS ?= featuregates?featuregates-controller-manager?featuregates
   ```

   Here `featuregates` is the path to the featuregates component from project's root directory, `featuregates-controller-manager`
   is the default image name, `featuregates` is the name of the package, this should be same as the directory name that
   holds the package definition of featuregates in `packages` directory that's in the project's root directory.

   If your project has multiple go modules and you want to build images and packages for each of the go module, you can
   do that by setting multiple components to the COMPONENTS variable. For example:

   ```
   COMPONENTS ?= featuregates?featuregates-controller-manager?featuregates capabilities?capabilities-controller-manager?capabilities
   ```

3. Run make init

   To initialize the build tooling we need to run the `init` make target, this fetches the Dockerfile that is used for
   building the image, testing the go module etc. and other templates needed by build tooling.
   It also pulls the packaging image that is needed to build and publish package and repo bundles.

   ```
   make init
   ```

4. Create packages directory and add package definition in it
   
   If you are using one of the seed projects, you need to customize the existing package in that project, else check 
   this [documentation](./add-package.md) on how to add a package

5. Build the images in the integration

   To build the images in the integration, run

   ```
   make docker-all
   ```
   
   Following env vars should be set when running the above make target

   1. `OCI_REGISTRY` - remote OCI registry where you would like to push the built image.
   2. `IMG_VERSION_OVERRIDE` - image tag for the image to be built.
   
6. Build the images, package bundles and publish them
   
   To build and publish the images and package bundles in the integration, run

   ```
   make all
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
