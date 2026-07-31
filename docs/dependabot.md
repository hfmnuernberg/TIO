# Dependabot

This repository uses Dependabot to create automatic pull requests for updating dependencies.

The configuration for Dependabot is stored in the [Dependabot config](../.github/dependabot.yaml) file.

## Auto-merge

If all CI checks in a PR opened by Dependabot pass, the PR will be merged automatically unless it's a major version
bump.

## Widgetbook dependencies have to be updated manually

Dependabot does not manage the [Widgetbook pubspec](../widgetbook/pubspec.yaml). The Widgetbook package depends on the
root package via a path dependency, which made Dependabot open conflicting pull requests for both packages. The
`/widgetbook` entry was therefore removed from the [Dependabot config](../.github/dependabot.yaml).

Instead, the verify workflow auto-commits `widgetbook/pubspec.lock` on Dependabot pull requests, so the lock file stays
in sync when root dependencies change. The direct dependencies in `widgetbook/pubspec.yaml` are not covered by this and
have to be bumped by hand:

```shell
scripts/app.sh widgetbook outdated
```

Keep `build_runner` aligned with the version in the root [pubspec](../pubspec.yaml). After bumping, run
`scripts/app.sh widgetbook generate` and `scripts/app.sh analyze`.
