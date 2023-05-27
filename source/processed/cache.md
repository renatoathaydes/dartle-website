{{ define title "Dartle Cache" }}\
{{ define order 5 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "The Dartle Cache" }}

For a build system to work intelligently, it needs to know what exactly it's building. This is so that the system
can sort the tasks that it needs to execute in the correct order, and avoid work that has already been done
on subsequent runs.

This is what the Dartle Cache allows Dartle to achieve. The cache is implemented as a
[library within the Dartle project](https://pub.dev/documentation/dartle/latest/dartle_cache/dartle_cache-library.html),
so it's possible to use it as a stand-alone Dart library!

For an example of using the `DartleCache`, check the [example DartleCache CLI](https://github.com/renatoathaydes/dartle/blob/master/example/cache_example.dart)
code, which can be used to keep track of changes on a certain directory.

{{end}}
{{component /processed/fragments/_section.html}}
{{ define sectionTitle "DartleCache API" }}

This section shows the most important parts of the API.

The full API can be found in [pub.dev](https://pub.dev/documentation/dartle/latest/dartle_cache/DartleCache-class.html).

### Caching file collections

The `DartleCache` can be used as a function to cache [FileCollection](reference/file-collections.html)s:

```dart
import 'package:dartle/dartle_cache.dart';

final cache = DartleCache('.cache-directory');

// cache everything in the `source` dir:
main() async {
  await cache(dir('source'));
}
```

> The next examples will omit the imports and `cache` declarations for brevity.

A second argument, `key` may be provided to _scope_ changes. This is used in Dartle to make
sure that files changes between invocations of different tasks can be recognized. For example,
two tasks may have the same inputs, but that doesn't mean that just because one task ran, the
other doesn't need to also run later, despite the fact that the previous task had cached the files.

```dart
// cache everything in the `source` dir, but only for a key `my-key`:
main() async {
  await cache(dir('source'), key: 'my-key');
}
```

To cache only files with a certain extension:

```dart
// cache *.txt in the `source` dir:
main() async {
  await cache(dir('source', fileExtensions: const {'.txt'}));
}
```

### Checking for changes

The simplest way to check for changes is by calling `hasChanged`,
which takes the same arguments as the cache function:

```dart
main() async {
  bool changed = await cache.hasChanged(dir('source'));
  print(changed);
}
```

To find out exactly what has changed, use `findChanges` instead:

```dart
main() async {
  final changes = await cache.findChanges(dir('source'));
  await for (final change in changes) {
    print('${change.entity.path} - ${change.kind}');
  }
}
```

This is used by Dartle to implement incremental builds.

### Task invocation support

`DartleCache` also supports caching task invocations. For example:

```dart
main(List<String> args) async {
  await cache.cacheTaskInvocation('myTask', args);
}
```

To check if the invocation is the same as last time (i.e. whether the arguments are the same as last time):

```dart
main(List<String> args) async {
  bool changed =await cache.hasTaskInvocationChanged('myTask', args);
  print(changed);
}
```

It's also possible to check at what time the latest invocation of a task happened:

```dart
main() async {
  DateTime? dateTime = await cache.getLatestInvocationTime('myTask');
  print(dateTime);
}
```

### Cleaning up

To completely cleanup the cache, call `clean` without any arguments:

```dart
main() async {
  await cache.clean();
}
```

To only cleanup cached artifacts for a particular key, pass the key as an argument:

```dart
main() async {
  await cache.clean('key');
}
```

It's also possible to remove only a provided `FileCollection` or task invocation.

```dart
main() async {
  await cache.remove(dir('source'), key: 'key');
  await cache.removeTaskInvocation('myTask');
}
```

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}