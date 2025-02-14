# Publish apps to app stores

This mobile app is deployed to the Apple App Store and the Google Play Store using [fastlane](https://fastlane.tools/) and [GitHub Actions](https://docs.github.com/en/actions).

_Note: The following steps involve generating secrets and keys. Make sure to securely store and share all generated secrets and keys using a password manager._

## Steps

1. [Install fastlane](#install-fastlane)
2. iOS
   1. [Add Identifier to Apple Developer Account](#add-identifiers-to-apple-developer-account)
   2. [Add App to Apple App Store Connect](#add-apps-to-apple-app-store-connect)
   3. [Create fastlane GitHub repo](#create-fastlane-github-repo)
   4. [Create or update distribution Profiles and Certificates](#create-or-update-distribution-profiles-and-certificates)
   5. (optional) [Delete distribution Profiles and Certificates](#delete-distribution-profiles-and-certificates)
   6. [Create GitHub Deploy Key](#create-github-deploy-key)
   7. [Create Apple App Store Connect API Key](#create-apple-app-store-connect-api-key)
   8. [Add GitHub Action repository variables and secrets for iOS](#add-github-action-repository-variables-and-secrets-for-ios)
3. Android
   1. [Create Google Service Account](#create-google-service-account)
   2. [Create Android Keystore Upload JKS](#create-android-keystore-upload-jks)
   3. [Create Android Keystore Properties](#create-android-keystore-properties)
   4. [Add GitHub Action repository variables and secrets for Android](#add-github-action-repository-variables-and-secrets-for-android)

## Install fastlane

Install [fastlane](https://fastlane.tools/) – e.g., with [Brew](https://formulae.brew.sh/formula/fastlane).

## Add Identifiers to Apple Developer Account

1. Login to your [Apple developer account](https://developer.apple.com/account) as member of `Hochschule fuer Musik Nuernberg`
2. Open [Certificates, Identifiers & Profiles of your developer account](https://developer.apple.com/account/resources/identifiers/list)
3. Click on the `+` icon to add a new Identifier
4. Select `App IDs`
5. Click on `Continue`
6. Select `App`
7. Click on `Continue`
8. Enter a `Description` (e.g., `TIO-Music`)
9. Enter a `Bundle ID` (e.g., `de.hfm-nuernberg.tiomusic`)
10. Select the following `Capabilities`:
    - `App Attest`
11. Click on `Continue`
12. Click on `Register`

## Add Apps to Apple App Store Connect

1. Login to your [Apple App Store Connect](https://appstoreconnect.apple.com) as member of `Hochschule fuer Musik Nuernberg`
2. Open [Apps](https://appstoreconnect.apple.com/apps)
3. Click on the `+` icon to add a new App
4. Select `App` from the popup
5. Select `iOS` under `Platforms`
6. Enter a `Name` (e.g., `TIO-Music`)
7. Select `German` as `Primary Language`
8. Choose the `Bundle ID` you created in the previous steps
9. Use the `Bundle ID` as `SKU`
10. Select `Limited Access` under `User Access`

## Create fastlane GitHub repo

1. Create a new GitHub repository: `TIO-fastlane`
   - _Note: Use `master` as trunk instead of `main`._
2. Create a new git project on your machine:
   1. `mkdir TIO-fastlane`
   2. `cd TIO-fastlane`
   3. `git init`
   4. `git branch -M master`
3. Commit an empty `README.md` file:
   1. `touch README.md`
   2. `git add README.md`
   3. `git commit -m "initial commit"`
4. Connect and push the git project to GitHub
   1. `git remote add origin git@github.com:hfmnuernberg/TIO-fastlane.git`
   2. `git push -u origin master`

## Create or update distribution Profiles and Certificates

The following step will **create** distribution [Profiles](https://developer.apple.com/account/resources/profiles/list)
and [Certificates](https://developer.apple.com/account/resources/certificates/list) to
the [Apple developer account](https://developer.apple.com/account) (if they don't exist yet), update/add them to
the [fastlane repo](https://github.com/hfmnuernberg/TIO-fastlane), and update/add them to your keychain.

Clone the [fastlane repo](https://github.com/hfmnuernberg/TIO-fastlane) and switch into the cloned directory.

Execute the following command to generate the development certificates and profiles:

```shell
fastlane match development
```

When prompted provide the following information (you will be asked to provide some details multiple times):

- URL to the git repo: `git@github.com:hfmnuernberg/TIO-fastlane.git`
- Passphrase for Match storage: `<generate-a-password>`
- Username: `<your-apple-id>`
- Password: `<your-password>`
- Team: `Hochschule fuer Musik Nuernberg`
- Bundle identifiers: `de.hfm-nuernberg.tiomusic`
- 6 digit token: `<apple-verification-token>`
- Password for login keychain: `<generate-a-password>`
- Your Apple ID Username: `<your-apple-id>`

Repeat the process for the distribution certificates and profiles:

```shell
fastlane match appstore
```

When prompted provide the information listed above.

Pull the latest changes:

```shell
git pull
```

## Delete distribution Profiles and Certificates

The following step will **delete** distribution [Profiles](https://developer.apple.com/account/resources/profiles/list)
and [Certificates](https://developer.apple.com/account/resources/certificates/list) from
the [Apple developer account](https://developer.apple.com/account), from
the [fastlane repo](https://github.com/hfmnuernberg/TIO-fastlane), and your keychain. This can be useful, in case the profiles and certificates need to be recreated.

Clone the [fastlane repo](https://github.com/hfmnuernberg/TIO-fastlane) and switch into the cloned directory.

Execute the following commands to delete the development certificates and profiles:

```shell
fastlane match nuke development
```

When prompted provide the information listed above.

Repeat the process for to delete the distribution certificates and profiles:

```shell
fastlane match nuke distribution
```

When prompted provide the information listed above.

Pull the latest changes:

```shell
git pull
```

## Create GitHub Deploy Key

1. Generate a new ssh key
   1. `cd ~/.ssh`
   2. `ssh-keygen -t ed25519 -C "Relevel@hfm-nuernberg.de"`
   3. Enter `id_tio_fastlane` when asked for the filename
   4. Skip the passphrase by hitting enter twice
2. Open the [fastlane repo](https://github.com/hfmnuernberg/TIO-fastlane)
3. Navigate to `Settings` > `Deploy keys`
4. Click `Add deploy key`
5. Enter a `Title`: `fastlane-github-deploy-public-key`
6. Copy the public key `cat id_tio_fastlane.pub | pbcopy`
7. Paste the public key as 'Key' into the form
8. Click `Add key`

## Create Apple App Store Connect API Key

1. Navigate to the [Integrations](https://appstoreconnect.apple.com/access/integrations/api) tab under `Users and Access`
2. Click on `Generate API Key`
3. Enter a name: `fastlane`
4. Select `App Manager` under `Access`
5. Click on `Generate`
6. Download the API Key
7. Note the `Issuer ID`
8. Note the `KEY ID`

## Add GitHub Action repository variables and secrets for iOS

1. Open the [TIO repo](https://github.com/hfmnuernberg/TIO)
2. Navigate to `Settings` > `Secrets and variables`
3. Add a variable `APPLE_DEVELOPER_TEAM_ID`
   - As value, use the team's developer team id (e.g., see [Membership details](https://developer.apple.com/account#MembershipDetailsCard))
4. Add a variable `APPLE_APP_STORE_CONNECT_API_ISSUER_ID`
   - As value, use the team's issuer id (e.g., can be found under [Integrations](https://appstoreconnect.apple.com/access/integrations/api) under Users and Access)
5. Add a variable `APPLE_APP_STORE_CONNECT_API_KEY_ID`
   - As value, use the `KEY ID`, generated when [creating the Apple App Store Connect API Key](#create-apple-app-store-connect-api-key)
6. Add a secret `APPLE_APP_STORE_CONNECT_API_KEY_SECRET`
   - As value, use the content of the `API Key` file, downloaded when [creating the Apple App Store Connect API Key](#create-apple-app-store-connect-api-key)
7. Add a secret `FASTLANE_GITHUB_DEPLOY_PRIVATE_KEY`
   - As value, use the Fastlane GitHub Deploy Private Key, generated when [creating the GitHub Deploy Key](#create-github-deploy-key) (copy with: `cat id_tio_fastlane | pbcopy`)
8. Add a secret `FASTLANE_GITHUB_MATCH_STORAGE_PASSWORD`
   - As value, use the passphrase, generated when [creating distribution Profiles and Certificates](#create-or-update-distribution-profiles-and-certificates)

## Create Google Service Account

_Note: The following steps follow the instructions, outlined [here](https://docs.fastlane.tools/getting-started/android/setup/)._

1. Create a service account user
   1. Open the [Google Cloud Console](https://console.cloud.google.com/iam-admin/serviceaccounts?hl=en)
   2. Select the correct Google Cloud project (e.g., `hfm-nuernberg`)
   3. Navigate to `IAM` > `Service Account`
   4. Click on `CREATE SERVICE ACCOUNT` at the top
   5. Enter a `Service account name`: `fastlane`
   6. Enter a `Service account ID`: `fastlane`
   7. Enter a `Service account description`: `Used by GitHub action workflows to upload Android build bundles to Google PlayStore`
   8. Do **not** click on `CREATE AND CONTINUE` (ignore the granting steps)
   9. Click on `DONE`
   10. Copy the generated service account email address (first column of table, e.g., `fastlane@hfm-nuernberg.iam.gserviceaccount.com`)
2. Create a service account json file
   1. Click on the actions menu (three vertical dots in the actions column of the table)
   2. Select `Manage keys`
   3. Click on `ADD KEY`
   4. Select on `Create New Key`
   5. Select `JSON` as key type
   6. Click on `CREATE`
   7. Download and securely store the json file (do **not** commit this file to git)
3. Invite the service account user to the Google Play Console
   1. Open the [Google Play Console](https://play.google.com/console/?hl=en)
   2. Navigate to `Users and Permissions`
   3. Click on `Invite new users`
   4. Paste the service account email address, copied earlier
   5. Click on `Account Permissions`
   6. Ensure the following permissions are selected:
      - `View app information and download bulk reports (read-only)`
      - `Create, edit, and delete draft apps`
      - `Release to production, exclude devices, and use Play App Signing`
      - `Release apps to testing tracks`
      - `Manage testing tracks and edit tester lists`
   7. Click on `Invite User`

## Create Android Keystore Upload JKS

_Note: The following steps follow the instructions, outlined [here](https://docs.flutter.dev/deployment/android#signing-the-app)._

1. Generate an upload keystore file:

   ```shell
   keytool -genkey \
     -keystore android/app/keystore/upload.keystore.jks \
     -keyalg RSA \
     -keysize 2048 \
     -validity 10000 \
     -alias upload \
     -v
   ```

2. Generate, securely store, and provide a keystore password when prompted:

   ```
   Enter keystore password:  
   
   Re-enter new password:
   ```

3. Provide the following information when prompted:

   ```
   Warning:  Different store and key passwords not supported for PKCS12 KeyStores. Ignoring user-specified -keypass value.
   Enter the distinguished name. Provide a single dot (.) to leave a sub-component empty or press ENTER to use the default value in braces.
   What is your first and last name?
   [Unknown]:  <your-name>
   What is the name of your organizational unit?
   [Unknown]:  IT         
   What is the name of your organization?
   [Unknown]:  Hochschule fuer Musik Nuernberg
   What is the name of your City or Locality?
   [Unknown]:  Nuernberg
   What is the name of your State or Province?
   [Unknown]:  Bayern
   What is the two-letter country code for this unit?
   [Unknown]:  DE
   Is CN=<your-name>, OU=IT, O=Hochschule fuer Musik Nuernberg, L=Nuernberg, ST=Bayern, C=DE correct?
   [no]:  yes
   
   Generating 2,048 bit RSA key pair and self-signed certificate (SHA384withRSA) with a validity of 10,000 days
   for: CN=<your-name>, OU=IT, O=Hochschule fuer Musik Nuernberg, L=Nuernberg, ST=Bayern, C=DE
   [Storing android/app/keystore/upload.keystore.jks]
   ```

4. Securely store the generated upload keystore file  (do **not** commit this file to git).

## Create Android Keystore Properties

1. Create a `key.properties` file according to the following scheme (consider copying [`key.properties.debug`](../android/key.properties.debug)):

   ```properties
   storeFile=keystore/upload.keystore.jks
   storePassword=<keystore-password>
   keyAlias=upload
   keyPassword=<keystore-password>
   ```

2. Replace `<keystore-password>` with the keystore password generated earlier.

3. Securely store the `key.properties` file  (do **not** commit this file to git).

## Add GitHub Action repository variables and secrets for Android

1. Open the [TIO repo](https://github.com/hfmnuernberg/TIO)
2. Navigate to `Settings` > `Secrets and variables`
3. Add a secret `ANDROID_KEYSTORE_PROPERTIES`
   - As value, use the Base64-encoded content of the `key.properties` file, created earlier
   - `cat key.properties | base64 | pbcopy`
4. Add a secret `ANDROID_KEYSTORE_UPLOAD_JKS`
   - As value, use the Base64-encoded content of the upload keystore file, generated earlier
   - `cat upload.keystore.jks | base64 | pbcopy`
5. Add a secret `GOOGLE_SERVICE_ACCOUNT`
   - As value, use the Base64-encoded content of the Google service account json file, generated earlier
   - `cat tio-music-<123456789>.json | base64 | pbcopy`
