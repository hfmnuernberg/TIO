# App Script – a helper script for regularly used commands

You can run many common commands more conveniently with help of the app [shell script](../scripts/app.sh):

```shell
scripts/app.sh <command> [args]
# e.g.:
# scripts/app.sh help
# or
# scripts/app.sh test
```

By adding a function as an `app` alias to your shell profile, you can execute the commands even more conveniently.

Add the following function to your shell profile (e.g., to `~/.oh-my-zsh/custom/aliases.zsh`):

```shell
app () { ./scripts/app.sh "$@"; }
```

Now you can run the script even more conveniently:

```shell
app <command> [args]
# e.g.:
# app help
# or
# app test
```

## Installing additional tools

Some app script commands require additional command-line tools to be installed:

- `dart` (see [Setup](./setup.md))
- `fastlane` (see [Setup](./setup.md))
- `flutter` (see [Setup](./setup.md))
- `genhtml` (see `lcov`)
- `lcov` (e.g., with [Brew](https://formulae.brew.sh/formula/lcov))
- `pod` (see [Setup](./setup.md))
- `rustup` (see [Setup](./setup.md))
- `watchexec` (e.g., with [Brew](https://formulae.brew.sh/formula/watchexec))
