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

This is what the Dartle Cache allows Dartle to achieve. The cache is implemented as a library within the Dartle project,
so it's possible to use it as a stand-alone Dart library!

TODO Cache Documentation

{{end}}
{{end}}
{{ include /processed/fragments/_footer.html }}