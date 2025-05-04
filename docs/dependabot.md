# Dependabot

This repository uses Dependabot to create automatic pull requests for updating dependencies.

The configuration for Dependabot is stored in the [Dependabot config](../.github/dependabot.yaml) file.

## Auto-merge

If all CI checks in a PR opened by Dependabot pass, the PR will be merged automatically unless it's a major version
bump.
