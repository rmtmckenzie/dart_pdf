import 'dart:convert';
import 'dart:html';
import 'package:pdf/pdf.dart';
import 'package:archive/archive.dart';

void main() {
  querySelector('#output').text =
      'Click the download button to generate the PDF';
  ButtonElement downloadButton = querySelector('#download');

  downloadButton.onClick.listen((_) {
    final data = Uri.encodeComponent(base64.encode(buildPdf()));
    AnchorElement(href: "data:application/pdf;base64,$data")
      ..setAttribute("download", "example.pdf")
      ..click();
  });
}

List<int> buildPdf() {
  final pdf =
      PdfDocument(deflate: (List<int> data) => ZLibEncoder().encode(data));
  final page = PdfPage(pdf, pageFormat: PdfPageFormat.letter);
  final g = page.getGraphics();
  final font = g.defaultFont;
  final top = page.pageFormat.height;

  g.setColor(PdfColor(0.0, 1.0, 1.0));
  g.drawRect(50.0 * PdfPageFormat.mm, top - 80.0 * PdfPageFormat.mm,
      100.0 * PdfPageFormat.mm, 50.0 * PdfPageFormat.mm);
  g.fillPath();

  g.setColor(PdfColor(0.3, 0.3, 0.3));
  g.drawString(font, 12.0, "Hello World!", 10.0 * PdfPageFormat.mm,
      top - 10.0 * PdfPageFormat.mm);

  return pdf.save();
}
