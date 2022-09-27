# Create a Release for Build Tooling for Integrations

To create a new release for Build Tooling for Integrations, there exists a GitHub Action called Create Release.

Simply navigate to the Actions page for this repository and select the "Create Release" workflow. Click on "Run workflow"
and enter the new version for the next release. This will start the release process.

The workflow will perform the following steps:

- Check out the repository
- Update version information in Make/Docker files
- Update the change log
- Commits the updates for the new release
- Creates a release, which also creates a tag with the supplied version
- Creates a branch and Pull Request containing the automated updates for the release
- Publishes the Go module
- Builds, tags and publishes the images for Package and Build Tooling
