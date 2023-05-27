{{ define title "Derived Build Tools" }}\
{{ define order 7 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Executing processes" }}

Every build tool must be able to execute processes, and Dartle is no different.

> For portability, prefer to implement build Tasks in pure Dart.

All functions shown below take a `Future<Process>`, which is returned by calling Dart's
[`Process.start()` function](https://api.dart.dev/stable/3.0.2/dart-io/Process/start.html).

The following functions are provided to make it easier to execute processes and consume their outputs:

* `exec`

The most basic helper function, `exec` consumes the process `stdout` and `stderr`, making them available
via optional callbacks that execute for each line.

Example throwing away the process output:

```dart
main() async {
  final code = await exec(Process.start('ls', const []));
  print(code);
}
```

Example delegating the process output to the current process's `stdout` and `stderr`:

```dart
main() async {
  final code = await exec(Process.start('ls', const []),
      onStdoutLine: stdout.writeln, onStderrLine: stderr.writeln);
  print(code);
}
```

* `execProc`:

This function is similar to [exec], but simpler to use for cases where
it is desirable to redirect the process' streams and automatically fail
depending on the exit code (non-zero codes are treated as failure by default).

Instead of handling the process output, a `StreamRedirectMode` can be used to select a strategy for how to
handle it depending on whether the process succeeds or not:

* `stdout` - redirect only stdout.
* `stderr` - redirect only stderr.
* `stdoutAndStderr` - redirect both.
* `none` - redirect none.

This example only redirects the process' output in case of failure (a common strategy for a build system to use):

```dart
main() async {
  final code = await execProc(Process.start('ls', const []),
      successMode: StreamRedirectMode.none,
      errorMode: StreamRedirectMode.stdoutAndStderr);
  print(code);
}
```

> The above modes are the defaults, so the `successMode` and `errorMode` arguments could be omitted.

If you want to allow non-zero exit codes to be treated as successful, set the `isCodeSuccessful`
function:

```dart
main() async {
  final code = await execProc(Process.start('ls', const []),
      isCodeSuccessful: const {0, 1, 2, 3}.contains);
  print(code);
}
```

* `execRead`

Use this function when you need to collect the process output lines into a `List<String>`.

It allows filtering output and, like `execProc`, allows configuring a `isCodeSuccessful` function.

This example counts how many output lines match a regular expression:

```dart
main() async {
  final result = await execRead(Process.start('ls', const []),
      stdoutFilter: RegExp('\w\s+\w').hasMatch);
  print(result.stdout.length);
}
```

> For more helper functions, see [Helper functions](helper-functions.html).

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}