# Build Tooling for Tanzu CLI Plugins

Requirements

- copy the Dockerfile and Makefile from templates/. 
- all plugins must be in their own directories in `cmd/cli/plugin`
- plugin name is established in main.go

Behavior
- Tanzu CLI plugin builder tool will be used to compile and publish plugins.
    - One way to make a plugin is use `builder init` and then delete all the git stuff, everything except the go and the plugin readme, which are required.
    Replace the generated Makefile with the one in `templates/`.
- Every plugin in the `cmd/cli/plugin` will be processed. To exclude or include, you must move plugin directories in or out of the `cmd/cli/plugin` directory
- We do not provide an interface to use other builder commands like `init`

Builder options
    - type = local or oci
    ... more to be continued ..