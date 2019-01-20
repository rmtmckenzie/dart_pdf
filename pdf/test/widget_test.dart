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
    Document.debug = true;

    var pdf = Document(deflate: zlib.encode);

    final symbol =
        pdf.defaultTextStyle.copyWith(font: PdfFont.zapfDingbats(pdf.document));

    final imData = zlib.decode(base64.decode(
        "eJz7//8/w388uOTCT6a4Ez96Q47++I+OI479mEVALyNU7z9seuNP/mAm196Ekz8YR+0dWHtBmJC9S+7/Zog89iMIKLYaHQPVJGLTD7MXpDfq+I9goNhPdPPDjv3YlnH6Jye6+2H21l/6yeB/4HsSDr1bQXrRwq8HqHcGyF6QXp9933N0tn/7Y7vn+/9gLPaih0PDlV9MIAzVm6ez7dsfzW3f/oMwzAx0e7FhoJutdbcj9MKw9frnL2J2POfBpxeEg478YLba/X0Wsl6lBXf+s0bP/s8ePXeWePJCvPEJNYMRZIYWSO/cq/9Z/Nv+M4bO+M8YDjFDJGkhzvSE7A6jRTdnsQR2wfXCMLHuMC5byyidvGgWE5JeZDOIcYdR+TpmkBno+mFmAAC+DGhl"));
    final im = PdfImage(pdf.document, image: imData, width: 16, height: 20);

    pdf.addPage(Page(
        pageFormat: PdfPageFormat(400.0, 400.0),
        margin: EdgeInsets.all(10.0),
        child: Column(children: <Widget>[
          Text("Hello World", textScaleFactor: 2.0),
          Text("How are you?"),
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
          Padding(padding: EdgeInsets.all(20.0)),
          Expanded(child: Text("Expanded")),
          Text("That's all Folks!",
              textAlign: TextAlign.center,
              style: pdf.defaultTextStyle
                  .copyWith(font: PdfFont.timesBoldItalic(pdf.document)),
              textScaleFactor: 3.0),
        ])));

    pdf.addPage(Page(
        pageFormat: PdfPageFormat(400.0, 200.0),
        margin: EdgeInsets.all(10.0),
        child: Placeholder()));

    var file = File('widgets.pdf');
    file.writeAsBytesSync(pdf.document.save());
  });
}
