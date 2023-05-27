{{ define title "Dartle Home" }}\
{{ define order 0 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

Welcome to the Dartle Documentation.

[![Dartle CI](https://github.com/renatoathaydes/dartle/workflows/Dartle%20CI/badge.svg)](https://github.com/renatoathaydes/dartle/)
[![pub package](https://img.shields.io/pub/v/dartle.svg)](https://pub.dev/packages/dartle)

To learn Dartle from the basics, check out the [Dartle Overview](dartle-overview.html) page.

For a quick introduction, read on.

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Introduction" }}

Dartle is a task-based build system written in the [Dart](https://dart.dev/) programming language.

**Dartle can be used to build anything that can be automated!**

How exactly you automate your build with Dartle depends on your needs:

* Write [Dart scripts](dartle-overview.html) to declare the build logic, like a more friendly and powerful Makefile.
* Use [DartleDart](dartle-for-dart.html) to build Dart projects.
* Create [your own build system](dartle-derived-build-tool.html) that is distributed as a binary executable, using
  Dartle as just a library.
* Use the [Dartle Cache](cache.html) to drive an external build system or scripts.

Dartle makes it easy to build most things using an easy, familiar language.

For example, to compile all C files found in the `src` directory recursively, using `gcc`:

```dart
import 'dart:io';

import 'package:dartle/dartle.dart';

final cfiles = dir('src', fileExtensions: {'.c'});
const output = 'mybinary';

final gccTask = Task(gcc,
    description: 'Compiles all C files in src/',
    runCondition: RunOnChanges(inputs: cfiles, outputs: file(output)));

main(List<String> args) => run(args, tasks: {gccTask});

gcc(_) async => execProc(Process.start('gcc', [
  '-o',
  output,
  ...await cfiles.resolveFiles().map((f) => f.path).toList(),
]));
```

Pretty simple and highly readable, unlike most build solutions out there.

In the same directory as the above `darle.dart` script, you can run `dartle gcc`:

```shell
$ dartle gcc
2023-05-09 20:05:06.542846 - dartle[main 51081] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-09 20:05:06.542944 - dartle[main 51081] - INFO - Running task 'gcc'
✔ Build succeeded in 528 ms

$ ./mybinary 
It works!
```

The above `gcc` task will only execute if changes are detected on its inputs or outputs.

The [Dartle Overview](dartle-overview.html) Section takes this basic example further and implements a fully incremental
C build!

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Real-world Example" }}

This website you're reading is built using Dartle! Here's what the script looks like:

```dart
import 'dart:io';

import 'package:dartle/dartle.dart';
import 'package:path/path.dart' as paths;

String userHome() => homeDir() ?? failBuild(reason: 'Cannot find user HOME');

final magFile = File(paths.join(userHome(), '.magnanimous', 'mag'));

final magnanimousDownloadTask = Task(downloadMagnanimous,
    description: 'Download Magnanimous',
    runCondition: RunOnChanges(outputs: file(magFile.path)));

final magnanimousRunTask = Task(runMagnanimous,
    description: 'Builds the Dartle Website using Magnanimous',
    dependsOn: {magnanimousDownloadTask.name},
    runCondition: RunOnChanges(
        inputs: entities(['dartle.dart'], [DirectoryEntry(path: 'source')]),
        outputs: dir('target')));

void main(List<String> args) {
  run(args, tasks: {
    magnanimousRunTask,
    magnanimousDownloadTask,
    createCleanTask(tasks: [magnanimousRunTask]),
  }, defaultTasks: {
    magnanimousRunTask,
  });
}

String _osArch() {
  if (Platform.isWindows) return 'windows-386.exe';
  if (Platform.isLinux) return 'linux-386';
  if (Platform.isMacOS) return 'darwin-amd64';
  failBuild(reason: 'Unsupported OS: ${Platform.operatingSystem}');
}

Future<void> downloadMagnanimous(_) async {
  await magFile.parent.create();
  final magStream = download(
      Uri.parse('https://github.com/renatoathaydes/magnanimous/releases'
          '/download/0.11.1/magnanimous-${_osArch()}'));
  await magFile.writeBinary(magStream, makeExecutable: true);
}

Future<void> runMagnanimous(_) async {
  final code = await execProc(
      Process.start(magFile.path, const ['-style', 'nord'], runInShell: true));
  if (code != 0) failBuild(reason: 'magnanimous exited with code $code');
}
```

Hopefully, it's easy to understand what's going on.

The `downloadMagnanimous` task downloads [Magnanimous](https://renatoathaydes.github.io/magnanimous/),
a static website generator (_also written by me, by the way 😉_), for the appropriate Operating System,
and the `runMagnanimous` task runs it.

For this to work, task `runMagnanimous` depends on `downloadMagnanimous`, so that Dartle will ensure the binary
has been downloaded before trying to run it!

Because `runMagnanimous` is the default task, this build can be executed by running the `dartle` command,
without any arguments, in the project's root directory.

```shell
$ dartle
2023-05-06 19:01:55.244210 - dartle[main 23751] - INFO - Executing 1 task out of a total of 3 tasks: 1 task (default), 1 dependency, 1 up-to-date
2023-05-06 19:01:55.244466 - dartle[main 23751] - INFO - Running task 'runMagnanimous'
✔ Build succeeded in 156 ms
```

You can execute any task you declared by passing its name as an argument to `dartle`.

For example, to run the `runMagnanimous` task:

```shell
$ dartle runMagnanimous
2023-05-06 19:03:44.552424 - dartle[main 24026] - INFO - Executing 0 tasks out of a total of 3 tasks: 1 task (default), 1 dependency, 2 up-to-date
✔ Build succeeded in 110 ms
```

Dartle requires only a few letters to _find_ a task, so running `dartle run`, or `dartle rM` would work as well!

Thanks to Dartle's [Cache System](cache.html), tasks only execute when necessary, so running the build again without changing anything
does basically nothing, which is why the build log above shows that no tasks needed to be executed!

> You can force tasks to run by using the `-f` flag.
> To see all options, check the [Dart CLI](cli.html) page.

## What next?

To find out more, check some of the pages below:

* [Getting Started](getting-started.html)
* [Dartle Overview](dartle-overview.html)
* [Writing Dartle Tasks](tasks.html)
* [Helper Functions](reference/helper-functions.html)

{{end}}

I hope you enjoy using Dartle.

{{end}}
{{ include /processed/fragments/_footer.html }}