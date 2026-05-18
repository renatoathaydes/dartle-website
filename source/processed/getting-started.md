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

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">examples</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> mkdir temp &amp;&amp; cd temp
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">temp</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle
There is no dartle.dart file in the current directory.
Would you like to create one [y&#47;N]? y
2026-05-16 20:49:16.265541 - dartle[main 59802] - INFO - Detected changes in dartle.dart or pubspec, compiling Dartle executable.
2026-05-16 20:49:17.957360 - dartle[main 59802] - INFO - Re-compiled dartle.dart in 1.685 seconds
2026-05-16 20:49:18.362166 - dartle[main 59809] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 2 tasks: 1 task (<span style="color:#555">default</span>)
2026-05-16 20:49:18.362237 - dartle[main 59809] - INFO - Running task &#39;<span style="font-weight:bold">sample</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 3ms, 94μs</span>
</pre>

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
