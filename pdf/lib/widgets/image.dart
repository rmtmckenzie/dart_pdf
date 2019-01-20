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

class Image extends Widget {
  final PdfImage image;
  final double aspectRatio;

  Image(this.image)
      : aspectRatio = (image.height.toDouble() / image.width.toDouble());

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    final w = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(image.width.toDouble());
    final h = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(image.height.toDouble());

    if (aspectRatio >= 1.0) {
      box = PdfRect.fromPoints(PdfPoint.zero, PdfPoint(h / aspectRatio, h));
    } else {
      box = PdfRect.fromPoints(PdfPoint.zero, PdfPoint(w, w / aspectRatio));
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    context.canvas.drawImage(image, box.x, box.y, box.w, box.h);
  }
}

class Shape extends Widget {
  final String shape;
  final PdfColor strokeColor;
  final PdfColor fillColor;
  final double width;
  final double height;
  final double aspectRatio;

  Shape(this.shape,
      {this.strokeColor, this.fillColor, this.width = 1.0, this.height = 1.0})
      : assert(width != null && width > 0.0),
        assert(height != null && height > 0.0),
        aspectRatio = height / width;

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    final w = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(width);
    final h = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(height);

    if (aspectRatio >= 1.0) {
      box = PdfRect.fromPoints(PdfPoint.zero, PdfPoint(h / aspectRatio, h));
    } else {
      box = PdfRect.fromPoints(PdfPoint.zero, PdfPoint(w, w / aspectRatio));
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    final mat = Matrix4.identity();
    mat.translate(box.x, box.y + box.h);
    mat.scale(box.w / width, -box.h / height);
    context.canvas
      ..saveContext()
      ..setTransform(mat);

    if (fillColor != null) {
      context.canvas
        ..setColor(fillColor)
        ..drawShape(shape, stroke: false)
        ..fillPath();
    }

    if (strokeColor != null) {
      context.canvas
        ..setColor(strokeColor)
        ..drawShape(shape, stroke: true);
    }

    context.canvas.restoreContext();
  }
}
