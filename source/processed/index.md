{{ define title "Dartle" }}
{{ include /processed/fragments/_header.html }}
# Dartle Documentation
<main>
{{component /processed/fragments/_section.html}}
Welcome to the Dartle Documentation.

Dartle is a task-based build system written in the Dart programming language.

It can be used to build anything that can be automated!

For example, this website is built using Dartle itself. Here's what the script looks like:

```dart
import 'dart:io';

import 'package:dartle/dartle.dart';

final magnanimousTask = Task(magnanimous,
    description: 'Builds the Dartle Website using Magnanimous',
    runCondition: RunOnChanges(
        inputs: entities(['dartle.dart'], [DirectoryEntry(path: 'source')]),
        outputs: dir('target')));

void main(List<String> args) {
  run(args, tasks: {
    magnanimousTask,
  }, defaultTasks: {
    magnanimousTask,
  });
}

Future<void> magnanimous(_) async {
  final code = await exec(Process.start(
      'magnanimous', const ['-style', 'base16-snazzy'],
      runInShell: true));
  if (code != 0) {
    throw DartleException(message: 'magnanimous exited with code $code');
  }
}
```

> Dartle currently comes with built-in support for [Dart](https://dart.dev) Projects.
> 
> Adding support for other languages and tools is easy, contributions are welcome! 

* [Getting Started](getting-started.html)
* [Dartle Basics](dartle-basics.html)
* [Using a Dartle Project](using-a-dartle-project.html)
* [Writing Dartle Tasks](dartle-tasks.html)
{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Working with Dart Projects" }}

Dartle has built-in support for Dart Projects, making it easy to manage the lifecycle of Dart projects without having
to remember when you need to invoke each Dart tool (even after all separate tools were unified in Dart 2.10, remembering
which commands to run, and when, is a task better left to Dartle).

* [Dartle for Dart Projects](dartle-for-dart.html)
* [Integrating with the Dart build system](dart-build-system.html)

{{end}}
</main>
{{ include /processed/fragments/_footer.html }}