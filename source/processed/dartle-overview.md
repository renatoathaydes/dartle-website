{{ define title "Overview" }}\
{{ define order 2 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

## Dartle Overview

This document gives an overview of Dartle by going from a minimal Hello World project using a Dartle script,
to a fully incremental C build system.

## Table of Contents

- [Hello Dartle](#hello-dartle)
  - [Using the dartle tool](#using-the-dartle-tool)
  - [Compiling to binary](#compiling-to-binary)
  - [Debugging with `dart run`](#debugging-with-dart)
- [A use case: compiling C code](#compiling-c-code)
  - [Task inputs/outputs](#task-inputs-outputs)
  - [Task dependencies](#task-dependencies)
  - [Computing task inputs/outputs](#computing-task-inputs-outputs)
  - [Making a task incremental](#making-a-task-incremental)
  - [Extracting complex logic into dartle-src/](#extracting-complex-logic)
  - [Clean builds](#clean-builds)
  - [Default tasks](#default-tasks)
  - [Profiling a build](#profiling-a-build)
  - [Conclusion](#conclusion)

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Hello Dartle" }}
{{ define sectionId "hello-dartle" }}

A Dartle build is normally driven by a `dartle.dart` script.

A _Hello World_ Dartle script looks like this:

```dart
import 'package:dartle/dartle.dart';

main(List<String> args) => run(args, tasks: {Task(hello)});

hello(_) => print('Hello Dartle');
```

<div id="using-the-dartle-tool"></div>
### Using the dartle tool

To run that, you can use the `dartle` command (see [Getting Started](getting-started.html) for installation instructions):

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle
2026-05-17 16:02:50.499739 - dartle[main 64339] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2026-05-17 16:02:52.036706 - dartle[main 64339] - INFO - Re-compiled dartle.dart in 1.531 seconds
<span style="color:#a50">2026-05-17 16:02:52.472183 - dartle[main 64347] - WARN - No tasks were requested and no default tasks exist.</span>
<span style="color:#0a0">✔ Build succeeded in 383μs</span>
</pre>

As you can see, `dartle` automatically compiles the script if before running it (and the next time it runs, it re-uses the compiled version if it's not changed, making the script much faster to run).

Without defining a [default task](#default-tasks), Dartle does not know what to run, so in this case, we need to call the task defined by the build, `hello`:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle hello
2026-05-17 16:03:09.221521 - dartle[main 64366] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-17 16:03:09.221565 - dartle[main 64366] - INFO - Running task &#39;<span style="font-weight:bold">hello</span>&#39;
Hello Dartle
<span style="color:#0a0">✔ Build succeeded in 282μs</span>
</pre>

<div id="compiling-to-binary"></div>
### Compiling to binary

It's also possible to compile the `dartle.dart` file to a small binary and then execute that instead:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dart compile exe dartle.dart
Generated: &#47;Users&#47;renatoathaydes&#47;programming&#47;projects&#47;dartle-website&#47;examples&#47;hello-world&#47;dartle.exe
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> .&#47;dartle.exe hello
2026-05-17 16:07:59.773680 - dartle[main 64770] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-17 16:07:59.773755 - dartle[main 64770] - INFO - Running task &#39;<span style="font-weight:bold">hello</span>&#39;
Hello Dartle
<span style="color:#0a0">✔ Build succeeded in 508μs</span>
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> time .&#47;dartle.exe hello
2026-05-17 16:08:03.537027 - dartle[main 64787] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-17 16:08:03.537114 - dartle[main 64787] - INFO - Running task &#39;<span style="font-weight:bold">hello</span>&#39;
Hello Dartle
<span style="color:#0a0">✔ Build succeeded in 458μs</span>
.&#47;dartle.exe hello  0.01s user 0.01s system 66% cpu 0.037 total
</pre>

<div id="debugging-with-dart"></div>
### Debugging with `dart run`

Finally, it's also possible to run the `dartle.dart` script as any other Dart application:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">hello-world</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> time dart run dartle.dart hello
2026-05-17 16:25:35.703471 - dartle[main 66001] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-17 16:25:35.709899 - dartle[main 66001] - INFO - Running task &#39;<span style="font-weight:bold">hello</span>&#39;
Hello Dartle
<span style="color:#0a0">✔ Build succeeded in 35ms, 483μs</span>
dart run dartle.dart hello  0.80s user 0.10s system 129% cpu 0.691 total
</pre>

The problem with that is that it's noticeably slower than using `dartle` or compiling to a binary. On the other hand,
it allows debugging the script more easily using the excellent [Dart Dev Tools](https://dart.dev/tools/dart-devtools).

Things to notice:

* the script is a _standard_ Dart script, so it starts with a `main` function.
* The `run` function is Dartle's entry point. Dartle expects `main`'s args to be passed into it.
* at least one `Task` must be declared, which in this case wraps a simple Dart function.
* A `Task`'s function is what runs when the task runs, and has the basic
  signature `FutureOr<void> Function(List<String> args)`.

> Task functions may also take a second argument for incremental compilation, as we'll see below.
> For reference about Tasks, visit the [Dartle Tasks](tasks.html) page.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionId "compiling-c-code" }}
{{ define sectionTitle "A use case: compiling C code" }}

In order to go through most Dartle features, the following sections will introduce each feature in the context of
creating a C build tool, starting from a simple task that compiles a single file, and ending with a fully incremental
build which can automatically determine dependencies between files, recompiling them only as necessary.

<div id="task-inputs-outputs"></div>
### Task inputs/outputs

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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle compile
2026-05-17 17:07:10.820116 - dartle[main 68088] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2026-05-17 17:07:17.939838 - dartle[main 68088] - INFO - Re-compiled dartle.dart in 7s, 115ms
2026-05-17 17:07:18.300476 - dartle[main 68095] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-17 17:07:18.300556 - dartle[main 68095] - INFO - Running task &#39;<span style="font-weight:bold">compileHello</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 77ms, 680μs</span>
</pre>

> Dartle will _guess_ the task you want to run if you type only the first few letters of the task name, and the
> name is not ambiguous. Uppercase letters are treated as if starting new words, which can be handy to disambiguate
> names. For example, `compE` may match a task named `compileExecutable`, but not `compileBinary`.

If everything worked, there should now be a file called `hello.o` next to `hello.c`.

Running the build again should result in no Tasks actually running, as everything is up-to-date.

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle compile
<span style="color:#0a0">Everything is up-to-date!</span>
<span style="color:#0a0">✔ Build succeeded in 897μs</span>
</pre>

If the object file is deleted, or the C file modified, Dartle will re-run the task.

> It's very important to define the Task's inputs/outputs accurately, otherwise work that should be performed will be wrongly
> skipped, or the opposite, unnecessary work will be performed too often!

<div id="task-dependencies"></div>
### Task dependencies

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
    runCondition: RunOnChanges(inputs: file('hello.o'), outputs: file('hello')))
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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">)</span><span style="color:#a50;font-weight:bold">✗</span> dartle link
2026-05-18 20:22:38.843244 - dartle[main 28465] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2026-05-18 20:22:40.525836 - dartle[main 28465] - INFO - Re-compiled dartle.dart in 1.677 seconds
2026-05-18 20:22:40.937040 - dartle[main 28472] - INFO - Executing<span style="font-weight:bold">2 tasks</span> out of a total of 2 tasks: 1 task selected, 1 dependency
2026-05-18 20:22:40.937121 - dartle[main 28472] - INFO - Running task &#39;<span style="font-weight:bold">compileHello</span>&#39;
2026-05-18 20:22:41.214675 - dartle[main 28472] - INFO - Running task &#39;<span style="font-weight:bold">link</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 445ms, 133μs</span>
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">)</span><span style="color:#a50;font-weight:bold">✗</span> .&#47;hello
Hello, World!
</pre>


<div id="computing-task-inputs-outputs"></div>
### Computing Task inputs/outputs

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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">)</span><span style="color:#a50;font-weight:bold">✗</span> dartle link
2026-05-18 20:31:13.846446 - dartle[main 29376] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2026-05-18 20:31:18.664887 - dartle[main 29376] - INFO - Re-compiled dartle.dart in 4.813 seconds
2026-05-18 20:31:19.072456 - dartle[main 29383] - INFO - Executing<span style="font-weight:bold">2 tasks</span> out of a total of 2 tasks: 1 task selected, 1 dependency
2026-05-18 20:31:19.072529 - dartle[main 29383] - INFO - Running task &#39;<span style="font-weight:bold">compile</span>&#39;
2026-05-18 20:31:19.151584 - dartle[main 29383] - INFO - Running task &#39;<span style="font-weight:bold">link</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 128ms, 849μs</span>
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">)</span><span style="color:#a50;font-weight:bold">✗</span> .&#47;hello
Olá, World!
</pre>

It all works fine, but to make things better, the `compile` task should be **incremental**, i.e. only the modified files
should be re-compiled. That's what the next section will address.

<div id="making-a-task-incremental"></div>
### Making a task incremental

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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> gcc -MMD -c hello.c
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> cat hello.d
hello.o: hello.c greeting.h
</pre>

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

<div id="extracting-complex-logic"></div>
### Extracting complex logic into dartle-src/

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

<div id="clean-builds"></div>
### Clean builds

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

> For more useful functions, see also [Helper Functions](reference/helper-functions.html). 

And run it with:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle clean
2026-05-18 21:26:34.375665 - dartle[main 32494] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 4 tasks: 1 task selected
2026-05-18 21:26:34.375754 - dartle[main 32494] - INFO - Running task &#39;<span style="font-weight:bold">clean</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 2ms, 675μs!</span>
</pre>

<div id="default-tasks"></div>
### Default tasks

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

<div id="profiling-a-build"></div>
### Profiling a build

Finally, make sure you understand your build performance by running the build with the `-l profile` option:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle archive -l profile
<span style="color:#a0a">2026-05-18 21:30:56.249169 - dartle-c[main 32938] - PROFILE - Parsed dcc configuration in 0ms</span>
<span style="color:#a0a">2026-05-18 21:30:56.251366 - dartle[main 32938] - PROFILE - Checked task &#39;compileC&#39; runCondition in 1ms, 564μs</span>
2026-05-18 21:30:56.251415 - dartle[main 32938] - INFO - Executing <span style="font-weight:bold">2 tasks</span> out of a total of 4 tasks: 1 task selected, 1 dependency
<span style="color:#a0a">2026-05-18 21:30:56.252650 - dartle[main 32938] - PROFILE - Collected 0 input and 5 output change(s) for &#39;compileC&#39; in 1ms, 203μs</span>
2026-05-18 21:30:56.252670 - dartle[main 32938] - INFO - Running task &#39;<span style="font-weight:bold">compileC</span>&#39;
2026-05-18 21:30:56.252876 - dartle-c[main 32938] - INFO - Compiling object files into directory &quot;out&quot;


<span style="color:#a0a">2026-05-18 21:30:56.302414 - dartle[main 32938] - PROFILE - Task &#39;compileC&#39; completed successfully in 49ms, 737μs</span>
2026-05-18 21:30:56.302459 - dartle[main 32938] - INFO - Running task &#39;<span style="font-weight:bold">archiveObjects</span>&#39;
2026-05-18 21:30:56.302650 - dartle-c[main 32938] - INFO - Creating archive &quot;libdartle-c.a&quot;


<span style="color:#a0a">2026-05-18 21:30:56.320850 - dartle[main 32938] - PROFILE - Task &#39;archiveObjects&#39; completed successfully in 18ms, 380μs</span>
<span style="color:#a0a">2026-05-18 21:30:56.324313 - dartle[main 32938] - PROFILE - Post-run action of task &#39;compileC&#39; completed successfully in 3ms, 429μs</span>
<span style="color:#a0a">2026-05-18 21:30:56.325945 - dartle[main 32938] - PROFILE - Post-run action of task &#39;archiveObjects&#39; completed successfully in 1ms, 616μs</span>
<span style="color:#a0a">2026-05-18 21:30:56.325987 - dartle[main 32938] - PROFILE - Garbage-collected cache in 8μs</span>
<span style="color:#0a0">✔ Build succeeded in 77ms, 228μs!</span>
</pre>

{{end}}

<hr>

<div id="conclusion"></div>
### Conclusion

With this, we come to the end of the Dartle Overview armed with a fully incremental C build system!

While you could use this to write your own build system, if you actually want a C build system, I turned the examples
in this page into the [Dartle_C](https://github.com/renatoathaydes/dartle_c) Dartle extension.

If you like Dartle and want to learn more, try some of these pages next:

* [Dartle CLI](cli.html)
* [Dartle as a Dart library](dartle-derived-build-tool.html)
* [Tasks](tasks.html)
* [Helper Functions](reference/helper-functions.html)

{{end}}
{{ include /processed/fragments/_footer.html }}
