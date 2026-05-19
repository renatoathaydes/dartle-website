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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-website</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">dartle-1.0</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle --help
Dartle 1.0.0

https:&#47;&#47;github.com&#47;renatoathaydes&#47;dartle

Usage: dartle [&lt;options&gt;] [&lt;tasks&gt;]

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
</pre>

> When the _informational_ options are used, i.e. `--help`, `--show-tasks` and `--show-task-graph`,
> no build tasks are run.

To see what tasks are available in a build, on a directory containing a `dartle.dart` script, use the `-s` flag:


<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-website</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">dartle-1.0</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle -s
<span style="color:#00a">======== Showing build information only, no tasks will be executed ========</span>

Tasks declared in this build:

<span style="color:#00a;font-style:italic">==&gt; Setup Phase:</span>
  * <span style="font-weight:bold">clean</span>
<span style="color:#00a;font-style:italic">==&gt; Build Phase:</span>
  * <span style="font-weight:bold">downloadMagnanimous</span><span style="color:#0a0"> [up-to-date]</span>
      Download Magnanimous
  * <span style="font-weight:bold">runMagnanimous</span> [default]<span style="color:#0a0"> [up-to-date]</span>
      Builds the Dartle Website using Magnanimous
<span style="color:#00a;font-style:italic">==&gt; TearDown Phase:</span>
  No tasks in this phase.

The following tasks were selected to run, in order:

  downloadMagnanimous
      runMagnanimous
</pre>

