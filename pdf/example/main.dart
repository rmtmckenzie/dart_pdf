import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

void main() {
  final pdf = Document(deflate: zlib.encode);

  pdf.addPage(Page(
      pageFormat: PdfPageFormat.letter,
      child: Column(children: <Widget>[
        Text("Hello World"),
      ])));

  var file = File('example.pdf');
  file.writeAsBytesSync(pdf.document.save());
}
