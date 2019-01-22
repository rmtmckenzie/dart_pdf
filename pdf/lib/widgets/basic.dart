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

class LimitedBox extends SingleChildWidget {
  LimitedBox({
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    Widget child,
  })  : assert(maxWidth != null && maxWidth >= 0.0),
        assert(maxHeight != null && maxHeight >= 0.0),
        super(child: child);

  final double maxWidth;

  final double maxHeight;

  BoxConstraints _limitConstraints(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.hasBoundedWidth
            ? constraints.maxWidth
            : constraints.constrainWidth(maxWidth),
        minHeight: constraints.minHeight,
        maxHeight: constraints.hasBoundedHeight
            ? constraints.maxHeight
            : constraints.constrainHeight(maxHeight));
  }

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    PdfPoint size;
    if (child != null) {
      child.layout(context, _limitConstraints(constraints),
          parentUsesSize: true);
      size = constraints.constrain(child.box.size);
    } else {
      size = _limitConstraints(constraints).constrain(PdfPoint.zero);
    }
    box = PdfRect(box.x, box.y, size.x, size.y);
  }
}

class Padding extends SingleChildWidget {
  Padding({
    @required this.padding,
    Widget child,
  })  : assert(padding != null),
        super(child: child);

  final EdgeInsets padding;

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    if (child != null) {
      final childConstraints = constraints.deflate(padding);
      child.layout(context, childConstraints, parentUsesSize: parentUsesSize);
      box = PdfRect(
          0.0,
          0.0,
          constraints.constrainWidth(child.box.w + padding.horizontal),
          constraints.constrainHeight(child.box.h + padding.vertical));
    } else {
      box = PdfRect(0.0, 0.0, constraints.constrainWidth(padding.horizontal),
          constraints.constrainHeight(padding.vertical));
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

class Transform extends SingleChildWidget {
  Transform({
    @required this.transform,
    this.origin,
    this.alignment,
    Widget child,
  })  : assert(transform != null),
        super(child: child);

  /// Creates a widget that transforms its child using a rotation around the
  /// center.
  Transform.rotate({
    @required double angle,
    this.origin,
    this.alignment = Alignment.center,
    Widget child,
  })  : transform = Matrix4.rotationZ(angle),
        super(child: child);

  /// Creates a widget that transforms its child using a translation.
  Transform.translate({
    @required PdfPoint offset,
    Widget child,
  })  : transform = Matrix4.translationValues(offset.x, offset.y, 0.0),
        origin = null,
        alignment = null,
        super(child: child);

  /// Creates a widget that scales its child uniformly.
  Transform.scale({
    @required double scale,
    this.origin,
    this.alignment = Alignment.center,
    Widget child,
  })  : transform = Matrix4.diagonal3Values(scale, scale, 1.0),
        super(child: child);

  /// The matrix to transform the child by during painting.
  final Matrix4 transform;

  /// The origin of the coordinate system
  final PdfPoint origin;

  /// The alignment of the origin, relative to the size of the box.
  final Alignment alignment;

  Matrix4 get _effectiveTransform {
    if (origin == null && alignment == null) return transform;
    final Matrix4 result = Matrix4.identity();
    if (origin != null) result.translate(origin.x, origin.y);
    PdfPoint translation;
    if (alignment != null) {
      translation = alignment.alongSize(box.size);
      result.translate(translation.x, translation.y);
    }
    result.multiply(transform);
    if (alignment != null) result.translate(-translation.x, -translation.y);
    if (origin != null) result.translate(-origin.x, -origin.y);
    return result;
  }

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    if (child != null) {
      child.layout(context, constraints, parentUsesSize: parentUsesSize);
      box = child.box;
    } else {
      box = PdfRect.zero;
    }
  }

  @override
  void paint(Context context) {
    assert(() {
      if (Document.debug) debugPaint(context);
      return true;
    }());

    if (child != null) {
      final mat = _effectiveTransform;
      context.canvas
        ..saveContext()
        ..setTransform(mat);
      child.paint(context);
      context.canvas.restoreContext();
    }
  }
}

/// A widget that aligns its child within itself and optionally sizes itself
/// based on the child's size.
class Align extends SingleChildWidget {
  Align(
      {this.alignment = Alignment.center,
      this.widthFactor,
      this.heightFactor,
      Widget child})
      : assert(alignment != null),
        assert(widthFactor == null || widthFactor >= 0.0),
        assert(heightFactor == null || heightFactor >= 0.0),
        super(child: child);

  /// How to align the child.
  final Alignment alignment;

  /// If non-null, sets its width to the child's width multiplied by this factor.
  final double widthFactor;

  /// If non-null, sets its height to the child's height multiplied by this factor.
  final double heightFactor;

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    final bool shrinkWrapWidth =
        widthFactor != null || constraints.maxWidth == double.infinity;
    final bool shrinkWrapHeight =
        heightFactor != null || constraints.maxHeight == double.infinity;

    if (child != null) {
      child.layout(context, constraints.loosen(), parentUsesSize: true);

      box = PdfRect.fromPoints(
          PdfPoint.zero,
          constraints.constrain(PdfPoint(
              shrinkWrapWidth
                  ? child.box.w * (widthFactor ?? 1.0)
                  : double.infinity,
              shrinkWrapHeight
                  ? child.box.h * (heightFactor ?? 1.0)
                  : double.infinity)));

      child.box = alignment.inscribe(child.box.size, box);
    } else {
      box = PdfRect.fromPoints(
          PdfPoint.zero,
          constraints.constrain(PdfPoint(
              shrinkWrapWidth ? 0.0 : double.infinity,
              shrinkWrapHeight ? 0.0 : double.infinity)));
    }
  }
}

/// A widget that imposes additional constraints on its child.
class ConstrainedBox extends SingleChildWidget {
  ConstrainedBox({@required this.constraints, Widget child})
      : assert(constraints != null),
        super(child: child);

  /// The additional constraints to impose on the child.
  final BoxConstraints constraints;

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    if (child != null) {
      child.layout(context, this.constraints.enforce(constraints),
          parentUsesSize: true);
      box = child.box;
    } else {
      box = PdfRect.fromPoints(PdfPoint.zero,
          this.constraints.enforce(constraints).constrain(PdfPoint.zero));
    }
  }
}

class Center extends Align {
  Center({double widthFactor, double heightFactor, Widget child})
      : super(
            widthFactor: widthFactor, heightFactor: heightFactor, child: child);
}
