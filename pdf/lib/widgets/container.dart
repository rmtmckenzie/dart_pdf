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

enum DecorationPosition { background, foreground }

@immutable
class BoxBorder {
  const BoxBorder(
      {this.left = false,
      this.top = false,
      this.right = false,
      this.bottom = false,
      this.color = PdfColor.black,
      this.width = 1.0})
      : assert(color != null),
        assert(width != null),
        assert(width >= 0.0);

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  /// The color of the
  final PdfColor color;

  /// The width of the
  final double width;

  void paintBorders(Context context, PdfRect box) {
    assert(box.x != null);
    assert(box.y != null);
    assert(box.w != null);
    assert(box.h != null);

    if (top || bottom || left || right) {
      context.canvas
        ..setColor(color)
        ..setLineWidth(width);

      if (top) {
        context.canvas.drawLine(box.x, box.t, box.r, box.t);
      }

      if (right) {
        if (!top) {
          context.canvas.moveTo(box.r, box.t);
        }
        context.canvas.lineTo(box.r, box.y);
      }

      if (bottom) {
        if (!right) {
          context.canvas.moveTo(box.r, box.y);
        }
        context.canvas.lineTo(box.x, box.y);
      }

      if (left) {
        if (!bottom) {
          context.canvas.moveTo(box.x, box.y);
        } else if (right && top) {
          context.canvas.closePath();
        } else
          context.canvas.lineTo(box.x, box.t);
      }

      context.canvas.strokePath();
    }
  }
}

@immutable
class BoxDecoration {
  const BoxDecoration({this.color, this.border});

  /// The color to fill in the background of the box.
  final PdfColor color;

  final BoxBorder border;

  void paintBackground(Context context, PdfRect box) {
    assert(box.x != null);
    assert(box.y != null);
    assert(box.w != null);
    assert(box.h != null);

    if (color != null) {
      context.canvas
        ..setColor(color)
        ..drawRect(box.x, box.y, box.w, box.h)
        ..fillPath();
    }
  }
}

class DecoratedBox extends SingleChildWidget {
  DecoratedBox(
      {@required this.decoration,
      this.position = DecorationPosition.background,
      Widget child})
      : assert(decoration != null),
        assert(position != null),
        super(child: child);

  /// What decoration to paint.
  final BoxDecoration decoration;

  /// Whether to paint the box decoration behind or in front of the child.
  final DecorationPosition position;

  @override
  void paint(Context context) {
    if (position == DecorationPosition.background) {
      decoration.paintBackground(context, box);
      decoration.border?.paintBorders(context, box);
    }
    super.paint(context);
    if (position == DecorationPosition.foreground) {
      decoration.paintBackground(context, box);
      decoration.border?.paintBorders(context, box);
    }
  }
}

class Container extends StatelessWidget {
  Container({
    this.alignment,
    this.padding,
    PdfColor color,
    BoxDecoration decoration,
    this.foregroundDecoration,
    double width,
    double height,
    BoxConstraints constraints,
    this.margin,
    this.transform,
    this.child,
  })  : assert(
            color == null || decoration == null,
            'Cannot provide both a color and a decoration\n'
            'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".'),
        decoration =
            decoration ?? (color != null ? BoxDecoration(color: color) : null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        super();

  final Widget child;

  final Alignment alignment;

  final EdgeInsets padding;

  /// The decoration to paint behind the [child].
  final BoxDecoration decoration;

  /// The decoration to paint in front of the [child].
  final BoxDecoration foregroundDecoration;

  /// Additional constraints to apply to the child.
  final BoxConstraints constraints;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsets margin;

  /// The transformation matrix to apply before painting the container.
  final Matrix4 transform;

  @override
  Widget build(Context context) {
    Widget current = child;

    if (child == null && (constraints == null || !constraints.isTight)) {
      current = LimitedBox(
          maxWidth: 0.0,
          maxHeight: 0.0,
          child: ConstrainedBox(constraints: const BoxConstraints.expand()));
    }

    if (alignment != null)
      current = Align(alignment: alignment, child: current);

    if (padding != null) current = Padding(padding: padding, child: current);

    if (decoration != null)
      current = DecoratedBox(decoration: decoration, child: current);

    if (foregroundDecoration != null) {
      current = DecoratedBox(
          decoration: foregroundDecoration,
          position: DecorationPosition.foreground,
          child: current);
    }

    if (constraints != null)
      current = ConstrainedBox(constraints: constraints, child: current);

    if (margin != null) current = Padding(padding: margin, child: current);

    if (transform != null)
      current = Transform(transform: transform, child: current);

    return current;
  }
}
