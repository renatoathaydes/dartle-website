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
