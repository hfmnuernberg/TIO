# Update cargo dependencies for Rust code

## Update Cargo minor and bugfix versions

1. Check which dependencies are outdated

In the rust folder, check the currently outdated dependencies by running:
```shell
cargo outdated
```

The cargo outdated list mixes direct and transitive deps. To start with root-only dependencies (the Cargo.toml entries) use:
```shell
cargo outdated -R
```

2. Update lockfile to latest compatible (non-breaking) across the board:

```shell
cargo update
```

3. Update version *requirements* in Cargo.toml to the latest compatible ones

```shell
cargo upgrade
```

4. Re-run updating the lockfile to ensure everything is in sync

```shell
cargo update
``` 

5. Verify what's left (should now be only the breaking majors):

```shell
cargo outdated -R
```

You should end up with just the known “review-needed” candidates.
