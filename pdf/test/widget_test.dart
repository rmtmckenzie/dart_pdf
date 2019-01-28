/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:test/test.dart';

void main() {
  test('Pdf', () {
    Document.debug = false;

    var pdf = Document(deflate: zlib.encode);

    final symbol =
        pdf.defaultTextStyle.copyWith(font: PdfFont.zapfDingbats(pdf.document));
    final bold = pdf.defaultTextStyle
        .copyWith(font: PdfFont.helveticaBold(pdf.document));

    final imData = zlib.decode(base64.decode(
        "eJz7//8/w388uOTCT6a4Ez96Q47++I+OI479mEVALyNU7z9seuNP/mAm196Ekz8YR+0dWHtBmJC9S+7/Zog89iMIKLYaHQPVJGLTD7MXpDfq+I9goNhPdPPDjv3YlnH6Jye6+2H21l/6yeB/4HsSDr1bQXrRwq8HqHcGyF6QXp9933N0tn/7Y7vn+/9gLPaih0PDlV9MIAzVm6ez7dsfzW3f/oMwzAx0e7FhoJutdbcj9MKw9frnL2J2POfBpxeEg478YLba/X0Wsl6lBXf+s0bP/s8ePXeWePJCvPEJNYMRZIYWSO/cq/9Z/Nv+M4bO+M8YDjFDJGkhzvSE7A6jRTdnsQR2wfXCMLHuMC5byyidvGgWE5JeZDOIcYdR+TpmkBno+mFmAAC+DGhl"));
    final im = PdfImage(pdf.document, image: imData, width: 16, height: 20);

    pdf.addPage(Page(
        pageFormat: PdfPageFormat(400.0, 400.0),
        margin: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: PdfColor.amber,
                  border: BoxBorder(
                      top: true,
                      bottom: true,
                      left: true,
                      right: true,
                      width: 2.0)),
              child: Text("Hello World",
                  textScaleFactor: 2.0, textAlign: TextAlign.center)),
          Align(alignment: Alignment.topLeft, child: Text("How are you?")),
          Padding(padding: EdgeInsets.all(5.0)),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image(im),
                PdfLogo(),
                Column(children: <Widget>[
                  Text("(", style: symbol),
                  Text("4", style: symbol),
                ]),
              ]),
          Padding(
              padding: EdgeInsets.only(left: 30, top: 20),
              child: Lorem(textAlign: TextAlign.justify)),
          Expanded(child: FittedBox(child: Text("Expanded"))),
          Container(
              padding: EdgeInsets.only(top: 5),
              decoration:
                  BoxDecoration(border: BoxBorder(top: true, width: 1.0)),
              child: Text("That's all Folks!",
                  textAlign: TextAlign.center,
                  style: pdf.defaultTextStyle
                      .copyWith(font: PdfFont.timesBoldItalic(pdf.document)),
                  textScaleFactor: 3.0)),
        ])));

    pdf.addPage(Page(
        pageFormat: PdfPageFormat(400.0, 200.0),
        margin: EdgeInsets.all(10.0),
        child: Align(
            alignment: Alignment.topCenter,
            child: Table(
                border: TableBorder(color: PdfColor.fromInt(0xffbada55)),
                children: <TableRow>[
                  TableRow(children: <Widget>[
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: BoxBorder(
                                    color: PdfColor.fromInt(0xffbada55),
                                    bottom: true,
                                    right: true)),
                            child: Text("Company", style: bold))),
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: BoxBorder(
                                color: PdfColor.fromInt(0xffbada55),
                                bottom: true,
                                right: true)),
                        child: Text("Contact", style: bold)),
                    Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: BoxBorder(
                                color: PdfColor.fromInt(0xffbada55),
                                bottom: true)),
                        child: Text("Country", style: bold))
                  ]),
                  TableRow(children: <Widget>[
                    Text("Alfreds Futterkiste"),
                    Text("Maria Anders"),
                    Text("Germany")
                  ]),
                  TableRow(children: <Widget>[
                    Text("Centro comercial Moctezuma"),
                    Text("Francisco Chang"),
                    Text("Mexico")
                  ]),
                  TableRow(children: <Widget>[
                    Text("Ernst Handel"),
                    Text("Roland Mendel"),
                    Text("Austria")
                  ]),
                  TableRow(children: <Widget>[
                    Text("Island Trading"),
                    Text("Helen Bennett"),
                    Text("UK")
                  ]),
                  TableRow(children: <Widget>[
                    Text("Laughing Bacchus Winecellars"),
                    Text("Yoshi Tannamuri"),
                    Text("Canada")
                  ]),
                  TableRow(children: <Widget>[
                    Text("Magazzini Alimentari Riuniti"),
                    Text("Giovanni Rovelli"),
                    Text("Italy")
                  ]),
                ]))));

    var file = File('widgets.pdf');
    file.writeAsBytesSync(pdf.document.save());
  });
}
