{{ define title "Overview" }}\
{{ define order 2 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Dartle Overview" }}

The basic way to use Dartle is by writing a `dartle.dart` script which drives the build.

> When using Dartle as a library, you'll also need to create Tasks and configure them, so this section is useful for that too.

We'll see a few options for how to run `dartle.dart` soon. But first, let's look at the mechanics of a Dartle script.

### Hello Dartle

The basic unit of a Dartle build is a `Task`.

To create a task is very easy. The following `dartle.dart` script shows the most basic, Hello World Dartle build:

```dart
import 'package:dartle/dartle.dart';

main(List<String> args) => run(args, tasks: {Task(hello)});

hello(_) => print('Hello Dartle');
```

Things to notice:

* the script is a _standard_ Dart script, so it starts with a `main` function.
* The `run` function is Dartle's entry point. Dartle expects `main`'s args to be passed into it.
* at least one `Task` must be declared, which in this case wraps a simple Dart function.
* A `Task`'s function is what runs when the task runs, and has the basic
  signature `FutureOr<void> Function(List<String> args)`.

> Task functions may also take a second argument for incremental compilation, as we'll see below.
> For reference about Tasks, visit the [Dartle Tasks](tasks.html) page.

The `hello` function shown above uses a very lightweight syntax, allowed by Dart's dynamic typing features
(no return type or argument type declared) that can be used to keep scripts simple. But if you prefer, you can declare
the types:

```dart
Future<void> hello(List<String> args) => print('Hello Dartle');
```

Dartle cannot distinguish between the two versions, so feel free to use whatever you prefer.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Running a build" }}

There are a few ways to run a Dartle build.

Let's start by using `dart` to run it directly, given that a Dartle script is also a _normal_ Dart script.

We need to tell Dartle which task to run because there's no default task defined yet, so to run the `hello` task
we run `dart dartle.dart hello`:

```shell
$ dart dartle.dart hello
2023-05-06 20:11:56.548602 - dartle[main 25414] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-06 20:11:56.566190 - dartle[main 25414] - INFO - Running task 'hello'
Hello Dartle
✔ Build succeeded in 92 ms
```

This is the easiest way to do it, but it's not very fast because of Dart's startup time not being so great
(Dartle's own observed time was `92ms`, but the actual process takes around 1 full second to run on my Macbook Air,
which is annoying for a command you may want to run very often).

For that reason, Dartle can be installed as an utility that manages the compilation of Dartle scripts so that when you
need to run a build, it starts up much faster (unless the script needs to be recompiled).

To activate `dartle`, run the following command:

```shell
$ dart pub global activate dartle
```

Now, you should be able to run the build as follows:

```shell
$ dartle hello
2023-05-06 20:26:50.972945 - dartle[main 25903] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-06 20:26:50.973047 - dartle[main 25903] - INFO - Running task 'hello'
Hello Dartle
✔ Build succeeded in 0 ms
```

> If you get an error, make sure that `~/.pub-cache/bin` is on your `PATH`.

This time, wall time was around 250ms on my machine. It's not instant, but feels quite fast.

Using this approach, Dartle will automatically re-compile the script when needed, and if you add a default task
to the build, you can just type `dartle` to run it, which is highly convenient.

Finally, to make it run **really** fast, you may want to compile it directly to a native binary as follows:

```shell
$ dart compile exe dartle.dart
Info: Compiling with sound null safety.
Generated: /Users/renato/programming/projects/dartle-website/hello/dartle.exe
```

Now, running `./dartle.exe hello` runs in just `0.050 seconds`, which really feels instant!

Users who find it really important to have this sort of speed gain may find it worthwhile to use this approach
(but notice that for most builds, actual tasks may take a lot longer to run, so the benefit of an instant startup
may not materialize in real gains).

Tools that [use Dartle as a library](dartle-derived-build-tool.html) will also benefit from this approach, normally.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "A use case: compiling C code" }}

