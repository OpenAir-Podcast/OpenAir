fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### github_release

```sh
[bundle exec] fastlane github_release
```

Upload build artifacts to an existing GitHub release

### draft

```sh
[bundle exec] fastlane draft
```

Build and upload draught release for current tag

----


## Android

### android build_apk

```sh
[bundle exec] fastlane android build_apk
```

Build a release APK

### android build_aab

```sh
[bundle exec] fastlane android build_aab
```

Build a release app bundle (AAB)

### android build_all

```sh
[bundle exec] fastlane android build_all
```

Build both APK and AAB

### android update_metadata

```sh
[bundle exec] fastlane android update_metadata
```

Upload metadata to F-Droid

----


## linux

### linux build_targz

```sh
[bundle exec] fastlane linux build_targz
```

Build a release Linux bundle (tar.gz)

### linux build_appimage

```sh
[bundle exec] fastlane linux build_appimage
```

Build a Linux AppImage

### linux build_all

```sh
[bundle exec] fastlane linux build_all
```

Build both tar.gz and AppImage

----


## windows

### windows build_zip

```sh
[bundle exec] fastlane windows build_zip
```

Build a release Windows EXE (zip)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
