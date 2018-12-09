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

class Text extends Widget {
  final String text;
  final PdfFont font;
  final double fontSize;
  final PdfColor color;
  PdfPoint _origin;

  Text(this.text,
      {@required this.font, this.fontSize = 20.0, this.color = PdfColor.black});

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    box = font.stringBounds(text) * fontSize;
    _origin = box.offset;
    box = PdfRect.fromPoints(PdfPoint.zero, box.size);
  }

  @override
  void paint(Context context) {
    super.paint(context);

    context.canvas
      ..setColor(color)
      ..drawString(font, fontSize, text, box.x + _origin.x, box.y - _origin.y);
  }
}