In order to go through most Dartle features, the following sections will introduce each feature in the context of
creating a C build tool, starting from a simple task that compiles a single file, and ending with a fully incremental
build which can automatically determine dependencies between files, recompiling them only as necessary.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task inputs/outputs" }}

To really benefit from Dartle, you need to tell it what the inputs/outputs of your tasks are, otherwise it has no way
of knowing when it can skip running a Task.

To declare the inputs/outputs of a Task, an implementation of `RunCondition` can be used.

To understand `RunCondition`, let's look at a simple build example to compile a C program. As you may know, you can
ask the C compiler to
[output an `.o` (object) file](https://beej.us/guide/bgc/html/split/multifile-projects.html#compiling-with-object-files)
for each `.c` source file. The object files can be linked together into a final executable once they've been compiled.

This means that it is not necessary to re-compile everything when a single file, or only a few, have changed.
With a proper build system, it should be possible to achieve that automatically.

To illustrate how Dartle can solve this problem, consider some basic C source code.

`hello.c`

```c
#include <stdio.h>
int main(void) {
   printf("Hello, World!\n");
   return 0;
}
```

And a Dartle script to compile just this file.

`dartle.dart`

```dart
import 'dart:io';

import 'package:dartle/dartle.dart';

main(List<String> args) => run(args, tasks: {
      Task(compileHello,
          runCondition: RunOnChanges(
            inputs: file('hello.c'),
            outputs: file('hello.o'),
          ))
    });

Future<void> compileHello(_) =>
    execProc(Process.start('gcc', const ['-c', 'hello.c']));
```

Notice the `runCondition: RunOnChanges(...)` declaration, which lets Dartle know the exact inputs/outputs of the task.

`file(...)` is a Dartle function that returns a `FileCollection`, which is a powerful tool to describe which files the
build requires and produces (see [File Collections](reference/file-collections.html) for details).

The Task's function is called `compileHello`, and it uses Dartle's `execProc(...)` and Dart's `Process` to execute `gcc`.
`execProc(...)` can do a few tricks, like not printing the process output by default unless there's an error, and checking
the exit code of the Process.

> For more helpful functions to run processes in Dartle, check out [Executing Processes](reference/executing-processes.html).

Running `dartle compile` to execute the above script should result in something like this:

```shell
$ dartle compile
2023-05-06 21:03:08.928448 - dartle[main 26492] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2023-05-06 21:03:14.920246 - dartle[main 26492] - INFO - Re-compiled dartle.dart in 5.982 seconds
2023-05-06 21:03:16.182709 - dartle[main 26502] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-06 21:03:16.182831 - dartle[main 26502] - INFO - Running task 'compileHello'
✔ Build succeeded in 706 ms
```

> Dartle will _guess_ the task you want to run if you type only the first few letters of the task name, and the
> name is not ambiguous. Uppercase letters are treated as if starting new words, which can be handy to disambiguate
> names. For example, `compE` may match a task named `compileExecutable`, but not `compileBinary`.

If everything worked, there should now be a file called `hello.o` next to `hello.c`.

Running the build again should result in no Tasks actually running, as everything is up-to-date.

```shell
$ dartle compile
Everything is up-to-date!
✔ Build succeeded in 3 ms
```

If the object file is deleted, or the C file modified, Dartle will re-run the task.

> It's very important to define the Task's inputs/outputs accurately, otherwise work that should be performed will be wrongly
> skipped, or the opposite, unnecessary work will be performed too often!

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task dependencies" }}

Another very important concept in Dartle is that of dependencies between tasks. If a task depends on another, it will
run AFTER the other task has been executed successfully. That also means that the inputs of a task are also inputs
of any tasks that depend on it.

Continuing with the C example, let's add another task to _link_ the object files (there's only one so far, but bear with me)
into a single executable.

The task function may be defined as follows:

