# How to create a Personal Access Token (PAT) for Dependabot and enable automatic dependency updates

To enable Dependabot to auto-merge pull requests for dependency updates, you need to create a Personal Access Token (PAT) with the necessary permissions first.
The PAT can only be created by a GitHub user account. Once created the PAT can be used as a secret in a repository or as company secret.
If multiple repositories want to use auto-merging, it is recommended to use a company secret.

To enable auto-merging in your GitHub pipeline for pull requests, you have to configure the `dependendabot.yaml` file first!

The following steps guide you through the process of creating a PAT for Dependabot.

## 1. Create a Personal Access Token (PAT) on GitHub

1. Go to your GitHub account settings.
2. Click on "Developer settings".
3. Click on "Personal access tokens".
4. Choose "Fine-grained tokens".
5. Click on "Generate new token".
6. Enter a name for the token (e.g., "DEPENDABOT_PAT"). 
7. Enter the expiration date for the token. 
8. Enter a description for the token (e.g., "PAT to allow Dependabot auto-merge for Pull Requests."). 
9. Select the Repositories that grant access to the token. 
10. Select the necessary repository permissions:
    - `metadata` (READ)
    - `commit statuses` (READ, WRITE)
    - `contents (code)` (READ, WRITE)
    - `deployments` (READ, WRITE)
    - `pull requests` (READ, WRITE)
11. Click on "Generate token". 
12. Copy the token and store it in a secure place (e.g., Password manager).

**Note:**
The token is only displayed once and can not be edited or viewed after creation.
If you lose the token, you need to create a new one.


## 2. Use the token as secret in your GitHub repository or as company secret

1. Go to the repository where you want to enable auto-merging.
2. Click on "Settings".
3. Click on "Secrets and variables".
4. Click on "Dependabot". 
5. Click on "New repository secret". 
6. Enter the name of the secret (e.g., "DEPENDABOT_PAT"). 
7. Paste the token into the value field. 
8. Click on "Add secret".

**Note:**
If you want to use the PAT as a company secret, you can add it to the company secrets in the organization settings.
You can then reference the company secret in the repository settings "Secret and variables" > "Dependabot" section.


## 3. Configure Dependabot to use the PAT for auto-merging

The PAT is used to authenticate the merge request and to allow Dependabot to merge the pull request automatically. Only pull requests that are up-to-date and have no conflicts can be merged automatically.
To enable auto-merging of pull requests you have to set up a step in your pipeline that uses the PAT to merge the pull requests.

```yaml
  auto-merge:
    runs-on: ubuntu-latest
    steps:
      - name: Clone project
        uses: actions/checkout@v4.2.2

      - name: Merge PR
        uses: ahmadnassri/action-dependabot-auto-merge@v2.6.6
        with:
          target: minor
          # PAT scopes (Repository permissions): Read access to metadata, Read and Write access to content (code), commit statuses, deployments, and pull requests
          github-token: ${{ secrets.DEPENDABOT_PAT }}
```

To get an example of how to configure the auto-merging process, you can check out the pull request pipeline in the `.github/workflows` folder of this repository.
