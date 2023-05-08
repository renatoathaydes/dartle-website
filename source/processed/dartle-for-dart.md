{{ define title "Dartle for Dart" }}\
{{ define order 6 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

If your goal is to build Dart projects, this section is for you.

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Working with Dart Projects" }}

Dartle has built-in support for Dart Projects, making it easy to manage the lifecycle of Dart projects without having
to remember when you need to invoke each Dart tool (even after all separate tools were unified in Dart 2.10, remembering
which commands to run, and when, is a task better left to Dartle).


{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}