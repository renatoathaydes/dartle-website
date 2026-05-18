import 'dart:convert';
import 'dart:io';

const Map<int, String> fg = {
  30: '#000',
  31: '#a00',
  32: '#0a0',
  33: '#a50',
  34: '#00a',
  35: '#a0a',
  36: '#0aa',
  37: '#aaa',
  90: '#555',
  91: '#f55',
  92: '#5f5',
  93: '#ff5',
  94: '#55f',
  95: '#f5f',
  96: '#5ff',
  97: '#fff',
};

final Map<int, String> bg = {
  for (final e in fg.entries) e.key + 10: e.value,
};

const debug = false;

final RegExp sgr = RegExp(r'\x1b\[([\d;]*)m');

/// matches terminal line that is not supposed to be displayed
final RegExp termSignal = RegExp(r'\s+\x1b]\d+;');

class AnsiToHtml {
  String? curFg, curBg, curSpan;
  var bold = false, italic = false, underline = false, reverse = false;
  final out = StringBuffer();

  void resetCodes() {
    curFg = null;
    curBg = null;
    bold = false;
    italic = false;
    underline = false;
    reverse = false;
  }

  void startSpan() {
    final styles = <String>[];
    if (curFg != null) styles.add('color:$curFg');
    if (curBg != null) styles.add('background:$curBg');
    if (bold) styles.add('font-weight:bold');
    if (italic) styles.add('font-style:italic');
    if (underline) styles.add('text-decoration:underline');
    if (styles.isNotEmpty) {
      curSpan = '<span style="${styles.join(';')}">';
    }
  }

  void writeSpan(String text) {
    if (text.isEmpty || termSignal.hasMatch(text) || reverse) {
      curSpan = null;
      return;
    }
    if (debug) {
      print('=======\nTEXT   : ${text}\n========');
      print('=======\nWRITING: ${text.runes.toList()}\n========');
    }
    if (curSpan != null) out.write(curSpan);
    out.write(htmlEscape.convert(text));
    if (curSpan != null) {
      out.write('</span>');
      curSpan = null;
    }
  }

  /// Returns `true` to terminate the processing of the file.
  bool call(String text) {
    if (text.startsWith('Saving session...')) return true;
    if (debug) print('=======\nLINE: ${text.runes.toList()}\n========');

    var pos = 0;
    for (final m in sgr.allMatches(text)) {
      final subText = text.substring(pos, m.start);
      writeSpan(subText);

      final codesStr = m.group(1) ?? '';
      final codes = <int>[];
      for (final s in codesStr.split(';')) {
        if (s.isNotEmpty) codes.add(int.parse(s));
      }
      if (codes.isEmpty) codes.add(0); // bare "ESC[m" means reset

      var i = 0;
      while (i < codes.length) {
        final c = codes[i];
        if (c == 0) {
          resetCodes();
        } else if (c == 1) {
          bold = true;
        } else if (c == 3) {
          italic = true;
        } else if (c == 4) {
          underline = true;
        } else if (c == 7) {
          reverse = true;
        } else if (c == 22) {
          bold = false;
        } else if (c == 23) {
          italic = false;
        } else if (c == 24) {
          underline = false;
        } else if (c == 27) {
          reverse = false;
        } else if (fg.containsKey(c)) {
          curFg = fg[c];
        } else if (bg.containsKey(c)) {
          curBg = bg[c];
        } else if (c == 39) {
          curFg = null;
        } else if (c == 49) {
          curBg = null;
        } else if ((c == 38 || c == 48) &&
            i + 4 < codes.length &&
            codes[i + 1] == 2) {
          // 24-bit truecolor: ESC[38;2;R;G;Bm  /  ESC[48;2;R;G;Bm
          final color = 'rgb(${codes[i + 2]},${codes[i + 3]},${codes[i + 4]})';
          if (c == 38) {
            curFg = color;
          } else {
            curBg = color;
          }
          i += 4;
        }
        i++;
      }

      startSpan();
      pos = m.end;
    }

    writeSpan(text.substring(pos));
    out.write('\n');
    return false;
  }
}

Future<void> main() async {
  final converter = AnsiToHtml();
  print('<pre style="font-family: monospace; background:#000; color:#ccc;">');
  var lineNum = 0;
  while (true) {
    final line = stdin.readLineSync(encoding: utf8);
    if (line == null) break;
    lineNum++;
    if (lineNum < 3 &&
        (line.startsWith('Script started on') ||
            line.startsWith('Restored session:') ||
            termSignal.hasMatch(line))) continue;
    if (converter(line)) break;
    lineNum++;
  }
  stdout.write(converter.out.toString());
  print('</pre>');
}
