# Testing pull request changes

This document provides guidance for testing pull request changes.

## Testing to be done when updating the files in templates directory

Whenever the files in the [templates](../templates) directory are updated, changes need to be validated before creating
the pull request. You can use one of the existing example projects in the [examples](../examples) directory to validate
the changes.

* When the Makefile is updated, make sure that the changes are validated by running the make targets in the example
project. 
* When the Dockerfile is updated, go to the example project, run `make init`, copy the Dockerfile changes from templates
directory to the Dockerfile in the example project and then run the make target `docker-build-all` to validate that you
can build the example successfully
* Similarly, if you update the .golangci.yaml file, copy the changes to the .golangci.yaml file in the example project
and validate the linter config changes by running either `lint` make target.

## Testing to be done when updating package tooling image

Whenever the files in [package-tooling-image](../package-tooling-image) directory are updated, you need to validate the
changes before creating the pull request. You can use the one of existing example projects in the [examples](../examples)
directory to validate the changes.

* Build the package tooling image by running the `build-package-tooling` make target in the build tooling project root
directory and use that image in the Makefile of one of the example projects to validate that you can build and push the
package and repo bundle in the example project. The easiest way to use and test the newly built package tooling
image is to set the `PACKAGING_CONTAINER_IMAGE` env var and run package related make targets `package-bundle-generate`
and `repo-bundle-generate`.