```dart
Future<void> link(_) =>
    execProc(Process.start('gcc', const ['-o', 'hello', 'hello.o']));
```

And the `Task` itself:

```dart
Task(link,
dependsOn: {'compileHello'},
runCondition: RunOnChanges(inputs: file('hello.o'), outputs: file('hello'
)
)
)
```

The `link` task will run whenever any of the tasks it depends on (`compileHello` in this case) runs,
and of course, if any of its own inputs/outputs change.

The `main` function now looks like this:

```dart
main(List<String> args) => run(args, tasks: {
      Task(compileHello,
          runCondition: RunOnChanges(
            inputs: file('hello.c'),
            outputs: file('hello.o'))),
      Task(link,
          dependsOn: {'compileHello'},
          runCondition: RunOnChanges(
              inputs: file('hello.o'),
              outputs: file('hello'))),
    });
```

Running `dartle link` should produce a file called `hello` which can be executed immediately:

```shell
$ dartle link
2023-05-06 21:36:29.098988 - dartle[main 27775] - INFO - Executing 1 task out of a total of 2 tasks: 1 task selected, 1 dependency, 1 up-to-date
2023-05-06 21:36:29.099146 - dartle[main 27775] - INFO - Running task 'link'
✔ Build succeeded in 102 ms

$ ./hello
Hello, World!
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Computing Task inputs/outputs" }}

We could keep declaring source files and their corresponding object files manually, but as a project grows,
that can become difficult to manage.

We can do something better... we may still want to list the C source files explicitly in the build file, so that it's
clear to
everyone what is expected to be compiled (though as shown in the [Introduction](index.html),
it's very easy to obtain every source file in a directory).
But the output files should probably be computed from the sources to avoid mistakes.

This can be done quite elegantly in Dart:

```dart
import 'package:path/path.dart' as paths;

const sourceFiles = [
  'hello.c',
  'greeting.c',
  'greeting.h',
];

final compileOutputs = [
  for (final source in sourceFiles)
    if (paths.extension(source) == '.c') paths.setExtension(source, '.o')
];
```

It's easy to update the rest of `dartle.dart` to use the above declarations now:

```dart
main(List<String> args) => run(args, tasks: {
      Task(compile,
          runCondition: RunOnChanges(
            inputs: files(sourceFiles),
            outputs: files(compileOutputs),
          )),
      Task(link,
          dependsOn: {'compile'},
          runCondition: RunOnChanges(
            inputs: files(compileOutputs), 
            outputs: file('hello'))),
    });

Future<void> compile(_) =>
    execProc(Process.start('gcc', ['-c', ...sourceFiles]));

Future<void> link(_) =>
    execProc(Process.start('gcc', ['-o', 'hello', ...compileOutputs]));
```

For completeness, here are the extra source files:

`hello.c`

```c
#include <stdio.h>
#include "greeting.h"
int main(void) {
   printf("%s, World!\n", greeting());
   return 0;
}
```

`greeting.h`

```c
#ifndef GREETING_H
#define GREETING_H
char* greeting(void);
#endif
```

`greeting.c`

```c
char* greeting(void) {
   return "Olá";
}
```

Finally, we can run the build again:

```shell
$ dartle link
2023-05-06 23:24:12.977305 - dartle[main 29683] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2023-05-06 23:24:19.007166 - dartle[main 29683] - INFO - Re-compiled dartle.dart in 6.019 seconds
2023-05-06 23:24:22.702044 - dartle[main 29692] - INFO - Executing 2 tasks out of a total of 2 tasks: 1 task selected, 1 dependency
2023-05-06 23:24:22.702189 - dartle[main 29692] - INFO - Running task 'compile'
2023-05-06 23:24:22.868822 - dartle[main 29692] - INFO - Running task 'link'
✔ Build succeeded in 275 ms

