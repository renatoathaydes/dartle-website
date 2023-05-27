{{ define title "Tasks" }}\
{{ define order 4 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

The fundamental unit of work in Dartle is a `Task`. Dartle's main purpose is, fundamentally, to execute Tasks.

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "The simplest possible task" }}

A very basic task can be defined like this:

```dart
hello(_) => print('Hello Dartle');

final helloTask = Task(hello);
```

When the above task runs, the `hello` function is executed. The full Dartle script should look something like this:

```dart
import 'package:dartle/dartle.dart';

hello(_) => print('Hello Dartle');

final helloTask = Task(hello);

void main(List<String> args) {
  run(args, tasks: {helloTask});
}
```

The task takes the name of the function, in this case, `hello`. To run a task, give its name as an argument to the
`dartle` command:

```shell
$ dartle hello
2023-05-26 20:48:38.147175 - dartle[main 75581] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-26 20:48:38.147335 - dartle[main 75581] - INFO - Running task 'hello'
Hello Dartle
✔ Build succeeded in 0 ms
```

> To invoke a task, you can type only its partial name as long as it's not ambiguous.
> See the [Dartle CLI](cli.html) documentation for details.

If a function takes a Dart lambda instead of a top-level function, its name must be provided explicitly, as shown in the
next section.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "A fully configured task" }}

A full task definition can include many details, as shown in this example:

```shell
final exampleTask = Task(_exampleTask,
    name: 'exampleTask',
    description: 'Run an example function.',
    phase: TaskPhase.setup,
    runCondition: RunOnChanges(
      inputs: file('input.txt'),
      outputs: file('output.txt'),
    ),
    argsValidator: const AcceptAnyArgs(),
    dependsOn: const {'hello'});
```

The configuration components of a Task will be explained in the next sections.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Basic Task Action" }}

A Task's action is the function it executes. In its simplest form, a task action can declare an untyped,
ignored argument, as we've seen in earlier examples:

```dart
hello(_) => print('Hello Dartle');

final helloTask = Task(hello);
```

The argument is actually of type `List<String>`, so if a task needs to accept arguments, it may be declared with a typed
argument:

```dart
hello(List<String> args) => print('Hello ${args.join(', ')}!');

final helloTask = Task(hello, argsValidator: const AcceptAnyArgs());
```

Tasks that accept arguments (by default, a task does not accept any arguments, so an `argsValidator` must be provided
as shown above) can be invoked with arguments by prepending task arguments with `:`, as shown below:

```shell
$ dartle hello :Joe :Mary
2023-05-26 21:23:46.582896 - dartle[main 76494] - INFO - Executing 1 task out of a total of 1 task: 1 task selected, -2 dependencies
2023-05-26 21:23:46.583053 - dartle[main 76494] - INFO - Running task 'hello'
Hello Joe, Mary!
✔ Build succeeded in 0 ms
```

Task actions may be asynchronous, in which case the action should return a `Future<void>`:

```dart
Future<void> uname(List<String> args) async => 
    await exec(Process.start('uname', args));
```

To fail when some problem is detected, use the `failBuild` function:

