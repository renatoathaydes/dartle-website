{{ define title "Tasks" }}\
{{ define order 4 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

The fundamental unit of work in Dartle is a `Task`. Dartle's main purpose is, essentially, to execute Tasks
in the right order, and only if necessary given the task's declared `RunCondition`.

This page explain in detail how to create and configure tasks.

## Table of Contents

- [The simplest possible task](#simplest-task)
- [A fully configured task](#full-task)
- [Basic task action](#basic-task)
- [Incremental task action](#incremental-task)
- [Task phases](#task-phases)
- [Determining when a task needs to run](#determining-task-needs-to-run)
- [Validating task arguments](#validating-task-args)
- [Task dependencies](#task-dependencies)
- [Task requirements](#task-requirements)
- [Task isolation](#task-isolation)

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "The simplest possible task" }}
{{ define sectionId "simplest-task" }}

A very basic task can be defined like this:

```dart
final helloTask = Task((_) => print('Hello World'), name: 'hello');
```

When the above task runs, the `hello` function is executed.

The full `dartle.dart` script file should look something like this:

```dart
import 'package:dartle/dartle.dart';

final helloTask = Task((_) => print('Hello World'), name: 'hello');

void main(List<String> args) {
  run(args, tasks: {helloTask});
}
```

To run a task, just pass its name to `dartle`:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">dartle-1.0</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle hello
2026-05-19 20:17:16.819861 - dartle[main 2742] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-19 20:17:16.819902 - dartle[main 2742] - INFO - Running task &#39;<span style="font-weight:bold">hello</span>&#39;
Hello World
<span style="color:#0a0">✔ Build succeeded in 281μs</span>
</pre>

> To invoke a task, you can type only its partial name as long as it's not ambiguous.
> See the [Dartle CLI](cli.html) documentation for details.

For convenience, a task _action_ that is a non-anonymous function does not need to declare a `name`, since that can be
inferred from the function name. Hence, the following task is equivalent to the `helloTask` above:

```dart
void hello(_) => print('Hello World');

final helloTask = Task(hello);
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "A fully configured task" }}
{{ define sectionId "full-task" }}

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
    dependsOn: const {'hello'},
    requires: const {'other'});
```

The configuration components of a Task will be explained in the next sections.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Basic Task Action" }}
{{ define sectionId "basic-task" }}

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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">dartle-1.0</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle hello :Joe :Mary
2026-05-19 20:26:17.005156 - dartle[main 3489] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-19 20:26:17.005200 - dartle[main 3489] - INFO - Running task &#39;<span style="font-weight:bold">hello</span>&#39;
Hello Joe, Mary!
<span style="color:#0a0">✔ Build succeeded in 292μs</span>
</pre>

Task actions may be asynchronous, in which case the action should return a `Future<void>`:

```dart
Future<void> uname(List<String> args) async => 
    await exec(Process.start('uname', args));
```

Running this task on my laptop, I get this:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">dartle-1.0</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle uname
2026-05-19 20:30:12.590474 - dartle[main 4248] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 2 tasks: 1 task selected
2026-05-19 20:30:12.590526 - dartle[main 4248] - INFO - Running task &#39;<span style="font-weight:bold">uname</span>&#39;
Darwin
<span style="color:#0a0">✔ Build succeeded in 3ms, 723μs</span>
</pre>

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
{{ define sectionId "incremental-task" }}

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
{{ define sectionId "task-phases" }}

Every Task has a phase associated with it. Dartle comes with 3 built-in phases, which run in order:

```
+-------+     +-------+     +-----------+
| setup | --> | build | --> | tearDown  |
+-------+     +-------+     +-----------+
                  ^
              (default)
```

More phases can be added by calling the [`TaskPhase.custom`](https://pub.dev/documentation/dartle/latest/dartle/TaskPhase-class.html) factory constructor.

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
{{ define sectionId "determining-task-needs-to-run" }}

A Task will only run if its [`RunCondition`](https://pub.dev/documentation/dartle/latest/dartle/RunCondition-mixin.html)
reports that it should.

> There are several types of `RunCondition` available in Dartle, including `RunToDelete` and `RunAtMostEvery`.
> Follow the link above for the full list.
> Users can also implement their own `RunCondition` if none of the available implementations suits their needs.

The most common implementation of `RunCondition` is [`RunOnChanges`](https://pub.dev/documentation/dartle/latest/dartle/RunOnChanges-class.html),
which runs a task when any of its inputs or outputs has changed. It is implemented using the
[Dartle Cache](cache.html), which keeps track of file system changes in the project.

To declare inputs and outputs, [file collections](reference/file-collections.html) are used. They can be as simple as
`file('some-file.txt')`, or more complex as in this example:

```dart
final runCondition = RunOnChanges(
  inputs: entities( // declare both files and directories
      const ['dartle.dart'], // files
      [dirEntry('source', extensions: {'.dart', '.c'})]), // dirs
  outputs: dir('target'),
);
```

A task using the above run condition would run if the `dartle.dart` file changed, or if any file under the `source`
directory having the extensions `.dart` or `.c` changed, or if any file under the `target` directory changed.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Validating task arguments" }}
{{ define sectionId "validating-task-args" }}

A Task can have an [ArgsValidator](https://pub.dev/documentation/dartle/latest/dartle/ArgsValidator-mixin.html)
associated with it.

By default, tasks use the [DoNotAcceptArgs](https://pub.dev/documentation/dartle/latest/dartle/DoNotAcceptArgs-class.html)
validator, which mean that trying to pass arguments to them causes an error.

Other available implementations include `AcceptAnyArgs` (zero or more args) and `ArgsCount` (a specific range of args).
Custom implementations can be provided.

> Information about a Task's `ArgsValidator`, as well as `RunCondition`, can be obtained by running
> `dartle -s -l debug`.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task dependencies" }}
{{ define sectionId "task-dependencies" }}

As we've seen, Tasks can depend on other Tasks.

When task `A` depends on task `B`, running task `A` causes `B` to also run, even when not directly invoked
(though tasks may be skipped if they are up-to-date).

Task dependencies may be declared directly on the constructor:

```dart
final myTask = Task(action, dependsOn: const {'otherTask'});
```

> A Task can only depend on other Tasks that run in the same phase, or an earlier phase, as itself.

In some cases, that's not possible because Tasks are declared in different projects.
Before Dartle's `run` method is called, it's possible to add more dependencies to a Task after its creation:

```dart
myTask.dependsOn(const {'anotherTask'});
```

However, it's not possible to remove Task dependencies.

Dartle automatically checks if a Task's inputs and outputs overlap with that of another Task, and enforces that
explicit dependencies between them are declared if an overlap is found.
This avoids a common mistake where dependencies are not correctly declared, causing a Task to overwrite another
Tasks' inputs or outputs.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task requirements" }}
{{ define sectionId "task-requirements" }}

Besides dependencies, tasks may also have _requirements_.

Requirements are similar to dependencies, with some differences:

* if task `A` requires task `B`, then, as with dependencies, running task `A` causes task `B` to run.
* a task's requirements run BEFORE the task itself.
* however, unlike with dependencies, a required task's status is not checked if it's not directly invoked.

This means that if task `A` is up-to-date and a user invokes only task `A`, no tasks will be executed even if task `B`
is a requirement of `A` and is NOT up-to-date.

This is in constrast to a task dependency, since if task `A` had a dependency on `B`, and `B` was not up-to-date, then the status
of task `A` would become `dependency-out-of-date` and both tasks would be executed.

Declaring requirements in a `Task`'s constructor:

```dart
final myTask = Task(action, requires: const {'otherTask'});
```

Adding a requirement after creating a task:

```dart
myTask.requires(const {'anotherTask'});
```

In most cases, task dependencies should be used instead of requirements.

Task requirements are, however, needed in a few cases. For example, sometimes a task needs to check the environemnt for things like
environment variables, or even determine the path of a binary that needs to be called. A task that does that must inherently run
every time, since the environment can change and the only way to know if it did is by running the task. This kind of task is a good
candidate for a task requirement.

The task that depends on the environment is what the user actually wants to call, and the task
shouldn't execute every time just because the environment may have changed. So, the task only executes if its own inputs/outputs
change, but if it does, its requirement is also going to be invoked, allowing it to provide some information to the main task
_off-band_.

> See also [Task isolation](#task-isolation) for more information about how tasks can share data without using IO.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task Isolation" }}
{{ define sectionId "task-isolation" }}

Tasks are likely to run in their own Dart [Isolate](https://dart.dev/language/concurrency#how-isolates-work). Whether
they will, depends on CLI options, number of tasks running, and the environment (number of CPUs available).

> Dart Isolates allow full parallelization of tasks, as well as isolation. To turn off Isolates,
> use the `--no-parallel-tasks` when running a build.

For this reason, a Task must not make assumptions about its global environment. It would be a mistake,
for example, to use global variables to _communicate_ between different tasks. Global variables are not
propagated to different Isolates.

The only safe ways to communicate between tasks are:

* by using the file system and ensuring dependencies between tasks are set up appropriately, so it's safe to assume a task runs before or after another.
* using state [actors](https://pub.dev/documentation/actors/latest/actors/). Actors can be passed to other actors via `toSendable()` and hence can be shared.

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
