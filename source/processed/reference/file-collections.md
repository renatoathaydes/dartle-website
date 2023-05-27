{{ define title "Derived Build Tools" }}\
{{ define order 7 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "File Collections" }}

Dartle comes with a powerful [`FileCollection`](https://pub.dev/documentation/dartle/latest/dartle_dart/FileCollection-class.html) type.
It makes it easy to work with files and directories.

File collections are mostly used with [RunOnChanges](https://pub.dev/documentation/dartle/latest/dartle_dart/RunOnChanges-class.html),
which can be used as a `runCondition` of a Task.

### Files

To create a `FileCollection` containing a single file:

```dart
final afile = file('myfile.txt');
```

Multiple files:

```dart
final someFiles = files({'myfile.txt', 'another/file.md'});
```

### Directories

To create a `FileCollection` containing a single directory, with everything within it except for
hidden files (whose names start with `.`):

```dart
final adir = dir('mydir');
```

Many options are available to filter only certain files:

```dart
final aCollection = dir('mydir', fileExtensions: {'.dart', '.rs'}, 
    exclusions: {'do-not-include.txt'},
    recurse: false,
    includeHidden: true,
    allowAbsolutePaths: true); // not recommended, makes a build non-deterministic
```

A `dirs` function is also available for cases where more than one root directory exists which takes the
same options as `dir`.

### Both files and directories

For selecting both files and directories, use `entities`:

```dart
final myCollection = entities( // declare both files and directories
  const ['dartle.dart'], // files
  [DirectoryEntry(path: 'source', fileExtensions: const {'.dart', '.c'})]); // dirs
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Resolving File Collections" }}

`FileCollection` has a few methods for resolving the current state of the file system.

* `resolve()` returns everything, including directories and files.
* `resolveFiles()` returns only the files.
* `resolveDirectories()` returns only the directories.

Notice that there's also `includedEntities()`, which does not **resolve** the collection, but returns the
file system entities included explicitly in the collection.

> To delete everything in a `FileCollection`, use
> [deleteAll](https://pub.dev/documentation/dartle/latest/dartle_dart/deleteAll.html).

To check if a certain file or directory _belongs_ to a `FileCollection`, use `includesFile` and
`includesDirectory`, respectively.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Combining FileCollections" }}

`FileCollection` was designed to be easily combinable.

The following methods are provided for combining two collections:

* `intersection` - returns a new `FileCollection` with only the entities included in both collections.
* `union` - returns a new `FileCollection` with all entities included in either collection.

The `+` operator is implemented by delegating to `union`.

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}