```dart
Future<void> uname(List<String> args) async {
  if (Platform.isWindows) {
    failBuild(reason: 'uname does not exist on Windows');
  }
  await exec(Process.start('uname', args));
}
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Incremental Task Action" }}

Incremental tasks may take a second, optional argument of type `ChangeSet?`, which will be non-null when an incremental
build is possible.

```dart
Future<void> incremental(List<String> args, [ChangeSet? changeSet]) async {
  if (changeSet != null) {
    // incremental build
    for (var change in changeSet.inputChanges) {
      // do something with each file added/modified/deleted
      final message = switch (change.kind) {
        ChangeKind.added => 'handling added file',
        ChangeKind.modified => 'a modified file',
        ChangeKind.deleted => 'deleted file',
      };
      print('$message -> ${change.entity.path}');
    }
  } else {
    // run a full build
  }
}
```

> A full example of what a real incremental task may look like is shown in the [Dartle Overview](dartle-overview.html).

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task Phases" }}

Every Task has a phase associated with it. Dartle comes with 3 built-in phases, which run in order:

* setup
* build (default phase)
* tearDown

More phases can be added by calling the [`TaskPhase.custom`](https://pub.dev/documentation/dartle/latest/dartle_dart/TaskPhase-class.html) factory constructor.

A Task phase only starts running after the preceeding phase has completed. That means that a Task associated with the
`setup` phase will always run before a Task in the `build` phase, even if there's no dependencies between them.

In fact, Tasks from one phase may not have dependencies on Tasks from a different phase. Phases can be thought of silos
for Tasks, so that one phase cannot interfere with another.

This is very useful, for example, for making sure a `clean` task, normally added to the `setup` phase, never runs in
parallel with any `build` tasks, without requiring explicit dependencies between them (which would have caused
the dependency to run when it's out-of-date even when not invoked, which wouldn't make sense in such case).

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Determining when a task needs to run" }}

A Task will only run if its [`RunCondition`](https://pub.dev/documentation/dartle/latest/dartle_dart/RunCondition-mixin.html)
reports that it should.

> There are several types of `RunCondition` available in Dartle, including `RunToDelete` and `RunAtMostEvery`.
> Follow the link above for the full list.
> Users can also implement their own `RunCondition` if none of the available implementations suits their needs.

The most common implementation of `RunCondition` is [`RunOnChanges`](https://pub.dev/documentation/dartle/latest/dartle_dart/RunOnChanges-class.html),
which runs a task when any of its inputs or outputs has changed. It is implemented using the
[Dartle Cache](cache.html), which keeps track of file system changes in the project.

To declare inputs and outputs, [file collections](reference/file-collections.html) are used. They can be as simple as
`file('some-file.txt')`, or more complex as in this example:

```dart
final runCondition = RunOnChanges(
  inputs: entities( // declare both files and directories
      const ['dartle.dart'], // files
      [DirectoryEntry(path: 'source', fileExtensions: const {'.dart', '.c'})]), // dirs
  outputs: dir('target'),
);
```

A task using the above run condition would run if the `dartle.dart` file changed, or if any file under the `source`
directory having the extensions `.dart` or `.c` changed, or if any file under the `target` directory changed.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Validating task arguments" }}

A Task can have an [ArgsValidator](https://pub.dev/documentation/dartle/latest/dartle_dart/ArgsValidator-mixin.html)
associated with it.

By default, tasks use the [DoNotAcceptArgs](https://pub.dev/documentation/dartle/latest/dartle_dart/DoNotAcceptArgs-class.html)
validator, which mean that trying to pass arguments to them causes an error.

Other available implementations include `AcceptAnyArgs` (zero or more args) and `ArgsCount` (a specific range of args).
Custom implementations can be provided.

> Information about a Task's `ArgsValidator`, as well as `RunCondition`, can be obtained by running
> `dartle -s -l debug`.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task dependencies" }}

As we've seen, Tasks can depend on other Tasks.

When task `A` depends on task `B`, running task `A` causes `B` to also run, even when not directly invoked.

Task dependencies may be declared directly on the constructor:

```dart
final myTask = Task(action, dependsOn: const {'otherTask'});
```

> A Task can only depend on other Tasks that run in the same phase as itself.

In some cases, that's not possible because Tasks are declared in different projects.
Before Dartle's `run` method is called, it's possible to add more dependencies to a Task after its creation:

```dart
myTask.dependsOn(const {'newTask'});
```

Notice that it's not possible to remove Task dependencies.

Dartle automatically checks if a Task's inputs and outputs overlap with that of another Task, and enforces that
explicit dependencies between them are declared if an overlap is found.
This avoids a common mistake where dependencies are not correctly declared, causing a Task to overwrite another
Tasks' inputs or outputs.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task Isolation" }}

Tasks are likely to run in their own Dart [Isolate](https://dart.dev/language/concurrency#how-isolates-work). Whether
they will, depends on CLI options, number of tasks running, and the environment (number of CPUs available).

> Dart Isolates allow full parallelization of tasks, as well as isolation. To turn off Isolates,
> use the `--no-parallel-tasks` when running a build.

For this reason, a Task must not make assumptions about its global environment. It would be a mistake,
for example, to use global variables to _communicate_ between different tasks. Global variables are not
propagated to different Isolates.

The only safe way to communicate between tasks is by using the file system and ensuring dependencies
between tasks are set up appropriately, so it's safe to assume a task runs before or after another.

Another limitation caused by Isolates is that not every Dart Object can be _sent_ to another Isolate,
hence if a Task's action contains state (which is possible because a Dart Function can be a stateful Object),
non-sendable state must be initialized lazily, when the action is executed. Trying to create a Task action
as shown below, for example, is likely to cause errors:

```dart
class StatefulAction {
  final Future<int> _exitCode;

  StatefulAction(String command, List<String> args):
        _exitCode = exec(Process.start(command, args, runInShell: true));

  Future<void> call(_)async {
    if (await _exitCode != 0) {
      failBuild(reason: 'process failed');
    }
  }
}

final statefulTask = Task(StatefulAction('ls', ['-a']), name: 'ls');
```

Running this task by itself may actually work fine! But when Dartle decides it should parallelize tasks,
this would fail:

```shell
Unhandled exception:
Invalid argument(s): Illegal argument in isolate message: object is unsendable - Library:'dart:async' Class: _Future@4048458 (see restrictions listed at `SendPort.send()` documentation for more information)
 <- Instance of 'StatefulAction' (from file:///programming/projects/dartle/temp-test/dartle.dart)
 <- Context num_variables: 1
 <- Closure: (dynamic) => Future<void> from Function 'call':. (from dart:core)
 <- Context num_variables: 5
 <- Closure: (_ActorMessage) => Future<void> (from dart:core)
 <- Instance of '_HandlerOfFunction<_ActorMessage, dynamic>' (from package:actors/src/actors_base.dart)
 <- Instance of '_BoostrapData<_ActorMessage, dynamic>' (from package:actors/src/actors_base.dart)
 <- Instance of 'Message' (from package:actors/src/message.dart)
```

To fix this problem, make sure to only initialize state that is _sendable_ in a Task action:

```dart
class StatefulAction {
  final String command;
  final List<String> args;

  const StatefulAction(this.command, this.args);

  Future<void> call(_) async {
    final exitCode = await exec(Process.start(command, args, runInShell: true));
    if (exitCode != 0) {
      failBuild(reason: 'process failed');
    }
  }
}

final statefulTask = Task(StatefulAction('ls', ['-a']), name: 'ls');
```

The above Task is always safe to run in parallel.

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}