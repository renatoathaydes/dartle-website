{{ define title "Reference" }}\
{{ define order 10 }}\
{{ include /processed/fragments/_header.html }}\
{{component /processed/fragments/_main.html}}\
{{define mainTitle "Dartle Documentation"}}\

{{component /processed/fragments/_section.html}}
{{ define sectionTitle "Dartle Reference" }}

{{for page (sortBy order) /processed/reference }}
* [{{eval page.title}}]({{eval basePath}}{{ eval page }})
{{end}}

{{end}}
