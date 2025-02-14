# Troubleshooting

### Install or update error: "You don't have write permissions for the /usr/bin directory."

If you're facing the following error on macOS when installing or updating CocoaPods:

```
ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /usr/bin directory.
```

Try executing the following command instead:

```shell
sudo gem install cocoapods -n/usr/local/bin
```

### Install or update error: "activesupport"

If an error message suggests to install `activesupport`, do so and try installing CocoaPods again.
