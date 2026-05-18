{{ define title "Dartle Home" }}\
{{ define order 0 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

Welcome to the Dartle Documentation.

[![Dartle CI](https://github.com/renatoathaydes/dartle/workflows/Dartle%20CI/badge.svg)](https://github.com/renatoathaydes/dartle/)
[![pub package](https://img.shields.io/pub/v/dartle.svg)](https://pub.dev/packages/dartle)

This page gives a short introduction to Dartle.

To learn Dartle from the basics, check out the [Dartle Overview](dartle-overview.html) page.

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Introduction" }}

> Dartle is a task-based build system written in the [Dart](https://dart.dev/) programming language.

**Dartle can be used to build or automate things!**

How exactly you use it depends on your needs:

* Write [Dart scripts](dartle-overview.html) to declare the build logic, like a more friendly and powerful Makefile.
* Use [DartleDart](dartle-for-dart.html) to build Dart projects.
* Create [your own build system](dartle-derived-build-tool.html) that is distributed as a binary executable, using
  Dartle as just a library.
* Use the [Dartle Cache](cache.html) to drive an external build system or scripts.

## Example Dartle Script

Dartle scripts are easy to read and write.

For example, to compile all C files found in the `src` directory recursively, using `gcc`:

```dart
import 'dart:io';

import 'package:dartle/dartle.dart';

final cfiles = dir('src', fileExtensions: {'.c'});
const output = 'mybinary';

final gccTask = Task(gcc,
    description: 'Compiles all C files in src/',
    runCondition: RunOnChanges(inputs: cfiles, outputs: file(output)));

main(List<String> args) => run(args, tasks: {gccTask});

gcc(_) async => execProc(Process.start('gcc', [
  '-o',
  output,
  ...await cfiles.resolveFiles().map((f) => f.path).toList(),
]));
```

In the same directory as the above `darle.dart` script, you can run `dartle gcc` from the terminal:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">basic-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle gcc
2026-05-16 19:58:38.401860 - dartle[main 56752] - INFO - Executing <span style="font-weight:bold">1 task</span> out of a total of 1 task: 1 task selected
2026-05-16 19:58:38.401913 - dartle[main 56752] - INFO - Running task &#39;<span style="font-weight:bold">gcc</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 87ms, 368μs</span>
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">basic-c</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> .&#47;mybinary<span style="font-weight:bold"> </span>
It works!
</pre>

The above `gcc` task will only execute if changes are detected on its inputs or outputs.

The [Dartle Overview](dartle-overview.html) Section takes this basic example further and implements a fully incremental
C build!

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Real-world Example" }}

This website you're reading is built using Dartle! Here's what the script looks like:

```dart
import 'dart:io';

import 'package:dartle/dartle.dart';
import 'package:path/path.dart' as paths;

const magnanimousVersion = '0.12';

String userHome() => homeDir() ?? failBuild(reason: 'Cannot find user HOME');

final magFile = File(paths.join(userHome(), '.magnanimous', 'mag'));

final magnanimousDownloadTask = Task(downloadMagnanimous,
    description: 'Download Magnanimous',
    runCondition: RunOnChanges(outputs: file(magFile.path)));

final magnanimousRunTask = Task(runMagnanimous,
    description: 'Builds the Dartle Website using Magnanimous',
    argsValidator: const RunMagnanimousArgsValidator(),
    dependsOn: {magnanimousDownloadTask.name},
    runCondition: RunOnChanges(
        inputs: entities(['dartle.dart'], [DirectoryEntry(path: 'source')]),
        outputs: dir('target')));

void main(List<String> args) {
  run(args, tasks: {
    magnanimousRunTask,
    magnanimousDownloadTask,
    createCleanTask(tasks: [magnanimousRunTask]),
  }, defaultTasks: {
    magnanimousRunTask,
  });
}

String _osArch() {
  if (Platform.isWindows) return 'windows-386.exe';
  if (Platform.isLinux) return 'linux-386';
  if (Platform.isMacOS) return 'darwin-amd64';
  failBuild(reason: 'Unsupported OS: ${Platform.operatingSystem}');
}

Future<void> downloadMagnanimous(_) async {
  await magFile.parent.create();
  final magStream = download(
      Uri.parse('https://github.com/renatoathaydes/magnanimous/releases'
          '/download/$magnanimousVersion/magnanimous-${_osArch()}'));
  await magFile.writeBinary(magStream, makeExecutable: true);
}

Future<int> runMagnanimous(List<String> args) async {
  final contextArgs = args.contains('github')
      ? ['-globalctx', '_github_global_context']
      : const [];
  return await execProc(Process.start(
      magFile.path, [...contextArgs, '-style', 'nord'],
      runInShell: true));
}

class RunMagnanimousArgsValidator implements ArgsValidator {
  const RunMagnanimousArgsValidator();

  @override
  String helpMessage() => 'Accepts the "github" argument only.';

  @override
  bool validate(List<String> args) =>
      args.isEmpty || (args.length == 1 && args.first == 'github');
}
```

Hopefully, it's easy to understand what's going on.

The `downloadMagnanimous` task downloads [Magnanimous](https://renatoathaydes.github.io/magnanimous/),
a static website generator (_also written by me, by the way 😉_), for the appropriate Operating System,
and the `runMagnanimous` task runs it.

For this to work, task `runMagnanimous` depends on `downloadMagnanimous`, so that Dartle will ensure the binary
has been downloaded before trying to run it!

Because `runMagnanimous` is the default task, this build can be executed by running the `dartle` command,
without any arguments, in the project's root directory.

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-website</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle
2026-05-16 20:16:02.874559 - dartle[main 57437] - INFO - Executing <span style="font-weight:bold">2 tasks</span> out of a total of 3 tasks: 1 task (<span style="color:#555">default</span>), 1 dependency
2026-05-16 20:16:02.874607 - dartle[main 57437] - INFO - Running task &#39;<span style="font-weight:bold">downloadMagnanimous</span>&#39;
2026-05-16 20:16:03.546637 - dartle[main 57437] - INFO - Running task &#39;<span style="font-weight:bold">runMagnanimous</span>&#39;
<span style="color:#0a0">✔ Build succeeded in 949ms, 5μs</span>
</pre>

You can execute any task you declared by passing its name as an argument to `dartle`.

For example, to run the `runMagnanimous` task:

<pre style="font-family: monospace; background:#000; color:#ccc;">
<span style="color:#0a0;font-weight:bold">➜  </span><span style="color:#0aa;font-weight:bold">dartle-website</span> <span style="color:#00a;font-weight:bold">git:(</span><span style="color:#a00;font-weight:bold">main</span><span style="color:#00a;font-weight:bold">) </span><span style="color:#a50;font-weight:bold">✗</span> dartle runMagnanimous
<span style="color:#0a0">Everything is up-to-date!</span>
<span style="color:#0a0">✔ Build succeeded in 11ms, 838μs</span>
</pre>

Dartle requires only a few letters to _find_ a task, so running `dartle run`, or `dartle rM` would work as well!

Thanks to Dartle's [Cache System](cache.html), tasks only execute when necessary, so running the build again without changing anything
does basically nothing, which is why the build log above shows that no tasks needed to be executed!

> You can force tasks to run by using the `-f` flag.
> To see all options, check the [Dart CLI](cli.html) page.

## What next?

To find out more, check some of the pages below:

* [Getting Started](getting-started.html)
* [Dartle Overview](dartle-overview.html)
* [Writing Dartle Tasks](tasks.html)
* [Helper Functions](reference/helper-functions.html)

{{end}}

I hope you enjoy using Dartle.

{{end}}
{{ include /processed/fragments/_footer.html }}
