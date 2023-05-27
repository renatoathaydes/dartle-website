{{ define title "Dartle for Dart" }}\
{{ define order 6 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

If your goal is to build Dart projects, this section is for you.

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Dartle for Dart Projects" }}

Dartle has built-in support for Dart Projects, making it easy to manage the lifecycle of Dart projects without having
to remember when you need to invoke each Dart tool.

> Even after all separate tools were unified in Dart 2.10, remembering
> which commands to run, and when, is a task better left to Dartle.

To add support for Dartle to an existing Dart project, run `dartle` on the project directory. It will automatically
detect it's a Dart project and setup Dartle accordingly.

> Hint: to create a new DartleDart project from scratch,
> run `dart create <dir> && cd <dir> && dartle`!

Alternatively, you can manually add Dartle by first running this command:

```shell
$ dart pub add -d dartle
```

This adds Dartle as a dev dependency.

After that, create a `dartle.dart` script as shown below (which is the file `dartle` would generate automatically):

```dart
import 'package:dartle/dartle_dart.dart';

final dartleDart = DartleDart();

void main(List<String> args) {
  run(args, tasks: {
    ...dartleDart.tasks,
  }, defaultTasks: {
    dartleDart.build
  });
}
```

That's all you need!

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Working with Dart Projects" }}

[`DartleDart`](https://pub.dev/documentation/dartle/latest/dartle_dart/DartleDart-class.html) can be used to configure the project.

By default, it will contain the following tasks:

```shell
$ dartle -s
======== Showing build information only, no tasks will be executed ========

Tasks declared in this build:

==> Setup Phase:
  * clean
      Deletes the outputs of all other tasks in this build.
==> Build Phase:
  * analyzeCode [up-to-date]
      Analyzes Dart source code
  * build [default] [always-runs]
      Runs all enabled tasks.
  * compileExe
      Compiles Dart executables declared in pubspec. Argument may specify the name(s) of the executable(s) to compile.
  * format [up-to-date]
      Formats all Dart source code.
  * runPubGet [up-to-date]
      Runs "pub get" in order to update dependencies.
  * test [up-to-date]
      Runs Dart tests.
==> TearDown Phase:
  No tasks in this phase.

The following tasks were selected to run, in order:

  format
  runPubGet
      analyzeCode
          test
              build
```

As you can see, the `build` task is the default task, and it will automatically run:

* `format`, invokes `dart format`.
* `runPubGet`, invokes `dart pub get` once a week, can be configured.
* `analyzeCode`, invokes `dart analyze`.
* `test`, invokes `dart test`.

That is, to make sure all the above tasks are up-to-date, you just need to run `dartle` without any arguments!

The other tasks, namely `clean` and `compileExe`, are not executed in the default pipeline.

Tasks are only executed if _needed_, i.e. if changes are detected to their inputs or outputs, or in the case of
`runPubGet`, at most once a week.

If you explicitly invoke a certain task, it will cause any tasks it depends on to also run.

Run with the `-g` flag to see which tasks would run for a certain invocation, without actually running it:

```shell
$ dartle -g compile
======== Showing build information only, no tasks will be executed ========

Tasks Graph:

- analyzeCode
  +--- format
  \--- runPubGet
- build
  +--- analyzeCode ...
  |--- format
  |--- runPubGet
  \--- test
       \--- analyzeCode ...
- clean
- compileExe
  \--- analyzeCode ...

The following tasks were selected to run, in order:

  runPubGet
  format
      analyzeCode
          compileExe
```

> See the [Dartle CLI](cli.html) page for more details about options accepted by the `dartle` command.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Configuring DartleDart" }}

Almost everything in `DartleDart` is configurable via the [`DartleConfig`](https://pub.dev/documentation/dartle/latest/dartle_dart/DartConfig-class.html) object.

Here's an example script configuring all possibilities (check the API reference for an up-to-date API):

```shell
import 'package:dartle/dartle_dart.dart';

final dartleDart = DartleDart(DartConfig(
  formatCode: false,
  runAnalyzer: false,
  compileExe: false,
  runPubGetAtMostEvery: const Duration(days: 30),
  runTests: true,
  rootDir: '.',
  testOutput: DartTestOutput.dart,
  buildRunnerRunCondition: RunOnChanges(
    inputs: file('pubspec.yaml'),
    outputs: file('lib/src/version.g.dart'),
  ),
));

void main(List<String> args) {
  dartleDart.test.dependsOn({dartleDart.runBuildRunner.name});
  run(args, tasks: {
    ...dartleDart.tasks,
  }, defaultTasks: {
    dartleDart.build
  });
}
```

The `test` task needs to explicitly depend on `runBuildRunner` because the output file of the latter overlaps
with the input files of the former... without such dependency, the tasks wouldn't run in the correct order.
Dartle automatically detects this kind of situation... without that dependency being present, an error would've
occurred:

```shell
2023-05-27 09:58:34.634616 - dartle[main 78846] - ERROR - The following tasks have implicit dependencies due to their inputs depending on other tasks' outputs:
  * Task 'test' must dependOn 'runBuildRunner' (clashing outputs: {lib/src/version.g.dart}).

Please add the dependencies explicitly.
```

Running `dartle -s`, you can see that the set of tasks now changed:

```shell
$ dartle -s
======== Showing build information only, no tasks will be executed ========

Tasks declared in this build:

==> Setup Phase:
  * clean
      Deletes the outputs of all other tasks in this build.
==> Build Phase:
  * build [default] [always-runs]
      Runs all enabled tasks.
  * runBuildRunner [out-of-date]
      Runs the Dart build_runner tool.
  * runPubGet [up-to-date]
      Runs "pub get" in order to update dependencies.
  * test [dependency-out-of-date]
      Runs Dart tests.
==> TearDown Phase:
  No tasks in this phase.

The following tasks were selected to run, in order:

  runPubGet
      runBuildRunner
          test
              build
```

The Dart build-runner would now automatically run when needed only, which is very helpful as it takes a long time to complete.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Changing the default task" }}

The default task is given to Dartle when invoking its `run` method. If you prefer to use a different set of default
tasks to run, change the `run` method invocation:

```dart
import 'package:dartle/dartle_dart.dart';

final dartleDart = DartleDart();

void main(List<String> args) {
  run(args, tasks: {
    ...dartleDart.tasks,
  }, defaultTasks: {
    dartleDart.formatCode, dartleDart.analyzeCode
  });
}
```

With this build script, the default tasks to be executed become:

```shell
The following tasks were selected to run, in order:

  format
  runPubGet
      analyzeCode
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Adding custom tasks" }}

Adding custom tasks is straightforward. Just make sure to include the task in the `tasks` Set when calling `run`:

```dart
void main(List<String> args) {
  run(args, tasks: {
    customTask,
    ...dartleDart.tasks,
  }, defaultTasks: {
    dartleDart.build
  });
}
```

The following example shows how to generate a `version.g.dart` file, allowing a
Dart application to have access to its own version at runtime, a common requirement.

> As explained in the [Dartle Overview](dartle-overview.html), it's recommended to always write implementation code
> on Dart files inside the `dartle-src` directory to avoid polluting the build script.

`dartle-src/generate_version.dart`:

```dart
import 'dart:io';

import 'package:dartle/dartle_dart.dart';
import 'package:yaml/yaml.dart';

const pubspec = 'pubspec.yaml';
const versionFile = 'lib/src/version.g.dart';

Future<void> generateVersion(_) async {
  final yaml = loadYaml(await File(pubspec).readAsString());
  await File(versionFile)
      .writeAsString('const version = "${yaml['version']}";');
}

final generateVersionTask = Task(generateVersion,
    description:
        'Generates a Dart file containing the version of this project.',
    runCondition: RunOnChanges(
      inputs: file(pubspec),
      outputs: file(versionFile),
    ));
```

`dartle.dart`:

```dart
import 'package:dartle/dartle_dart.dart';
import 'dartle-src/generate_version.dart';

final dartleDart = DartleDart();

void main(List<String> args) {
  dartleDart.formatCode.dependsOn({generateVersionTask.name});
  run(args, tasks: {
    generateVersionTask,
    ...dartleDart.tasks,
  }, defaultTasks: {
    dartleDart.build
  });
}
```

The custom task, `generateVersion`, is added as a dependency of the existing `formatCode` task, so it will automatically
run during a build where the latter task runs... And it will be skipped if the YAML file hasn't changed!

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}