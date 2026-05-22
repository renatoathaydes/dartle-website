import 'package:dartle/dartle.dart';

void hello(List<String> args) => print('Hello ${args.join(', ')}!');

void main(List<String> args) {
  run(args, tasks: {Task(hello, argsValidator: const AcceptAnyArgs())});
}
