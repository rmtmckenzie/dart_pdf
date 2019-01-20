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
}
