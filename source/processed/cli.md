{{ define title "CLI" }}\
{{ define order 3 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Dartle CLI" }}

Dartle is mostly meant to be used as a CLI (Command-Line Interface) Application.

Users are expected to run commands on a terminal (or use other tools to do it) to drive a build.

In this page, features of the Dartle CLI are explained in detail.

{{ end }}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Informational Options" }}

Use `-h`, or `--help` to show usage:

```shell
$ dartle --help
Dartle 0.24.0

https://github.com/renatoathaydes/dartle

Usage: dartle [<options>] [<tasks>]

Runs a Dartle build.
Tasks are declared in the dartle.dart file. If no task is given, the
default tasks are run.

Options:
-l, --log-level              Set the log level.
[trace, debug, info (default), warn, error, profile]
-c, --[no-]color             Use ANSI colors to colorize output.
(defaults to on)
-f, --force-tasks            Force all selected tasks to run.
-p, --[no-]parallel-tasks    Allow tasks to run in parallel using Isolates.
(defaults to on)
-s, --show-tasks             Show all tasks in this build. Does not run any tasks when enabled.
-g, --show-task-graph        Show the task graph for this build. Does not run any tasks when enabled.
-z, --reset-cache            Reset the Dartle cache.
-v, --version                Show the Dartle version.
-h, --help                   Show this help message.
-d, --disable-cache          Whether to disable the Dartle cache.
```

> When the _informational_ options are used, i.e. `--help`, `--show-tasks` and `--show-task-graph`,
> no build tasks are run.

To see what tasks are available in a build, on a directory containing a `dartle.dart` script, use the `-s` flag:

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

The output depends on the build script, as that's what defines the tasks in a build.

At the end of the output above, you can see the tasks that would've executed if the `-s` flag hadn't been given.

Tasks further to the right are executed after tasks to the left. In the output above, that means `downloadMagnanimous`
runs first, and then `runMagnanimous` runs once it completes.

Task may also be executed in parallel, in which case they are shown at the same level.

For example:

```shell
  taskA
  taskB
      taskC
          taskD
          taskE
```

This would mean that `taskA` and `taskB` execute simultaneously at first, then once they complete, `taskC` executes,
and finally `taskD` and `taskE` execute in parallel.

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

> The `...` after some tasks shown above means that the dependencies of the task are not being shown as they appeared
> earlier in the graph already.

The graph shows task dependencies as _child_ nodes, so in the graph above, while `clean` has no dependencies,
`compile` depends on both `installCompileDependencies` and `installProcessorDependencies` directly, which both
depend on `writeDependencies`, in turn.

{{ end }}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Running Tasks" }}

If you run `dartle` without any arguments, the default task(s) defined in the build will be executed. If no default task
is defined, an error occurs.

To run one or more specific tasks, give the name of the task(s) as arguments. For example, to run
`compileJava` and `testJava`:

```shell
$ dartle compileJava testJava
```

Dartle can match partial names when there's no ambiguity, using capital letters as word separators.

An example should make it clear how that works.

Imagine a build with tasks `compileJava, compileDart, testJava, testDart`.

To run `compileJava`, you may run `dartle compileJava`, but also `dartle compJ`, or even `dartle cJ` because there's no
other tasks whose name start with `c` and then `J`. Using just `dartle compile` wouldn't work because that could match
either `compileJava` or `compileDart`.

Similarly, `cD` would match `compileDart`, `tJ` would match `testJava`, and `tD` matches `testDart`.

{{ end }}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Task and Dartle arguments" }}

By default, all arguments are passed directly to Dartle. The example below sets the `log-level` to `debug` and runs the
`example` task:

```shell
$ dartle example -l debug
```

If you want to pass arguments to a task, prepend the argument with `:`... in the example below, the argument `abc` will
be passed to the `example` task.

```shell
$ dartle example :abc -l debug
```

Changing the order of the arguments does not affect the result, so the invocation below is equivalent to the previous
one:

```shell
$ dartle example -l debug :abc
```

When running more than one task, arguments are passed to the latest task specified.

In the example below, task `taskA` gets arguments `123` and `456`, while `taskB` gets `789`:

```shell
$ dartle taskA :123 :456 taskB :789
```

The order in which tasks run depends only on their interdependencies, not on the order in which the tasks are invoked.
Hence, in the example above, if `taskA` and `taskB` have no interdependencies, they run immediately, in parallel.
If `taskA` depends on `taskB`, `taskB` will run before `taskA` despite it being invoked last.

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}
