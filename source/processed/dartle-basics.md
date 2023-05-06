{{ define title "Dartle Basics" }}
{{ include /processed/fragments/_header.html }}
# Dartle Documentation
<main>

## Dartle Basics

The basic way to use Dartle is by writing a `dartle.dart` script which drives the build.

We'll see soon how to run the script. But first, let's look at the basics of a Dartle script.

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
* A `Task`'s function is what runs when the task runs, and has the basic signature `FutureOr<void> Function(List<String> args)`.

> `Task` functions may also take more arguments for incremental compilation.

## Running a Dartle build

There are a few ways to run a Dartle build.

Let's start by using Dart to run it directly, given that a Dartle script is also a _normal_ Dart script.

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
(Dartle's own observable time was 92ms, but the actual process takes around 1 full second to run on my Macbook Air,
which is annoying for a command you may want to run very often).

For that reason, Dartle can be installed as an utility that manages the compilation of Dartle scripts so that when you run
them, they start up instantly.

To activate `dartle`, run the following command:

```shell
$ dart pub global activate dartle
```

Now, you should be able to run the Dartle build as follows:

> If you get an error, make sure that `~/.pub-cache/bin` is on your `PATH`.

```shell
$ dartle hello
2023-05-06 20:26:50.972945 - dartle[main 25903] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-06 20:26:50.973047 - dartle[main 25903] - INFO - Running task 'hello'
Hello Dartle
✔ Build succeeded in 0 ms
```

This time, the script executes in around 250ms on my machine.

To make it **really** fast, you may want to compile it directly to a native binary as follows:

```shell
dart compile exe dartle.dart
Info: Compiling with sound null safety.
Generated: /Users/renato/programming/projects/dartle-website/hello/dartle.exe
```

Now, running `./dartle.exe hello` runs in just `0.050 seconds`! However, if you do that, you must remember to re-compile
the script every time you make any changes. For this reason, the recommended way to run Dartle is by using the `dartle`
utility, as that's plenty fast enough for most cases, while still being very convenient, as it will automatically
re-compile the script as needed.

## Tasks inputs/outputs

To really benefit from Dartle, you need to tell it what the inputs/outputs of your tasks are, otherwise it has no way
of knowing when it can skip running a Task.

To declare the inputs/outputs of a Task, we use an implementation of `RunCondition`.

To understand `RunCondition`, let's look at a simple build example to compile a C program. As you may know, when you
ask the C compiler to compile one or more `.c` files, you can ask it to
[output an `.o` (object) file](https://beej.us/guide/bgc/html/split/multifile-projects.html#compiling-with-object-files)
for each `.c` file. The object files can then be linked together into a final executable later.

This means that we can compile only those files we're making changes to, without having to re-compile everything even
if just a single file has changed. If we have a proper build system, we should be able to achieve that automatically.

With Dartle, we may achieve this in a few different ways. The simplest would be to declare a `Task` for each C file,
so that we do not need to compute inputs/outputs at all, just explicitly declare them.

First, create a `hello.c` file:

```c
#include <stdio.h>
int main(void) {
   printf("Hello, World!\n");
   return 0;
}
```

Now, write a Dartle script to compile just this file:

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

`file(...)` is a Dartle function that returns a `FileCollection`, which is a powerful tool to describe which files we're
interested in (see [file-collections](file-collections.html) for details).

The Task's function is now called `compileHello`, and it uses Dartle's `execProc(...)` and Dart's `Process` to execute `gcc`.
`execProc(...)` does a few tricks, like not printing the process output by default unless there's an error and checking
the exit code of the Process. There are more helpful functions to run Processes in Dartle, check out
[Executing Processes](executing-processes.html) for more information.

Now, we're ready to compile! Run `dartle compile` and you should see the following:

> Dartle will _guess_ the task you want to run if you type only the first few letters of the task name, and the
> name is not ambiguous. Uppercase letters are treated as if starting new words, which can be handy to disambiguate
> names. For example, `compE` may match a task named `compileExecutable`, but not `compileBinary`.

```shell
$ dartle compile
2023-05-06 21:03:08.928448 - dartle[main 26492] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2023-05-06 21:03:14.920246 - dartle[main 26492] - INFO - Re-compiled dartle.dart in 5.982 seconds
2023-05-06 21:03:16.182709 - dartle[main 26502] - INFO - Executing 1 task out of a total of 1 task: 1 task selected
2023-05-06 21:03:16.182831 - dartle[main 26502] - INFO - Running task 'compileHello'
✔ Build succeeded in 706 ms
```

You should find a file called `hello.o` next to `hello.c`, which means that it worked!

Running the build again should result in no Tasks actually running, as everything is up-to-date.

```shell
$ dartle compile
2023-05-06 21:05:01.998423 - dartle[main 26551] - INFO - Executing 0 tasks out of a total of 1 task: 1 task selected, 1 up-to-date
✔ Build succeeded in 3 ms
```

It's very important to properly define the Task's inputs/outputs, otherwise work that should be peformed will be wrongly
skipped!

If you delete the object file, or change the C file, Dartle will re-run the task.

## Tasks Dependencies

Another very important concept in Dartle is that of dependencies between tasks. If a task depends on another, it must
run AFTER the other task has been executed successfully. That also means that the inputs of a task are also inputs
of any tasks that depend on it.

Continuing with our C example, let's add another task to _link_ the object file (there's only one so far, but bear with me)
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
  runCondition: RunOnChanges(outputs: file('hello')))
```

Notice that this task only needs to declare outputs, because it already depends on other tasks which declare inputs.
The `link` task will run whenever any of the tasks it depends on (`compileHello` in this case) runs,
so in a way, it _inherits_ its dependencies' inputs.

The `main` function now looks like this:

```dart
main(List<String> args) => run(args, tasks: {
      Task(compileHello,
          runCondition: RunOnChanges(
            inputs: file('hello.c'),
            outputs: file('hello.o'),
          )),
      Task(link,
          dependsOn: {'compileHello'},
          runCondition: RunOnChanges(outputs: file('hello'))),
    });
```

Running `dartle link` should produce a `hello` file which can be executed immediately:

```shell
$ dartle link
2023-05-06 21:36:29.098988 - dartle[main 27775] - INFO - Executing 1 task out of a total of 2 tasks: 1 task selected, 1 dependency, 1 up-to-date
2023-05-06 21:36:29.099146 - dartle[main 27775] - INFO - Running task 'link'
✔ Build succeeded in 102 ms

./hello
Hello, World!
```

</main>
{{ include /processed/fragments/_footer.html }}