$ ./hello
Olá, World!
```

It all works fine, but to make things better, the `compile` task should be **incremental**, i.e. only the modified files
should be re-compiled. That's what the next section will address.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Making a task incremental" }}

An incremental build is one where after an initial build is completed, further builds re-use work done previously so
that only work that is strictly necessary, given the changes, is performed.

Naively, one may think that, continuing with C compilation as an example, we would need to re-compile a C file
only if it, or its corresponding object file, had been modified since the last compilation. But in many languages,
including C, a file may _include_ other files.

If a file A is included by another file B, and A changes, both A and B must be re-compiled. That's because B may be
using
things from A that were removed or altered in an incompatible way. In other words: when a file is modified, it must be
re-compiled along with all other files that depend on it.

**Hence, to make a build incremental, one needs to know not just what has changed, but also which files depend on which
files.**

But how can one know which files depends on which other files? The answer depends on the programming language being
used.

With the `gcc` (and `clang`) C compiler, it's possible to find that out
by [using the -MMD flag](https://www.evanjones.ca/makefile-dependencies.html)
to generate a `.d` file listing the dependencies of each compiled file.

For example, using the same files from the previous section:

```shell
$ gcc -MMD -c hello.c          

$ cat hello.d
hello.o: hello.c greeting.h
```

The compiler invocation above compiled an object file, `hello.o`, from the `hello.c` source, as well as a `hello.d` file
which shows all the
dependencies of `hello.o` (using `Makefile` syntax, as it was designed to work with Make). In this example, we can see
that `hello.o` _depends on_ `hello.c` and `greeting.h`.

> I assume that `.o` files always depend first on the `.c` file it was compiled from, and that the next dependencies
> listed are the actual `.c` file's dependencies. In this example, that would mean `hello.c` _depends on_ `greeting.h`,
> which is correct.

A Dartle Task that needs to know which files have changed since the last compilation can take a second argument,
as shown below:

```dart
Future<void> compile(List<String> args, [ChangeSet? changeSet]) { ... }
```

The first time the task runs, or after a clean build, the `changeSet` parameter will be `null`, otherwise it will
contain
`inputChanges` and `outputChanges` which can be inspected by the task to know what work it needs to perform.

This is all we need to know to write a fully incremental C (or any other language) build system!

Here's what the `compile` Task function would look like, accounting for incremental compilation:

```dart
Future<int> compile(List<String> args, [ChangeSet? changeSet]) async {
  Iterable<String> sources = sourceFiles;
  if (changeSet != null) {
    if (changeSet.outputChanges.isEmpty) {
      final incrementalSources =
      (await computeFilesToCompile(changeSet).toSet())
          .where((e) => e.endsWith('.c'));
      if (incrementalSources.isNotEmpty) {
        sources = incrementalSources;
        logger.fine(() => 'Compiling incrementally: $sources');
      }
    } else {
      logger.info(
              () => 'Cannot perform incremental compilation as outputs changed');
    }
  }
  return await execProc(Process.start(
      'gcc', ['-MMD', '-c', ...sources.where((p) => p.endsWith('.c'))]));
}
```

> This example performs a full compilation if there's any output changes because handling that correctly can be
> difficult.
> Also, the main purpose of an incremental task is to handle the much more common case where only inputs are changed.

The `computeFilesToCompile` function is where the bulk of the logic is implemented:

```dart
Stream<String> computeFilesToCompile(ChangeSet changeSet) async* {
  // collect the deleted files to avoid trying to re-compile any
  final deletedFiles = changeSet.inputChanges
      .where((f) => f.kind == ChangeKind.deleted)
      .map((f) => f.entity.path)
      .toSet();

  final dependencyTree = await _readDependencyTree(
      compileOutputs.where((p) => p.endsWith('.d')), deletedFiles);

  for (final change in changeSet.inputChanges) {
    switch (change.kind) {
      case ChangeKind.modified || ChangeKind.added:
        yield change.entity.path;
        for (final dep in _dependents(change.entity.path, dependencyTree)) {
          yield dep;
        }
        break;
      case ChangeKind.deleted:
        // must delete the output file from all deleted sources
        await ignoreExceptions(() async =>
            await File(paths.setExtension(change.entity.path, '.o')).delete());
    }
  }
}
```

> A few helper functions are omitted from the code above for brevity. They're not particularly complex,
> but aren't very relevant to this section.
> For the curious, you can find my
> full [implementation here](https://github.com/renatoathaydes/dartle_c/blob/main/lib/src/compile.dart).

It's become a fairly sophisticated task function now!

And for this very reason, it would be nice to keep "implementation details" like this out of the build file,
as will be shown in the next section.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Extracting complex logic into dartle-src/" }}

Complex tasks should not be written directly in the build script, as they can make it hard to understand what the build
is supposed to do by including too many details.

The simplest way to extract functionality out of the build script is to create separate Dart files in the `dartle-src/`
directory.

> The reason for doing that, rather than, say, just writing Dart files on the same directory as the `dartle.dart` file,
> is that Dartle _knows_ to consider any files inside `dartle-src/` as _input files_ for the script re-compilation task.

As a very basic example, let's move the `link` task function implementation from the previous sections into a new file:

`dartle-src/link.dart`

```dart
import 'package:dartle/dartle.dart';
import 'dart:io';
import 'package:path/path.dart' as paths;

