import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:test/test.dart';

final fontList = Map<String, PdfFont>();

void printText(PdfGraphics g, String text, String fontFile, double top) {
  if (!fontList.containsKey(fontFile)) {
    fontList[fontFile] = PdfTtfFont(g.page.pdfDocument,
        (File(fontFile).readAsBytesSync() as Uint8List).buffer.asByteData());
  }
  var font = fontList[fontFile];
  text = text + fontFile;
  var r = font.stringBounds(text);
  const FS = 20.0;
  g.setColor(PdfColor(0.9, 0.9, 0.9));
  g.drawRect(50.0 + r.x * FS, g.page.pageFormat.height - top + r.y * FS,
      r.w * FS, r.h * FS);
  g.fillPath();
  g.setColor(PdfColor(0.3, 0.3, 0.3));
  g.drawString(font, FS, text, 50.0, g.page.pageFormat.height - top);
}

void main() {
  test('Pdf', () {
    var pdf = PdfDocument();
    var page = PdfPage(pdf, pageFormat: const PdfPageFormat(500.0, 300.0));

    var g = page.getGraphics();

    var top = 0;
    const s = "Hello Lukáča ";

    printText(g, s, "open-sans.ttf", 20.0 + 30.0 * top++);
    printText(g, s, "roboto.ttf", 20.0 + 30.0 * top++);
    printText(g, "Hello 你好世界 ", "noto-sans.ttf", 20.0 + 30.0 * top++);

    var file = File('file2.pdf');
    file.writeAsBytesSync(pdf.save());
  });
}
