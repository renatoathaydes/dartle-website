import 'dart:io';

import 'package:dartle/dartle.dart';
import 'package:path/path.dart' as paths;

final magFile = File(paths.join(homeDir(), '.magnanimous', 'mag'));

final magnanimousDownloadTask = Task(downloadMagnanimous,
    description: 'Download Magnanimous',
    runCondition: RunOnChanges(outputs: file(magFile.path)));

final magnanimousRunTask = Task(runMagnanimous,
    description: 'Builds the Dartle Website using Magnanimous',
    dependsOn: {magnanimousDownloadTask.name},
    runCondition: RunOnChanges(
        inputs: entities(['dartle.dart'], [DirectoryEntry(path: 'source')]),
        outputs: dir('target')));

void main(List<String> args) {
  run(args, tasks: {
    magnanimousRunTask,
    magnanimousDownloadTask,
    createCleanTask(name: 'clean', tasks: [magnanimousRunTask]),
  }, defaultTasks: {
    magnanimousRunTask,
  });
}

Future<void> downloadMagnanimous(_) async {
  final os = Platform.isWindows
      ? 'windows-386.exe'
      : Platform.isLinux
          ? 'linux-386'
          : Platform.isMacOS
              ? 'darwin-amd64'
              : error('Unsupported OS: ${Platform.operatingSystem}');
  final req = await HttpClient()
      .getUrl(Uri.parse('https://github.com/renatoathaydes/magnanimous/releases'
          '/download/0.11.1/magnanimous-$os'));
  req.persistentConnection = false;
  req.headers.add('Accept', '*/*');
  final res = await req.close();
  if (res.statusCode == 200) {
    await magFile.parent.create();
    final handle = magFile.openWrite();
    try {
      await handle.addStream(res);
      await handle.flush();
    } finally {
      await handle.close();
    }
    if (!Platform.isWindows) {
      final proc =
          await Process.run('chmod', ['+x', magFile.path], runInShell: true);
      if (proc.exitCode != 0) error('Failed to make magnanimous executable');
    }
  } else
    error('Unable to download Magnanimous: $res');
}

Future<void> runMagnanimous(_) async {
  final code = await exec(
      Process.start(magFile.path, const ['-style', 'nord'], runInShell: true));
  if (code != 0) {
    throw DartleException(message: 'magnanimous exited with code $code');
  }
}

String homeDir() =>
    Platform.environment['HOME'] ??
    Platform.environment['USERPROFILE'] ??
    error('Cannot find user HOME');

Never error(String message) => throw DartleException(message: message);
