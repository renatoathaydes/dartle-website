import 'dart:io';

import 'package:dartle/dartle.dart';
import 'package:path/path.dart' as paths;

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
          '/download/0.11.1/magnanimous-${_osArch()}'));
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
