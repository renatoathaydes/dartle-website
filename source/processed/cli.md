{{ define title "CLI" }}\
{{ define order 3 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Dartle CLI" }}

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


TODO

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}
