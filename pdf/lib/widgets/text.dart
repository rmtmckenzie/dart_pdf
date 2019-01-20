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

part of widget;

@immutable
class TextStyle {
  const TextStyle({
    this.color,
    this.font,
    this.fontSize = _defaultFontSize,
    this.letterSpacing = 1.0,
    this.wordSpacing = 1.0,
    this.height = 1.0,
    this.background,
  })  : assert(font != null),
        assert(color != null);

  final PdfColor color;

  final PdfFont font;

  final double fontSize;

  static const double _defaultFontSize = 12.0 * PdfPageFormat.point;

  final double letterSpacing;

  final double wordSpacing;

  final double height;

  final PdfColor background;

  TextStyle copyWith({
    PdfColor color,
    PdfFont font,
    double fontSize,
    double letterSpacing,
    double wordSpacing,
    double height,
    PdfColor background,
  }) {
    return TextStyle(
      color: color ?? this.color,
      font: font ?? this.font,
      fontSize: fontSize ?? this.fontSize,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      height: height ?? this.height,
      background: background ?? this.background,
    );
  }
}

enum TextAlign {
  left,
  right,
  center,
}

@immutable
class _Word {
  final String word;
  final PdfRect box;

  _Word(this.word, this.box);

  String toString() {
    return "Word $word $box";
  }
}

class Text extends Widget {
  final String data;

  TextStyle style;

  final TextAlign textAlign;

  final double textScaleFactor;

  final int maxLines;

  Text(
    this.data, {
    this.style,
    this.textAlign = TextAlign.left,
    softWrap = true,
    this.textScaleFactor = 1.0,
    int maxLines,
  })  : maxLines = !softWrap ? 1 : maxLines,
        assert(data != null);

  final _words = List<_Word>();

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    if (style == null) {
      style = context.textStyle;
    }

    final cw = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth();
    final ch = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight();

    var x = 0.0;
    var y = 0.0;
    var w = 0.0;
    var h = 0.0;
    var lh = 0.0;

    final space =
        style.font.stringBounds(" ") * (style.fontSize * textScaleFactor);

    var lines = 1;

    for (var word in data.split(" ")) {
      final box =
          style.font.stringBounds(word) * (style.fontSize * textScaleFactor);

      var ww = box.w;
      var wh = box.h;

      if (x + ww > cw) {
        if (maxLines != null && ++lines > maxLines) break;
        w = math.max(w, x - space.w);
        x = 0.0;
        y += lh;
        h += lh;
        lh = 0.0;
        if (y > ch) break;
      }

      var wx = x;
      var wy = y;

      x += ww + space.w;
      lh = math.max(lh, wh);

      final wd = _Word(word, PdfRect(box.x + wx, box.y + wy + wh, ww, wh));
      _words.add(wd);
    }
    w = math.max(w, x - space.w);
    h += lh;
    box = PdfRect(0.0, 0.0, constraints.constrainWidth(w),
        constraints.constrainHeight(h));
  }

  @override
  void paint(Context context) {
    super.paint(context);
    context.canvas.setColor(style.color);

    for (var word in _words) {
      context.canvas.drawString(style.font, style.fontSize * textScaleFactor,
          word.word, box.x + word.box.x, box.y + box.h - word.box.y);
    }
  }
}
