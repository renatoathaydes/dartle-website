import 'package:dartle/dartle.dart';

main(List<String> args) => run(args, tasks: {Task(hello)});

hello(_) => print('Hello Dartle');

