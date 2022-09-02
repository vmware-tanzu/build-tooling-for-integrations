# Add a package to package repository

This document provides guidance on how to add a package to a package repository.

## Steps to add a package to a package repository

Below are steps to add a package to the package repository:

1. Copy the `simple-integration` directory from `examples/simple-integration/packages` directory in this repo to the 
   packages directory in your project

   The tree structure of package directory would look something like below and needs to be changed to use your
   package name.

   ```plain
    packages/simple-integration
    ├── Makefile
    ├── README.md
    ├── bundle
    │   ├── config
    │   │   ├── overlay
    │   │   ├── upstream # This is the directory to add the package contents using ytt templates.
    │   │   └── values.yaml # Package contents can be configured by providing data values in this file.
    ├── vendir.yml # To fetch config files from a different data source.
    ├── metadata.yaml # To provide high level information description about your package.
    └── package.yaml # Update the Package CR spec to add/modify fields such as releaseNotes etc.
   ```

   The files in your package directory should be updated with the package config. Significance of each file is provided
   in the above tree structure.

   The Makefile contains `configure-package` and `reset-package` target to configure the package dynamically,
   which is completely optional.

2. Fetch config files from datasource [optional]

   If you have updated the vendir.yaml to fetch the config from a different source, run

   ```shell
      make package-vendir-sync
   ```

3. Update kbld-config.yaml [optional]

   If the container image in your config needs to be replaced by an image at build time, add/update an entry like below in the
   kbld-config.yaml file in your package directory.

   ```yaml
       - image: "simple-integration-manager:latest"
         newImage: ""
   ```
4. Update package-values.yaml to add your package details

   `package-values.yaml` contains Ytt data values for all packages and package repositories.

   Add an entry like below to package-values.yaml under `repositories.<packageRepository>.packages`.

   ```yaml
         #! package name
       - name: simple-integration
         #! Relative path to package bundle
         path: packages/simple-integration
         domain: tanzu.vmware.com
         version: latest
         sha256: "simple-integration:latest"
   ```