The output depends on the build script, as that's what defines the tasks in a build. In the above case, we're using
the [Dartle Website](https://github.com/renatoathaydes/dartle-website)'s own Dartle script.

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

This would mean that `taskA` and `taskB` execute simultaneously (using different Dart Isolates by default) at first, then once they complete, `taskC` executes,
and finally `taskD` and `taskE` execute in parallel.

The `-g` option shows a task graph, which makes it easy to understand the tasks' dependencies:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-website</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">dartle-1.0</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle -g
<span style="color:#00a">======== Showing build information only, no tasks will be executed ========</span>

Tasks Graph:

- clean
- downloadMagnanimous
- runMagnanimous
  &#92;--- downloadMagnanimous

The following tasks were selected to run, in order:

  downloadMagnanimous
      runMagnanimous
</pre>

In very simple builds, this may not look very helpful, but on more complex builds, like
[jb's Dartle build](https://github.com/renatoathaydes/jb), it can become quite handy:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">jb</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle -g
<span style="color:#00a">======== Showing build information only, no tasks will be executed ========</span>

Tasks Graph:

- analyzeCode
  +--- format
  |     +--- generateEmbeddedAssets
  |     |--- generateJbConfigModel
  |     |--- generateLicenses
  |     &#92;--- generateVersionFile
  |--- generateEmbeddedAssets
  |--- generateJbConfigModel
  |--- generateLicenses
  |--- generateVersionFile
  &#92;--- runPubGet
- build
  +--- analyzeCode ...
  |--- format ...
  |--- runPubGet
  &#92;--- test
       +--- analyzeCode ...
       |--- cleanExamples
       |--- compileExe
       |     &#92;--- analyzeCode ...
       &#92;--- setupTestMvnRepo
            &#92;--- buildMvnRepoListsProject
- clean
  +--- cleanExamples
  &#92;--- cleanTests
- distribution
  &#92;--- compileExe ...
- emptyGeneratedAssets

The following tasks were selected to run, in order:

  generateJbConfigModel
  generateLicenses
  generateVersionFile
  cleanExamples
      buildMvnRepoListsProject
          setupTestMvnRepo
              generateEmbeddedAssets
              runPubGet
                  format
                      analyzeCode
                          compileExe
                              test
                                  build
</pre>

> The `...` after some tasks shown above means that the dependencies of the task are not being shown as they appeared
> earlier in the graph already.

The graph shows task dependencies as _child_ nodes, so in the graph above, while `emptyGeneratedAssets` has no dependencies,
`build` depends on `analyzeCode`, `format`, `runPubGet` and `test` directly (and those tasks have their own dependencies).

{{ end }}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Running Tasks" }}

If you run `dartle` without any arguments, the default task(s) defined in the build will be executed. If no default task
is defined, an error occurs.

To run one or more specific tasks, give the name of the task(s) as arguments. For example, to run
`clean` and `compileExe` (i.e. run a clean build that compiles an executable):

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">jb</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle clean compileExe
2026-05-19 19:46:22.434484 - dartle[main 1085] - INFO - Executing <span style="font-weight:bold">9 tasks</span> out of a total of 17 tasks: 2 tasks selected, 9 dependencies, 2 <span style="color:#0a0">up-to-date</span>
2026-05-19 19:46:22.434680 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">clean</span>&#39;
2026-05-19 19:46:22.434824 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">generateJbConfigModel</span>&#39;
2026-05-19 19:46:22.434869 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">generateLicenses</span>&#39;
2026-05-19 19:46:22.434946 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">generateVersionFile</span>&#39;
Formatted lib&#47;src&#47;jb_config.g.dart
Formatted 1 file (1 changed) in 0.02 seconds.
Formatted lib&#47;src&#47;licenses.g.dart
Formatted 1 file (1 changed) in 0.04 seconds.
2026-05-19 19:46:26.246886 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">generateEmbeddedAssets</span>&#39;
2026-05-19 19:46:26.246947 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">runPubGet</span>&#39;
Will not generate lib&#47;src&#47;jbuild_jar.g.dart as it already exists (size &gt; 32)!
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 96.0.0 (100.0.0 available)
  analyzer 10.2.0 (13.0.0 available)
  async 2.13.0 (2.13.1 available)
  build 4.0.4 (4.0.6 available)
  build_runner 2.12.2 (2.15.0 available)
  built_value 8.12.4 (8.12.6 available)
  dart_style 3.1.7 (3.1.9 available)
  json_annotation 4.11.0 (4.12.0 available)
  matcher 0.12.19 (0.12.20 available)
  meta 1.18.1 (1.18.2 available)
  test 1.30.0 (1.31.1 available)
  test_api 0.7.10 (0.7.12 available)
  test_core 0.6.16 (0.6.18 available)
  vm_service 15.0.2 (15.2.0 available)
  xml 6.6.1 (7.0.1 available)
Got dependencies!
15 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.

2026-05-19 19:46:26.493890 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">format</span>&#39;
2026-05-19 19:46:26.800615 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">analyzeCode</span>&#39;
Analyzing ....
No issues found!
2026-05-19 19:46:27.606614 - dartle[main 1085] - INFO - Running task &#39;<span style="font-weight:bold">compileExe</span>&#39;

Generated: &#47;Users&#47;renatoathaydes&#47;programming&#47;projects&#47;jb&#47;build&#47;bin&#47;jb

<span style="color:#0a0">✔ Build succeeded in 9s, 21ms</span>
</pre>

> Notice how Dartle automatically ran several tasks, even though only `clean` and `compileExe` were called explicitly.
  You can check that the tasks executing match the dependency graph printed in the previous section!

Dartle can match partial names when there's no ambiguity, using capital letters as word separators.

An example should make it clear how that works.

Imagine a build with the following tasks:

* `compileJava`
* `compileDart`
* `testJava`
* `testDart`

To run the `compileJava` task, you may use:

    dartle compileJava

Or:

    dartle compJ

Or even:

    dartle cJ

Because there's no other tasks whose name start with `c` and then `J`.

Using just `dartle compile` wouldn't work because that could match
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

### Next Steps

Check out the [Dartle Tasks](tasks.html) documentation to familiarize yourself with the main concept in Dartle.

Or if you prefer, go directly to [Dartle for Dart](dartle-for-dart.html) if you want to use Dartle to build Dart
projects, or [Derived Build Tools](dartle-derived-build-tool.html) to build your own build tool using Dartle
as a library.

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}