Future<void> link(_) => execProc(Process.start('gcc',
    ['-o', 'hello', ...compileOutputs.where((f) => paths.extension(f) == '.o')]));
```

For this to compile, it needs access to `compileOutputs`, which was in the `dartle.dart` script.

This is a common problem when splitting up build files. The easy solution is to create a file for _configuration_ that
can be imported by any other files.

`dartle-src/config.dart`

```dart
import 'package:path/path.dart' as paths;

const sourceFiles = {
  'hello.c',
  'greeting.c',
  'greeting.h',
};

final compileOutputs = [
  for (final source in sourceFiles)
    if (paths.extension(source) == '.c') ...[
      paths.setExtension(source, '.o'),
      paths.setExtension(source, '.d'),
    ]
];
```

Now, `link.dart` can import `config.dart`:

```dart
import 'package:dartle/dartle.dart';
import 'dart:io';
import 'package:path/path.dart' as paths;

import 'config.dart';

Future<void> link(_) => execProc(Process.start('gcc',
    ['-o', 'hello', ...compileOutputs.where((f) => paths.extension(f) == '.o')]));
```

The `compile` task function (along with its helper functions) can also be moved into its own file, `dartle-src/compile.dart`...

After doing that, this is what the example build script would look like:

```dart
import 'package:dartle/dartle.dart';

import 'dartle-src/compile.dart';
import 'dartle-src/config.dart';
import 'dartle-src/link.dart';

main(List<String> args) => run(args, tasks: {
      Task(compile,
          runCondition: RunOnChanges(
            inputs: files(sourceFiles),
            outputs: files(compileOutputs),
          )),
      Task(link,
          dependsOn: {'compile'},
          runCondition: RunOnChanges(
              inputs: files(compileOutputs), 
              outputs: file('hello'))),
    });
```

Very simple, but powerful!

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Clean builds" }}

Even though Dartle was designed to avoid the need for running clean builds, it's still possible there are mistakes
that can prevent an incremental build from working. You may also want to test that things are still working when run
from a clean environment.

For this reason, it's advisable to add a `clean` task to the build, which can be done with `createCleanTask`, which
takes a set of `Task`s whose output it should _clean_. In other words, the `clean` task, when run, deletes the outputs
of the `Task`s it was provided.

To do that, use the `createCleanTask` function:

```dart
createCleanTask(tasks: [compileTask, linkTask])
```

And run it with:

```shell
$ dartle clean
2023-05-07 20:14:27.609901 - dartle[main 36395] - INFO - Executing 1 task out of a total of 3 tasks: 1 task selected
2023-05-07 20:14:27.610095 - dartle[main 36395] - INFO - Running task 'clean'
✔ Build succeeded in 3 ms
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Default Tasks" }}

