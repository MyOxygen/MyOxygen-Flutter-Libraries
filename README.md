# MyOxygen-Flutter-Libraries
This is MyOxygen's Flutter packages repository. It contains all the libraries and packages that are intended to be shared across multiple Flutter packages. 

### Creating a new package

The full step-by-step guide is described in the [Dart docs](https://dart.dev/guides/libraries/create-library-packages) and the [Flutter docs](https://flutter.dev/docs/development/packages-and-plugins/developing-packages). The minimum required goes like so:

1. Clone this repository.
2. Open a terminal and navigate to the `/MyOxgyen-Flutter-Libraries` folder, using `cd /path/to/repo/MyOxygen-FLutter-Libraries`.
3. Still in terminal, run `flutter create --template=package [PACKAGE_NAME]`, replacing `[PACKAGE_NAME]` with the name of the package or library. **Note**: If you are creating a package that requires Android/iOS-specific code, run `flutter create --org uk.co.myoxygen --template=plugin [PACKAGE_NAME]`. This will create the separate `/android` and `/ios` folders, along with the `/example` folder, which should be used for example code implementing the plugin.
4. Commit the new package as is. Mark it as "Initial Commit" (see [Commiting Package Changes](https://github.com/MyOxygen/MyOxygen-Flutter-Libraries#commiting-package-changes) on formatting a commit message).
5. Open the `/.circleci/libraries_test_run.sh` script in a text editor.
6. Add your library name (which should be the folder name) to the list of libraries created with the `declare -a libraries` command.
7. Commit changes.
8. Write code for your library!

### Implementing custom packages

When adding a package dependency in Flutter, the `pubspec.yaml` file will be littered with dependencies (example: `intl: ^0.15.8`). Adding custom packages requires a different layout:

```yaml
[PACKAGE_NAME]:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: path/to/package's/pubspec/file
    ref: [TAG_NAME]
```

As an example, the `QuickDialogs` package is under the `/quickdialogs` folder, and I want to make sure the latest `QuickDialogs` release tag (`QuickDialogs-v0.0.2`) is used. My Flutter project's `pubspec.yaml` file should contain:

```yaml
# MyOxygen libraries/packages
quickdialogs:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: quickdialogs
    ref: QuickDialogs-v0.0.2
```

The full list of tags can be obtained using the `git tag` terminal command.

### Committing Package Changes

Because this repository contains multiple packages, each commit for each library is saved to the main repository's commit history. This makes it difficult to track commits for each library, and it means any breaking changes will be difficult to find from commit to commit. To mitigate this, it is necessary to properly commit changes with adequate messages. Simply having a message like *Added a null-check* does not give sufficient information (which library was changed, where was this change made, etc).

To prevent commits being lost in the "Commit History", the following format is proposed:

```
[<PackageName>] <Commit message>
```
Where:
- `<PackageName>` is the name of the library/package that has been modified.
- `<CommitMessage>` is the standard message that is sent on commit.

Some examples:
```
1. [QuickDialogs] Updated ReadMe.
2. [QuickDialogs] Added a null-check to the callback handler.
3. [InfiniteScrollView] Added tests for null widgets.
4. Updated the main ReadMe file.
```

Examples 1, 2, and 3 clearly state which library they are referring to. This makes it easier to track commits in the main "Commit History".

The format used in example 4 is only expected to be used when changing content **outside the packages folders** like the main ReadMe file.

If you accidentally commit with an incorrect package tag. This can be fixed using `git amend` if the most recent commit, or `git rebase` if not. A more comprehensive guide can be [found here.](https://help.github.com/en/github/committing-changes-to-your-project/changing-a-commit-message).

### Releasing a new version

When releasing a new version of whichever package, it is important to assign a tag to the commit that marks it as "released". Tag names should be in the following format:

```
<PackageName>-v<semantic.version.number>

Example:
QuickDialogs-v0.0.2
```

This makes referencing a specific library and commit much easier than having to write the commit hash (which is really unhelpful). It also means that no two tags then clash. For example, `QuickDialogs`'s version 0.0.2 should not clash with `InfiniteScrollView`'s version 0.0.2, if the tags `QuickDialogs-v0.0.2` and `InfiniteScrollView-v0.0.2` respectively are used. When looking at a list of tags, this will make it easy to tell which version each package is on.

### FAQs

> How does versioning work?

Each package has a `pubspec.yaml` file. Because you are creating a dependency to a repository, `pub` will not search for the `pubspec.yaml`'s version number (I think). It is up to the developer to keep the version number up to date for documentation and traceability purposes, but versioning can only happen by referencing the right tag.

> If someone introduces a breaking change to a package, will all the projects that rely on it also break?

No. If you are referencing a specific tag, you will only be getting the code from that tag. If breaking changes occur **after** that tag-reference, but you haven't referenced the new commits/tags, nothing will happen.

> Do I have to pull down all the libraries just to access one?

No, `pub` will look for the `pubspec.yaml` file to import the necessary package. You will not be importing all the packages, only the one you wish to import. However, for every local package, you will have to point to the git repository, the path, and the tag name.
