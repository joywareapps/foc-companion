# Release Process

FOC Companion releases are built and published automatically by
[`beta-distribution.yml`](.github/workflows/beta-distribution.yml), which
triggers on any pushed tag matching `v*`. Cutting a release is just:
bump the version, tag it, push the tag.

## Steps

1. **Make sure `master` is up to date** and has everything you want to
   release merged in.

2. **Bump the version** in `foc-companion/pubspec.yaml`:

   ```yaml
   version: X.Y.Z+N
   ```

   - `X.Y.Z` is the semantic version shown to users (Android `versionName`,
     app "About" screen, etc.).
   - `N` is the build number (Android `versionCode`). It must **strictly
     increase** on every release — Android will refuse to install an
     update with a build number lower than or equal to what's installed.

   Convention: bump the patch digit (`Z`) and increment `N` by 1, e.g.
   `1.5.2+25` → `1.5.3+26`. Use a minor/major bump for larger changes.

3. **Commit the version bump** on its own, using the existing convention:

   ```bash
   git commit -am "Bump version to X.Y.Z+N"
   ```

4. **Tag the commit** with a `v`-prefixed, `+build` **excluded**, tag:

   ```bash
   git tag vX.Y.Z
   ```

5. **Push the commit and the tag**:

   ```bash
   git push origin master
   git push origin vX.Y.Z
   ```

Pushing the tag triggers the `Beta Distribution` GitHub Action, which:

- Builds the Windows release EXE and zips it.
- Builds the Android release APK.
- Generates release notes from `git log` between this tag and the
  previous `v*` tag.
- Creates a GitHub Release named `Release vX.Y.Z` with both artifacts
  attached.
- Uploads the APK to Firebase App Distribution (`beta-testers` group),
  which emails everyone enrolled in the beta program.

No further manual steps are needed — the workflow handles building,
release-note generation, and distribution.

## Notes

- The workflow can also be run manually via `workflow_dispatch` from the
  Actions tab (useful for rebuilding an existing tag without changing
  code), but it will only attach the resulting APK/EXE to a GitHub
  Release if it was triggered by a tag push.
- The `dev-latest` GitHub Release referenced from `README.md` is
  maintained separately from this workflow (not automated here).