A very convenient thing to add to a Dartle build is a default task. That makes it just a tiny bit easier to run the most
common build tasks, as instead of having to specify the task(s) that need to be run, you can type `dartle` and be
done with it!

Here's what the final build script for the Example C project will look like with this addition:

```dart
import 'package:dartle/dartle.dart';

import 'dartle-src/compile.dart';
import 'dartle-src/config.dart';
import 'dartle-src/link.dart';

final compileTask = Task(compile,
    runCondition: RunOnChanges(
      inputs: files(sourceFiles),
      outputs: files(compileOutputs),
    ));

final linkTask = Task(link,
    dependsOn: {'compile'}, runCondition: RunOnChanges(inputs: files(compileOutputs),
        outputs: file('hello')));

main(List<String> args) => run(args, tasks: {
      compileTask,
      linkTask,
      createCleanTask(tasks: [compileTask, linkTask]),
    }, defaultTasks: {
      linkTask
    });
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Profiling a build" }}

Finally, make sure you understand your build performance by running the build with the `-l profile` option:

```shell
$ dartle -l profile
2023-05-07 20:20:04.324333 - dartle[main 36682] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2023-05-07 20:20:09.615994 - dartle[main 36682] - PROFILE - Task '_compileDartleFile' completed successfully in 5.281 seconds
2023-05-07 20:20:09.835265 - dartle[main 36682] - PROFILE - Post-run action of task '_compileDartleFile' completed successfully in 212 ms
2023-05-07 20:20:09.835404 - dartle[main 36682] - INFO - Re-compiled dartle.dart in 5.502 seconds
2023-05-07 20:20:10.047037 - dartle[main 36691] - PROFILE - Checked task 'compile' runCondition in 0 ms
2023-05-07 20:20:10.047161 - dartle[main 36691] - INFO - Executing 2 tasks out of a total of 3 tasks: 1 task (default), 1 dependency
2023-05-07 20:20:10.048725 - dartle[main 36691] - PROFILE - Collected 3 input and 0 output change(s) for 'compile' in 1 ms
2023-05-07 20:20:10.048763 - dartle[main 36691] - INFO - Running task 'compile'
2023-05-07 20:20:10.048878 - dartle-c[main 36691] - WARN - Missing .d file: hello.d
2023-05-07 20:20:10.593449 - dartle[main 36691] - PROFILE - Task 'compile' completed successfully in 544 ms
2023-05-07 20:20:10.593607 - dartle[main 36691] - INFO - Running task 'link'
2023-05-07 20:20:10.680562 - dartle[main 36691] - PROFILE - Task 'link' completed successfully in 86 ms
2023-05-07 20:20:10.685960 - dartle[main 36691] - PROFILE - Post-run action of task 'compile' completed successfully in 5 ms
2023-05-07 20:20:10.688199 - dartle[main 36691] - PROFILE - Post-run action of task 'link' completed successfully in 2 ms
2023-05-07 20:20:10.688283 - dartle[main 36691] - PROFILE - Garbage-collected cache in 0 ms
✔ Build succeeded in 641 ms
```

{{end}}

<hr>

With this, we come to the end of the Dartle Overview armed with a fully incremental C build system!

While you could use this to write your own build system, if you actually want a C build system, I turned the examples
in this page into the [Dartle_C](https://github.com/renatoathaydes/dartle_c) Dartle extension.

If you like Dartle and want to learn more, try some of these pages next:

* [Dartle CLI](cli.html)
* [Dartle as a Dart library](dartle-derived-build-tool.html)
* [Tasks](tasks.html)

{{end}}
{{ include /processed/fragments/_footer.html }}