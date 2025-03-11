# Dependabot - automatic dependency updates

## Dependabot

This repository uses Dependabot to create automatic pull requests for updating dependencies.
The configuration for Dependabot is stored in the [Dependabot config](../.github/dependabot.yaml) file.

## Label Dependabot PRs to auto-merge only minor/patch updates

To auto-merge only minor and patch version updates, the Dependabot PR needs to be labeled with `semver: minor` or `semver: patch`.
For that we have a [GitHub workflow](../.github/workflows/pr--label-dependabot-pull-requests.yaml) that checks the versions in the PR title and adds a semver label accordingly.

## Dependabot auto-merge

If the Dependabot PR is green and the CI checks are passing, the PR can be auto-merged by Dependabot.
The auto-merge action is configured in the PR verify pipeline and is only available for the `dependabot` user.

The job needs the following permissions to pass:
Read access to metadata, Read and Write access to content (code), commit statuses, deployments, and pull requests

_Note: The read access to metadata permission is default and can't be set manually. The permissions are only active for this specific job._

```yaml
permissions:
  statuses: write
  contents: write
  deployments: write
  pull-requests: write
```

### Complete example

```yaml
auto-merge:
  needs: verify
  runs-on: ubuntu-latest
  permissions:
    statuses: write
    contents: write
    deployments: write
    pull-requests: write
  steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Authenticate GitHub CLI
      run: echo "${{ secrets.GITHUB_TOKEN }}" | gh auth login --with-token

    - name: Enable auto-merge for Dependabot PRs (minor/patch only)
      if: >
        github.actor == 'dependabot[bot]' &&
        (
          contains(toJSON(github.event.pull_request.labels), 'semver: minor') ||
          contains(toJSON(github.event.pull_request.labels), 'semver: patch')
        )
      run: gh pr merge --auto --squash "$PR_URL"
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        PR_URL: ${{ github.event.pull_request.html_url }}

```
