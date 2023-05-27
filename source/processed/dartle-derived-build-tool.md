{{ define title "Derived Build Tools" }}\
{{ define order 7 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Dartle as a Dart library" }}

Dartle can be used as a simple Dart library to drive a derived build system.

The [Dartle Overview](dartle-overview.html) shows how to write a build script for compiling C programs. With a little
more work to allow configuring the build using something other than just the Dart script, the resulting script can be
compiled to an executable without any dependency on Dartle or the Dart runtime!

As an example, the [DartleC](https://github.com/renatoathaydes/dartle_c) project was created based on the
[Dartle Overview](dartle-overview.html) final code. DartleC is compiled to an executable, `dcc`, and is configured
via a YAML file, `dcc.yaml`.

The executable is as small as `6Mb`, runs really fast, and can be easily compiled on any Operating System supported
by Dart. This makes Dartle an attractive choice for authoring build tools.

Another example build tool that uses Dartle is [`jb`](https://github.com/renatoathaydes/jb), a Java build tool.
It also used a YAML file for configuration, but allows extensions (which add new Dartle tasks) to be written in any
JVM language. Extending it is also possible in Dart because, just like `Dartle`, [`jb` is a Dart library](https://pub.dev/packages/jb)
and hence, can be used in the same way.

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}