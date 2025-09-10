# Update Rust (Editions, Toolchain, Flutter-Rust-Bridge side)


## Content:

1. [Important notes](#important-notes)
2. [Which version to choose?](#latest-stable-or-latest-stable-with-edition-support)
   - Updating MSRV to [latest stable](#updating-msrv-to-latest-stable-example-1890-upcoming-edition-202425) VS [latest stable with Edition support](#updating-msrv-to-latest-stable-with-edition-support-example-1850-for-edition-2024)
   - [Rule of thumb](#rule-of-thumb)
3. [Update Rust (Rust version, Edition, Toolchain, Flutter/FRB side, re-resolve deps)](#update-rust)


## Important notes

"rust-version" in Cargo.toml is the **MSRV (Minimum Supported Rust Version)**.
- If you truly want to raise the version to the newest supported, set it to the current stable (e.g., 1.89.0). That guarantees everyone builds with a modern compiler, but it drops support for older toolchains.
- If you want the lowest version that still supports latest Edition crates (e.g., coreaudio-sys), use e.g, 1.85.0. As of today, that’s the first stable with Edition 2024.


## Latest stable or latest stable with Edition support?

### Updating MSRV to latest stable (example: 1.89.0, upcoming edition 2024/25)

Pros
- Maximum forward-compatibility: virtually all crates that have raised MSRV in 2024/2025 (including those adopting Edition 2024) will build.
- Newer compiler optimizations, faster builds, newer std features, newer lints.
- Fewer “requires newer Cargo” errors when transitive deps adopt new features.

Cons
- Drops support for devs/CI agents still on older toolchains; everyone must have ≥1.89.
- More clippy/rustfmt diffs and lint breakages (new lints become warnings/errors).
- You may need to refresh prebuilt images/caches more often (CI base images, Docker).

### Updating MSRV to latest stable with Edition support (example: 1.85.0 for Edition 2024)

Pros
- Solves your immediate problem (crates using edition = "2024" compile) with the lowest necessary MSRV.
- Keeps a slightly wider contributor base (anyone on 1.85–1.88 is fine).
- Fewer lint/style churns than jumping straight to 1.89.0.

Cons
- You can still hit MSRV bumps later if crates start requiring >1.85. (Then you’ll need to raise MSRV again.)
- You won’t get the very latest compiler improvements/lints until you move again.

### Rule of thumb
- If you want minimal change now but to compile Edition-2024 crates: choose 1.85.0.
- If you prefer to future-proof and avoid repeating this soon: choose 1.89.0.


## Update Rust

**1. Check the latest version of Rust on the [Rust release page](https://releases.rs/). There you can also find the list of versions and related changelogs.**

**2. Check the latest edition of Rust on the [Rust editions page](https://doc.rust-lang.org/edition-guide/editions/index.html).**

_Note:_
- The edition is updated as last step, after updating the Rust version. This is because the edition can be updated independently of the Rust version, but newer editions require a minimum Rust version (e.g., edition = "2024" require a compiler ≥1.85).
- Rust editions are mostly about syntax and linting changes. The edition can be specified in the `Cargo.toml` file.

**3. Check the currently installed Rust version by running:**

```shell
rustc --version
```

**4. Check the currently installed and active toolchain by running:**

```shell
app doctor
```

_Note:_
- Rustup is the recommended tool to manage Rust versions and toolchains.
- If you do not have rustup installed, follow the instructions on the [rustup installation page](https://rustup.rs/).
- If you care about installer/management behaviors, check rustup’s CHANGELOG on GitHub: [rust-lang/rustup CHANGELOG](https://github.com/rust-lang/rustup/blob/master/CHANGELOG.md)
- If you have multiple toolchains installed (e.g., stable, beta, nightly), ensure you are updating the correct one.

**5. Open [rust/Cargo.toml](../rust/Cargo.toml) and change the `rust-version` field to the desired version (e.g., "1.85.0"):**

```toml
[package]
rust-version = "1.85.0"
```

_Optional but recommended:_
Update the Edition to the latest (e.g., "2024") if you want to use new syntax/lints. This is not strictly necessary just
to compile Edition-2024 crates, but it’s a good idea to stay current.
  
```toml
[package]
edition = "2024"
```

Then run:

```shell
app install:edition
```

_Note: If you run into issues during updating the Edition, run the update command later, after running the version update
command (step 10)._

**6. Pin the local toolchain to the desired version. Edit [rust-toolchain.toml](../rust-toolchain.toml) at the repo root to:**

```toml
[toolchain]
channel = "1.85.0"
versioned = "1.85.0"
```

If the file has other fields, keep them; just set `channel` and `versioned` to the new version (e.g., 1.85.0).

**7. Install & use that toolchain:**

```shell
app install:toolchain 1.85.0
cargo +1.85.0 --version
```

If you want to uninstall an old toolchain (any installed toolchain that is not the current default), run:

```shell
rustup toolchain uninstall <OLD_VERSION>
```

**8. ONLY if you added any temporary pins, remove them.**

If you previously added a workaround like

```toml
[patch.crates-io]
coreaudio-sys = "=0.2.16"
```

in Cargo.toml to force a specific version, remove that now, then:

```shell
cargo update -p coreaudio-sys
```

**9. Re-resolve & build on new version (e.g., 1.85.0)**

In rust folder, where the [Cargo.toml](/rust/Cargo.toml) is:

```shell
app update
app build
```

**10. Run formatting and linting:**

```shell
app format
app lint
```

**11. Run tests:**

```shell
app test
```

**12. Check CI configuration**

- If you have a GitHub Action or other CI, check the Rust version used there.
- Update it to the new version, e.g., 1.85.0 (or rustup update 1.85.0) before build/test.

**13. Flutter/FRB side**

In rust folder, run this to install the flutter_rust_bridge_codegen CLI (one-time / when upgrading) and cargo-ndk:

```shell
app install:frb
```

_Note:
If the installed rust-version from Cargo.toml is >= 1.86.0, it installs the latest cargo-ndk, otherwise cargo-ndk 3.5.4._

Then run this, to actually create/update the bindings:

```shell
app generate
```

**14. Update Edition (when new Edition is available):**

**Important:**
Installing a new edition can make many changes, so it’s best to commit first before and do it in a separate commit.

In rust folder, change Edition in [Cargo.toml](../rust/Cargo.toml):
```toml
[package]
edition = "2024"
```

Make sure the rust-version is set correct (e.g., 1.85.0 supports edition 2024).
When changing the edition in Cargo.toml is done run:

```shell
app install:edition
```

**15. Start the app:**

```shell
app run ios
```

If something is not working, try to clean and rebuild:

```shell
app clean
app generate:rust
app run ios
```
