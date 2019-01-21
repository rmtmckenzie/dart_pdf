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
class BoxConstraints {
  /// The minimum width that satisfies the constraints.
  final double minWidth;

  /// The maximum width that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxWidth;

  /// The minimum height that satisfies the constraints.
  final double minHeight;

  /// The maximum height that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxHeight;

  /// Creates box constraints with the given constraints.
  const BoxConstraints(
      {this.minWidth = 0.0,
      this.maxWidth = double.infinity,
      this.minHeight = 0.0,
      this.maxHeight = double.infinity});

  bool get hasBoundedWidth => maxWidth < double.infinity;

  bool get hasBoundedHeight => maxHeight < double.infinity;

  bool get hasInfiniteWidth => minWidth >= double.infinity;

  bool get hasInfiniteHeight => minHeight >= double.infinity;

  /// Whether there is exactly one width value that satisfies the constraints.
  bool get hasTightWidth => minWidth >= maxWidth;

  /// Whether there is exactly one height value that satisfies the constraints.
  bool get hasTightHeight => minHeight >= maxHeight;

  /// Whether there is exactly one size that satisfies the constraints.
  bool get isTight => hasTightWidth && hasTightHeight;

  PdfPoint constrain(PdfPoint size) {
    final result = PdfPoint(constrainWidth(size.x), constrainHeight(size.y));
    return result;
  }

  double constrainWidth([double width = double.infinity]) {
    return width.clamp(minWidth, maxWidth);
  }

  double constrainHeight([double height = double.infinity]) {
    return height.clamp(minHeight, maxHeight);
  }

  /// Returns new box constraints with a tight width and/or height as close to
  /// the given width and height as possible while still respecting the original
  /// box constraints.
  BoxConstraints tighten({double width, double height}) {
    return BoxConstraints(
        minWidth: width == null ? minWidth : width.clamp(minWidth, maxWidth),
        maxWidth: width == null ? maxWidth : width.clamp(minWidth, maxWidth),
        minHeight:
            height == null ? minHeight : height.clamp(minHeight, maxHeight),
        maxHeight:
            height == null ? maxHeight : height.clamp(minHeight, maxHeight));
  }

  /// Creates box constraints that require the given width or height.
  const BoxConstraints.tightFor({double width, double height})
      : minWidth = width != null ? width : 0.0,
        maxWidth = width != null ? width : double.infinity,
        minHeight = height != null ? height : 0.0,
        maxHeight = height != null ? height : double.infinity;

  /// Creates box constraints that expand to fill another box constraints.
  const BoxConstraints.expand({double width, double height})
      : minWidth = width != null ? width : double.infinity,
        maxWidth = width != null ? width : double.infinity,
        minHeight = height != null ? height : double.infinity,
        maxHeight = height != null ? height : double.infinity;

  /// Returns new box constraints that are smaller by the given edge dimensions.
  BoxConstraints deflate(EdgeInsets edges) {
    assert(edges != null);
    final double horizontal = edges.horizontal;
    final double vertical = edges.vertical;
    final double deflatedMinWidth = math.max(0.0, minWidth - horizontal);
    final double deflatedMinHeight = math.max(0.0, minHeight - vertical);
    return BoxConstraints(
        minWidth: deflatedMinWidth,
        maxWidth: math.max(deflatedMinWidth, maxWidth - horizontal),
        minHeight: deflatedMinHeight,
        maxHeight: math.max(deflatedMinHeight, maxHeight - vertical));
  }

  /// Returns new box constraints that remove the minimum width and height requirements.
  BoxConstraints loosen() {
    return BoxConstraints(
        minWidth: 0.0,
        maxWidth: maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
  }

  /// Returns new box constraints that respect the given constraints while being
  /// as close as possible to the original constraints.
  BoxConstraints enforce(BoxConstraints constraints) {
    return BoxConstraints(
        minWidth: minWidth.clamp(constraints.minWidth, constraints.maxWidth),
        maxWidth: maxWidth.clamp(constraints.minWidth, constraints.maxWidth),
        minHeight:
            minHeight.clamp(constraints.minHeight, constraints.maxHeight),
        maxHeight:
            maxHeight.clamp(constraints.minHeight, constraints.maxHeight));
  }

  @override
  String toString() {
    return "BoxConstraint <$minWidth, $maxWidth> <$minHeight, $maxHeight>";
  }
}

@immutable
class EdgeInsets {
  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom);

  const EdgeInsets.all(double value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const EdgeInsets.only(
      {this.left = 0.0, this.top = 0.0, this.right = 0.0, this.bottom = 0.0});

  const EdgeInsets.symmetric({double vertical = 0.0, double horizontal = 0.0})
      : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  static const EdgeInsets zero = EdgeInsets.only();

  final double left;

  final double top;

  final double right;

  final double bottom;

  /// The total offset in the horizontal direction.
  double get horizontal => left + right;

  /// The total offset in the vertical direction.
  double get vertical => top + bottom;

  EdgeInsets copyWith({
    double left,
    double top,
    double right,
    double bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }

  /// Returns the sum of two [EdgeInsets] objects.
  EdgeInsets add(EdgeInsets other) {
    return EdgeInsets.fromLTRB(
      left + other.left,
      top + other.top,
      right + other.right,
      bottom + other.bottom,
    );
  }
}

class Alignment {
  const Alignment(this.x, this.y)
      : assert(x != null),
        assert(y != null);

  /// The distance fraction in the horizontal direction.
  final double x;

  /// The distance fraction in the vertical direction.
  final double y;

  /// The top left corner.
  static const Alignment topLeft = Alignment(-1.0, 1.0);

  /// The center point along the top edge.
  static const Alignment topCenter = Alignment(0.0, 1.0);

  /// The top right corner.
  static const Alignment topRight = Alignment(1.0, 1.0);

  /// The center point along the left edge.
  static const Alignment centerLeft = Alignment(-1.0, 0.0);

  /// The center point, both horizontally and vertically.
  static const Alignment center = Alignment(0.0, 0.0);

  /// The center point along the right edge.
  static const Alignment centerRight = Alignment(1.0, 0.0);

  /// The bottom left corner.
  static const Alignment bottomLeft = Alignment(-1.0, -1.0);

  /// The center point along the bottom edge.
  static const Alignment bottomCenter = Alignment(0.0, -1.0);

  /// The bottom right corner.
  static const Alignment bottomRight = Alignment(1.0, -1.0);

  /// Returns the offset that is this fraction within the given size.
  PdfPoint alongSize(PdfPoint other) {
    final double centerX = other.x / 2.0;
    final double centerY = other.y / 2.0;
    return PdfPoint(centerX + x * centerX, centerY + y * centerY);
  }

  /// Returns the point that is this fraction within the given rect.
  PdfPoint withinRect(PdfRect rect) {
    final double halfWidth = rect.w / 2.0;
    final double halfHeight = rect.h / 2.0;
    return PdfPoint(
      rect.l + halfWidth + x * halfWidth,
      rect.t + halfHeight + y * halfHeight,
    );
  }

  /// Returns a rect of the given size, aligned within given rect as specified
  /// by this alignment.
  PdfRect inscribe(PdfPoint size, PdfRect rect) {
    final double halfWidthDelta = (rect.w - size.x) / 2.0;
    final double halfHeightDelta = (rect.h - size.y) / 2.0;
    return PdfRect(
      rect.x + halfWidthDelta + x * halfWidthDelta,
      rect.y + halfHeightDelta + y * halfHeightDelta,
      size.x,
      size.y,
    );
  }

  @override
  String toString() => "($x, $y)";
}
