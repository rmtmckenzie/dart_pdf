/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General 
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General  License for more details.
 *
 * You should have received a copy of the GNU Lesser General 
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

part of pdf;

class PdfTtfFont extends PdfFont {
  PdfObjectStream _unicodeCMap;
  PdfFontDescriptor _descriptor;
  PdfArrayObject _widthsObject;
  final _widths = List<String>();
  final TtfParser font;
  int _charMin;
  int _charMax;
  bool get unicode => font.unicode;

  /// Constructs a [PdfTtfFont]
  PdfTtfFont(PdfDocument pdfDocument, ByteData bytes)
      : font = TtfParser(bytes),
        super._create(pdfDocument, subtype: "/TrueType") {
    PdfObjectStream file = PdfObjectStream(pdfDocument, isBinary: true);
    final data = bytes.buffer.asUint8List();
    file.buf.putBytes(data);
    file.params["/Length1"] = PdfStream.intNum(data.length);

    _charMin = 32;
    _charMax = 255;

    for (var i = _charMin; i <= _charMax; i++) {
      _widths.add((glyphAdvance(i) * 1000.0).toString());
    }

    _unicodeCMap = PdfObjectStream(pdfDocument);
    _descriptor = PdfFontDescriptor(this, file);
    _widthsObject = PdfArrayObject(pdfDocument, _widths);
  }

  @override
  String get fontName => "/" + font.fontName.replaceAll(" ", "");

  @override
  double glyphAdvance(int charCode) {
    var g = font.charToGlyphIndexMap[charCode];

    if (g == null) {
      return super.glyphAdvance(charCode);
    }

    return (g < font.advanceWidth.length ? font.advanceWidth[g] : null) ??
        super.glyphAdvance(charCode);
  }

  @override
  PdfRect glyphBounds(int charCode) {
    var g = font.charToGlyphIndexMap[charCode];

    if (g == null) {
      return super.glyphBounds(charCode);
    }

    return font.glyphInfoMap[g] ?? super.glyphBounds(charCode);
  }

  @override
  void _prepare() {
    super._prepare();

    params["/BaseFont"] = PdfStream.string(fontName);
    params["/FirstChar"] = PdfStream.intNum(_charMin);
    params["/LastChar"] = PdfStream.intNum(_charMax);
    params["/Widths"] = _widthsObject.ref();
    params["/FontDescriptor"] = _descriptor.ref();
    // params["/Encoding"] = PdfStream.string("/Identity-H");
    // params["/ToUnicode"] = _unicodeCMap.ref();

    _unicodeCMap.buf.putString("/CIDInit/ProcSet findresource begin\n"
        "12 dict begin\n"
        "begincmap\n"
        "/CIDSystemInfo<<\n"
        "/Registry (Adobe)\n"
        "/Ordering (UCS)\n"
        "/Supplement 0\n"
        ">> def\n"
        "/CMapName/Adobe-Identity-UCS def\n"
        "/CMapType 2 def\n"
        "1 begincodespacerange\n"
        "<00> <FF>\n"
        "endcodespacerange\n"
        "11 beginbfchar\n"
        "<01> <0048>\n"
        "<02> <0065>\n"
        "<03> <006C>\n"
        "<04> <006F>\n"
        "<05> <0020>\n"
        "<06> <004C>\n"
        "<07> <0075>\n"
        "<08> <006B>\n"
        "<09> <00E1>\n"
        "<0A> <010D>\n"
        "<0B> <0061>\n"
        "endbfchar\n"
        "endcmap\n"
        "CMapName currentdict /CMap defineresource pop\n"
        "end\n"
        "end");
  }

  int unicodeCMap(int rune) {
    return rune.clamp(0, 255);
  }
}
