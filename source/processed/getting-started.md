{{ define title "Getting Started" }}\
{{ define order 1 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Getting Started" }}

The recommended way to install Dartle is via [dart pub](https://dart.dev/tools/pub/cmd).

> If for whatever reason, you cannot use `dart pub`, download a pre-built binary from
> the [Github Releases](https://github.com/renatoathaydes/dartle/releases) page.
> You still need to have Dart installed to run the Dartle scripts, though.

If you do not have Dart installed, you'll need to [install it first](https://dart.dev/get-dart).

Make sure to [add the Pub Cache](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)
(usually `~/.pub-cache/bin`) directory to your `PATH`.

Install Dartle by running the following command:

```shell
$ dart pub global activate dartle
```

Verify that it's working:

```shell
$ dartle --version
Dartle version 0.23.2
```

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Create a Dartle Project" }}

If you run `dartle` on a directory where there's no `dartle.dart` file, Dartle will ask you if you want to create one.

```shell
$ mkdir temp
  
$ cd temp
  
$ dartle
There is no dartle.dart file in the current directory.
Would you like to create one [y/N]? y
2023-05-26 17:44:11.210553 - dartle[main 75195] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2023-05-26 17:44:17.887181 - dartle[main 75195] - INFO - Re-compiled dartle.dart in 6.662 seconds
2023-05-26 17:44:18.184342 - dartle[main 75214] - INFO - Executing 1 task out of a total of 2 tasks: 1 task (default)
2023-05-26 17:44:18.184491 - dartle[main 75214] - INFO - Running task 'sample'
✔ Build succeeded in 6 ms
```

> Dartle logs using the pattern `${date} - ${loggerName}[${isolateName} ${PID}] - ${LEVEL} ${MESSAGE}`.
> 
> While the loggerName is `dartle` when running Dartle directly, build tools that use Dartle as a library may
> add their own loggers. The `isolateName` may also be important as tasks may run on different `Isolate`s by
> default, and the PID (process ID) helps understand when different processes are being spawned.
> Log levels are used to enable more or less output, e.g. use `-l debug` to enable debug messages
> (see [Dartle CLI](cli.html) for details).

The initial project layout looks as shown below:

```shell
$ tree 
.
├── dartle-src
│     └── tasks.dart
├── dartle.dart
├── pubspec.yaml
├── source
│     └── input.txt
└── target
    └── output.txt

3 directories, 5 files
```

`dartle.dart` is the Dartle script that defines the build.

Inside `dartle-src`, you may add other Dart files that `dartle.dart` can use for building things.

`pubspec.yaml` is the Dart project descriptor, where you can add Dart dependencies among other things.

`source` is a directory with an example input file, and `target` has an example output file.

You can see in the `dartle.dart` file that there's a single task, `sampleTask`.

Because that's defined as the default task, Dartle already ran it because the command `dartle` alone always tries to
execute the default task(s).

### Next Steps

Have a look at [Dartle Overview](dartle-overview.html) to learn the most important features of Dartle, or head to
[Dartle CLI](cli.html) for more information on interacting with a Dartle build on the terminal.

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}