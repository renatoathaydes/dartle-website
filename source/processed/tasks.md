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
dartle hello :Joe :Mary
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
{{end}}
{{ include /processed/fragments/_footer.html }}