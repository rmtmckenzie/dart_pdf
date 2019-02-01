import 'dart:io';
import 'dart:async';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future<PdfDocument> generateDocument(PdfPageFormat format) async {
  final pdf = Document(deflate: zlib.encode);
  final lorem = LoremText();

  pdf.addPage(MultiPage(
      pageFormat: format.applyMargin(
          left: 2.0 * PdfPageFormat.cm,
          top: 2.0 * PdfPageFormat.cm,
          right: 2.0 * PdfPageFormat.cm,
          bottom: 2.0 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) return null;
        return Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: BoxDecoration(
                border:
                    BoxBorder(bottom: true, width: 0.5, color: PdfColor.grey)),
            child: Lorem(
                length: 2,
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColor.grey)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text("Page ${context.pageNumber}",
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColor.grey)));
      },
      build: (Context context) => <Widget>[
            Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Lorem(length: 2, textScaleFactor: 2.0),
                      PdfLogo()
                    ])),
            Paragraph(text: lorem.paragraph(80)),
            Paragraph(text: lorem.paragraph(60)),
            Header(level: 1, text: lorem.paragraph(5)),
            Paragraph(text: lorem.paragraph(30)),
            Paragraph(text: lorem.paragraph(50)),
            Paragraph(text: lorem.paragraph(40)),
            Header(level: 1, text: lorem.paragraph(3)),
            Paragraph(text: lorem.paragraph(35)),
            Paragraph(text: lorem.paragraph(20)),
            Paragraph(text: lorem.paragraph(80)),
            Header(level: 1, text: lorem.paragraph(2)),
            Paragraph(text: lorem.paragraph(20)),
            Bullet(text: lorem.paragraph(10)),
            Bullet(text: lorem.paragraph(15)),
            Bullet(text: lorem.paragraph(12)),
          ]));

  return pdf.document;
}
