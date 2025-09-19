# Update cargo dependencies for Rust code

## Update Cargo minor and bugfix versions

**1. Check which dependencies are outdated**

In the rust folder, check the currently outdated dependencies by running:
```shell
app outdated
```

The cargo outdated list mixes direct and transitive deps. To start with root-only dependencies (the Cargo.toml entries) use:
```shell
app outdated:root
```

**2. Update lockfile to latest compatible (non-breaking) across the board:**

```shell
app update
```

**3. Update version *requirements* in Cargo.toml to the latest compatible ones**

```shell
app upgrade
```

**4. Re-run updating the lockfile to ensure everything is in sync**

```shell
app update
``` 

**5. Verify what's left (should now be only the breaking majors):**

```shell
app outdated:root
```

You should end up with just the known “review-needed” candidates.
