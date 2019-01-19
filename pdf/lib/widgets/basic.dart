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

class Padding extends SingleChildWidget {
  Padding({
    @required this.padding,
    Widget child,
  })  : assert(padding != null),
        super(child: child);

  final EdgeInsets padding;

  @override
  void layout(BoxConstraints constraints, {parentUsesSize = false}) {
    if (child != null) {
      final childConstraints = BoxConstraints(
          minWidth: constraints.minWidth,
          minHeight: constraints.minHeight,
          maxWidth: constraints.hasBoundedWidth
              ? constraints.maxWidth - padding.horizontal
              : double.infinity,
          maxHeight: constraints.hasBoundedHeight
              ? constraints.maxHeight - padding.vertical
              : double.infinity);
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      box = PdfRect(
          0.0,
          0.0,
          constraints.hasBoundedWidth
              ? constraints.maxWidth
              : child.box.w + padding.horizontal,
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : child.box.h + padding.vertical);
    } else {
      box = PdfRect(0.0, 0.0, padding.horizontal, padding.vertical);
    }
  }

  @override
  void debugPaint(Context context) {
    context.canvas
      ..setColor(PdfColor.lime)
      ..moveTo(box.x, box.y)
      ..lineTo(box.r, box.y)
      ..lineTo(box.r, box.t)
      ..lineTo(box.x, box.t)
      ..moveTo(box.x + padding.left, box.y + padding.bottom)
      ..lineTo(box.x + padding.left, box.t - padding.top)
      ..lineTo(box.r - padding.right, box.t - padding.top)
      ..lineTo(box.r - padding.right, box.y + padding.bottom)
      ..fillPath();
  }

  @override
  void paint(Context context) {
    assert(() {
      if (Document.debug) debugPaint(context);
      return true;
    }());

    if (child != null) {
      final mat = Matrix4.identity();
      mat.translate(box.x + padding.left, box.y + padding.bottom);
      context.canvas
        ..saveContext()
        ..setTransform(mat);
      child.paint(context);
      context.canvas.restoreContext();
    }
  }
}
