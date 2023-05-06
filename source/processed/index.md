{{ define title "Dartle" }}
{{ include /processed/fragments/_header.html }}
# Dartle Documentation
<main>
Welcome to the Dartle Documentation.

[![Dartle CI](https://github.com/renatoathaydes/dartle/workflows/Dartle%20CI/badge.svg)](https://github.com/renatoathaydes/dartle/)
[![pub package](https://img.shields.io/pub/v/dartle.svg)](https://pub.dev/packages/dartle)

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Introduction" }}

Dartle is a task-based build system written in the [Dart](https://dart.dev/) programming language.

**Dartle can be used to build anything that can be automated!**

How exactly you automate your build with Dartle depends on your needs:

* Write [Dart scripts](dartle-basics.html) to declare the build logic, like a more friendly and powerful Makefile.
* Use [DartleDart](dartle-for-dart.html) to build Dart projects.
* Create [your own build system](dartle-derived-build-tool.html) that is distributed as a binary executable, using Dartle as just a library.
* Use the advanced [Dartle Cache Library](dartle-cache.html) to drive an external build system or scripts.

## Example

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

For example, to run the `runMagnanimous` task, type:

```shell
$ dartle runMagnanimous
2023-05-06 19:03:44.552424 - dartle[main 24026] - INFO - Executing 0 tasks out of a total of 3 tasks: 1 task (default), 1 dependency, 2 up-to-date
✔ Build succeeded in 110 ms
```

Thanks for Dartle's Cache System, tasks only execute when necessary, so running the build again without changing anything
does absolutely nothing!

> You can force tasks to run by using the `-f` flag. To completely reset the Dartle Cache, use `-z`.
> To see all options, use `-h`.

To see what tasks are available in a build, use the `-s` flag:

```shell
$ dartle -s
======== Showing build information only, no tasks will be executed ========

Tasks declared in this build:

==> Setup Phase:
  * clean
==> Build Phase:
  * downloadMagnanimous [up-to-date]
      Download Magnanimous
  * runMagnanimous [default] [out-of-date]
      Builds the Dartle Website using Magnanimous
==> TearDown Phase:
  No tasks in this phase.

The following tasks were selected to run, in order:

  downloadMagnanimous
      runMagnanimous
```

At the end of the output above, you can see the tasks that would've executed if the `-s` flag hadn't been given, so in a
way, this is like a dry run where you can see not just which tasks exist, but which tasks would run given certain arguments.

The `-g` option shows a task graph, which makes it easy to understand the tasks' dependencies:

```shell
$ dartle -g
======== Showing build information only, no tasks will be executed ========

Tasks Graph:

- clean
- downloadMagnanimous
- runMagnanimous
  \--- downloadMagnanimous

The following tasks were selected to run, in order:

  downloadMagnanimous
      runMagnanimous
```

In very simple builds, this may not look very helpful, but on more complex builds, like the one below from a test Java project
built using [`jb`](https://github.com/renatoathaydes/jb) (a Dartle-derived build system for Java), it can become quite handy:

```shell
Tasks Graph:

- clean
- compile
  +--- installCompileDependencies
  |     \--- writeDependencies
  \--- installProcessorDependencies
       \--- writeDependencies
- createEclipseFiles
  \--- installCompileDependencies ...
- dependencies
- downloadTestRunner
- installRuntimeDependencies
  \--- writeDependencies
- requirements
  \--- compile ...
- runJavaMainClass
  +--- compile ...
  \--- installRuntimeDependencies ...
- sample-task
- test
  +--- compile ...
  |--- downloadTestRunner
  \--- installRuntimeDependencies ...

The following tasks were selected to run, in order:

  writeDependencies
      installCompileDependencies
      installProcessorDependencies
          compile
```

> Dartle currently comes with built-in support for [Dart](https://dart.dev) Projects.
> 
> Adding support for other languages and tools is easy, contributions are welcome! 

* [Getting Started](getting-started.html)
* [Dartle Basics](dartle-basics.html)
* [Using a Dartle Project](using-a-dartle-project.html)
* [Writing Dartle Tasks](dartle-tasks.html)
{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Working with Dart Projects" }}

Dartle has built-in support for Dart Projects, making it easy to manage the lifecycle of Dart projects without having
to remember when you need to invoke each Dart tool (even after all separate tools were unified in Dart 2.10, remembering
which commands to run, and when, is a task better left to Dartle).

* [Dartle for Dart Projects](dartle-for-dart.html)
* [Integrating with the Dart build system](dart-build-system.html)

{{end}}

</main>
{{ include /processed/fragments/_footer.html }}