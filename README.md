# Dartle Website

Source code for the Dartle Website.

## Build Locally

```shell
dartle
```

## Build for GitHub Pages

```shell
dartle run :github
```

> To publish, simply push to the `main` branch.

## Create termninal samples

Use `script` to capture a session, then pipe the file to [ansi-to-html.dart](utils/ansi-to-html.dart).

Example capturing session:

```shell
➜  dartle-website git:(main) ✗ script session.log
Script started, output file is session.log
Restored session: Sat May 16 20:16:09 CEST 2026
➜  dartle-website git:(main) ✗ dartle runMagnanimous
2026-05-16 20:30:53.667146 - dartle[main 58255] - INFO - Executing 1 task out of a total of 3 tasks: 1 task selected, 1 dependency, 1 up-to-date
2026-05-16 20:30:53.667199 - dartle[main 58255] - INFO - Running task 'runMagnanimous'
✔ Build succeeded in 184ms, 995μs
➜  dartle-website git:(main) ✗ exit

Saving session...completed.

Script done, output file is session.log
```

After that, just run:

```shell
dart run utils/ansi-to-html.dart < session.log
```

Which will output the HTML.
