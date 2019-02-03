import 'dart:io';
import 'dart:async';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

const green = PdfColor.fromInt(0xff9ce5d0);
const lightGreen = PdfColor.fromInt(0xffcdf1e7);

class MyPage extends Page {
  MyPage(
      {PdfPageFormat pageFormat = PdfPageFormat.a4,
      BuildCallback build,
      EdgeInsets margin})
      : super(pageFormat: pageFormat, margin: margin, build: build);

  void paint(Widget child, Context context) {
    context.canvas
      ..setColor(lightGreen)
      ..moveTo(0, pageFormat.height)
      ..lineTo(0, pageFormat.height - 230)
      ..lineTo(60, pageFormat.height)
      ..fillPath()
      ..setColor(green)
      ..moveTo(0, pageFormat.height)
      ..lineTo(0, pageFormat.height - 100)
      ..lineTo(100, pageFormat.height)
      ..fillPath()
      ..setColor(lightGreen)
      ..moveTo(30, pageFormat.height)
      ..lineTo(110, pageFormat.height - 50)
      ..lineTo(150, pageFormat.height)
      ..fillPath()
      ..moveTo(pageFormat.width, 0)
      ..lineTo(pageFormat.width, 230)
      ..lineTo(pageFormat.width - 60, 0)
      ..fillPath()
      ..setColor(green)
      ..moveTo(pageFormat.width, 0)
      ..lineTo(pageFormat.width, 100)
      ..lineTo(pageFormat.width - 100, 0)
      ..fillPath()
      ..setColor(lightGreen)
      ..moveTo(pageFormat.width - 30, 0)
      ..lineTo(pageFormat.width - 110, 50)
      ..lineTo(pageFormat.width - 150, 0)
      ..fillPath();

    super.paint(child, context);
  }
}

class Block extends StatelessWidget {
  Block({this.title});

  final String title;

  @override
  Widget build(Context context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(top: 2.5, left: 2, right: 5),
              decoration: BoxDecoration(color: green, shape: BoxShape.circle),
            ),
            Text(title, style: Theme.of(context).defaultTextStyleBold),
          ]),
          Container(
            decoration: BoxDecoration(
                border: BoxBorder(left: true, color: green, width: 2)),
            padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: EdgeInsets.only(left: 5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Lorem(length: 20),
                ]),
          ),
        ]);
  }
}

class Category extends StatelessWidget {
  Category({this.title});

  final String title;

  @override
  Widget build(Context context) {
    return Container(
        decoration: BoxDecoration(color: lightGreen, borderRadius: 6),
        margin: EdgeInsets.only(bottom: 10, top: 20),
        padding: EdgeInsets.fromLTRB(10, 7, 10, 4),
        child: Text(title, textScaleFactor: 1.5));
  }
}

Future<PdfDocument> generateDocument(PdfPageFormat format) async {
  final pdf = Document(deflate: zlib.encode);

  pdf.addPage(MyPage(
    pageFormat: format.applyMargin(
        left: 2.0 * PdfPageFormat.cm,
        top: 4.0 * PdfPageFormat.cm,
        right: 2.0 * PdfPageFormat.cm,
        bottom: 2.0 * PdfPageFormat.cm),
    build: (Context context) => Row(children: <Widget>[
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Container(
                    padding: EdgeInsets.only(left: 30, bottom: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Parnella Charlesbois",
                              textScaleFactor: 2.0,
                              style: Theme.of(context).defaultTextStyleBold),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Text("Electrotyper",
                              textScaleFactor: 1.2,
                              style: Theme.of(context)
                                  .defaultTextStyleBold
                                  .copyWith(color: green)),
                          Padding(padding: EdgeInsets.only(top: 20)),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("568 Port Washington Road"),
                                      Text("Nordegg, AB T0M 2H0"),
                                      Text("Canada, ON"),
                                    ]),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("+1 403-721-6898"),
                                      Text("p.charlesbois@yahoo.com"),
                                      Text("wholeprices.ca")
                                    ]),
                                Padding(padding: EdgeInsets.zero)
                              ]),
                        ])),
                Category(title: "Work Experience"),
                Block(title: "Tour bus driver"),
                Block(title: "Logging equipment operator"),
                Block(title: "Foot doctor"),
                Category(title: "Education"),
                Block(title: "Bachelor Of Commerce"),
                Block(title: "Bachelor Interior Design"),
              ])),
          Container(
            height: double.infinity,
            width: 10,
            decoration: BoxDecoration(
                border: BoxBorder(left: true, color: green, width: 2)),
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                    child: Container(
                        width: 100,
                        height: 100,
                        color: lightGreen,
                        child: Shape(
                            "m 4.7739997,16.673194 c 2.8848088,-1.051554 3.8069366,-1.938341 3.8069366,-3.837128 0,-1.140022 -0.8809362,-0.76766 -1.2675746,-2.8553186 C 7.1528085,9.114789 6.3748508,9.9669423 6.2257657,7.9897463 c 0,-0.7877872 0.4247873,-0.9836808 0.4247873,-0.9836808 0,0 -0.2157873,-1.1659998 -0.3005107,-2.0633191 C 6.2454254,3.824959 6.996,0.93617193 11.000001,0.93617193 c 4.003763,0 4.754807,2.88878707 4.649723,4.00657447 -0.08471,0.8973193 -0.300277,2.0633191 -0.300277,2.0633191 0,0 0.424551,0.1958936 0.424551,0.9836808 -0.148615,1.977192 -0.926571,1.1250427 -1.087125,1.9910011 -0.387107,2.0876586 -1.267576,1.7152966 -1.267576,2.8553186 0,1.898787 0.92166,2.785574 3.806467,3.837128 C 20.119703,17.727789 22,18.80298 22,19.536236 l 0,2.463765 -10.999999,0 -11.000001,0 0,-2.463765 C 0,18.80298 1.8800639,17.727789 4.7739997,16.673194",
                            width: 22.0,
                            height: 21.0,
                            fillColor: PdfColor.fromInt(0xffefefef))))
              ])
        ]),
  ));
  return pdf.document;
}
