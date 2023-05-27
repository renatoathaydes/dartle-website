{{ define title "Derived Build Tools" }}\
{{ define order 7 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Helper functions" }}

Most build tools need to perform some tasks, like packaging/unpackaging artifacts and downloading things,
which may not be so easy using just the Dart standard library.

Dartle tries to fill the gap with the following helper functions:

* [`download`](https://pub.dev/documentation/dartle/latest/dartle_dart/download.html)

For downloading binary data.

Example:

```dart
main() async {
  final stream = download(
      Uri.parse('https://example.org/assets/artifact'));
  await File('artifact').writeBinary(magStream, makeExecutable: true);
}
```

The above example also uses the `writeBinary` extension function on `File`, provided by Dartle.

All download functions can configure:

* HTTP headers.
* HTTP cookies.
* a `SecurityContext` for custom TLS settings.
* a `connectionTimeout`.
* a `isSuccessfulStatusCode` function.

For example:

```dart
final stream = download(
    Uri.parse('https://example.org/assets/artifact'),
    headers: (h) => h.add('Accept', 'image/jpg'),
    cookies: (c) => c.add(Cookie('mycookie', 'hello')),
    isSuccessfulStatusCode: const {200, 201}.contains,
    context: SecurityContext(withTrustedRoots: true),
    connectionTimeout: Duration(seconds: 3),
);
```

* [`downloadText`](https://pub.dev/documentation/dartle/latest/dartle_dart/downloadText.html)

For downloading text data.

It works similarly to `download`, but returns a `Future<String>`.

Besides the `download` configuration options, `downloadText` also accepts a `Encoding encoding` parameter.

* [`downloadJson`](https://pub.dev/documentation/dartle/latest/dartle_dart/downloadJson.html)

For downloading and automatically parsing JSON data.

It works similarly to `download`, but returns a `Future<Object?>`.

It takes the same options as `downloadText`.

* [tar](https://pub.dev/documentation/dartle/latest/dartle_dart/tar.html)

Tars files in a [FileCollection](file-collections.html) into a tar ball.

By default, it gzips the archive, but another encoding, or no encoding, can also be used.

Example:

```dart
Future<void> distribution(_) => tar(dir('target'),
    destination: 'mytar.tar.gz',
    // optionally remap resources locations in the destination archive
    destinationPath: (p) => p == executable ? 'bin/$p' : p);
```

To make sure gzip is not used, set the encoder function to `NoEncoding`:

```dart
Future<void> distribution(_) => tar(dir('target'),
    destination: 'mytar.tar.gz',
    // ensure no gzip is used, or use a different compression algorithm
    encoder: const NoEncoding());
```

* [untar](https://pub.dev/documentation/dartle/latest/dartle_dart/untar.html)

Untars a tarball on a given directory.

By default, `.tar.gz` files are decompressed using gzip, other extensions are assumed to not be compressed.

To change the default behaviour, provide a `decoder` explicitly.

Example:

```dart
main() async {
  await untar('my.tar.gz', destinationDir: tempDir().path);
}
```

* [tempDir](https://pub.dev/documentation/dartle/latest/dartle_dart/tempDir.html)

Creates a temporary directory (under the system's temporary directory).

Example:

```dart
final temp = tempDir(suffix: 'my-tests');
```

* [homeDir](https://pub.dev/documentation/dartle/latest/dartle_dart/homeDir.html)

Get the user home directory if available.

Example:

```dart
final home = homeDir() ?? tempDir().path;
```

* [ignoreExceptions](https://pub.dev/documentation/dartle/latest/dartle_dart/ignoreExceptions.html)

Sometimes, it's unavoidable that a build must run some action in a best-effort manner. If it fails, nothing
significant should happen. This is often the case with cleanup tasks, specially given that Dart's `File.delete`
can throw if the file does not exist (which can be safely ignored, as the objective was to make sure the file didn't exist).

Example:

```dart
main() async {
  await ignoreExceptions(() => File('somefile').delete());
}
```

* [failBuild](https://pub.dev/documentation/dartle/latest/dartle_dart/failBuild.html)

Fails a build by throwing a `DartleException`, which is handled cleanly by Dartle.

Example:

```dart
main() {
  if (Platform.isWindows) {
    failBuild(reason: 'Cannot run on Windows');
  }
}
```

As `failBuild` always throws, it returns `Never`, so it enables Dart flow analysis to work:

```dart
main() {
  String? s = null;
  if (s == null) {
    failBuild(reason: 's must not be null');
  }
  // OK: s is non-null here
  print(s.length);
}
```

* [deleteAll](https://pub.dev/documentation/dartle/latest/dartle_dart/deleteAll.html)

Deletes all files included in a [FileCollection](file-collections.html).

Example:

```dart
main() async {
  await deleteAll(dir('target'));
}
```

* [createCleanTask](https://pub.dev/documentation/dartle/latest/dartle_dart/createCleanTask.html)

Creates a task that, when executed, deletes the outputs of all given tasks.

Example:

```dart
final compileTask = Task(compile);
final linkTask = Task(link);

main(List<String> args) => run(args, tasks: {
      compileTask,
      linkTask,
      createCleanTask(tasks: [compileTask, linkTask]),
    });
```

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}