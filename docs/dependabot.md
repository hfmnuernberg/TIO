# Dependabot - automatic dependency updates

## Dependabot

This repository uses Dependabot to create automatic pull requests for updating dependencies.
The configuration for Dependabot is stored in the [Dependabot config](../.github/dependabot.yaml) file.

## Dependabot auto-merge

If the Dependabot PR is green and the CI checks are passing, the PR can be auto-merged by Dependabot.
The auto-merge action is configured in the PR verify pipeline and is only available for the `dependabot` user.

The pipeline step that adds semver labels to the Dependabot PRs is necessary to avoid auto-merging major updates!

## Label Dependabot PRs to auto-merge only minor/patch updates

To auto-merge only minor and patch version updates, the Dependabot PR needs to be labeled with `semver: major`, `semver: minor`, or `semver: patch`.
For that we have a separate job in the [auto-merge GitHub workflow](../.github/workflows/pr--verify.yaml).
The labels need to be created manually in the GitHub repository settings.
