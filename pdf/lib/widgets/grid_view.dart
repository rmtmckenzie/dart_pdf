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

class GridView extends MultiChildWidget {
  GridView(
      {this.direction = Axis.vertical,
      this.padding = EdgeInsets.zero,
      @required this.crossAxisCount,
      this.mainAxisSpacing = 0.0,
      this.crossAxisSpacing = 0.0,
      this.childAspectRatio = double.infinity,
      List<Widget> children = const []})
      : assert(padding != null),
        super(children: children);

  final Axis direction;
  final EdgeInsets padding;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    double mainAxisExtent;
    double crossAxisExtent;
    switch (direction) {
      case Axis.vertical:
        mainAxisExtent = constraints.maxHeight - padding.vertical;
        crossAxisExtent = constraints.maxWidth - padding.horizontal;
        break;
      case Axis.horizontal:
        mainAxisExtent = constraints.maxWidth - padding.horizontal;
        crossAxisExtent = constraints.maxHeight - padding.vertical;
        break;
    }

    final mainAxisCount = (children.length / crossAxisCount).ceil();
    final childCrossAxis = crossAxisExtent / crossAxisCount -
        (crossAxisSpacing * (crossAxisCount - 1) / crossAxisCount);
    final childMainAxis = math.min(
        childCrossAxis * childAspectRatio,
        mainAxisExtent / mainAxisCount -
            (mainAxisSpacing * (mainAxisCount - 1) / mainAxisCount));
    final totalMain =
        (childMainAxis + mainAxisSpacing) * mainAxisCount - mainAxisSpacing;
    final totalCross =
        (childCrossAxis + crossAxisSpacing) * crossAxisCount - crossAxisSpacing;

    var startX = padding.left;
    var startY = 0.0;
    var mainAxis;
    var crossAxis;
    BoxConstraints innerConstraints;
    switch (direction) {
      case Axis.vertical:
        innerConstraints = BoxConstraints.tightFor(
            width: childCrossAxis, height: childMainAxis);
        crossAxis = startX;
        mainAxis = startY;
        break;
      case Axis.horizontal:
        innerConstraints = BoxConstraints.tightFor(
            width: childMainAxis, height: childCrossAxis);
        mainAxis = startX;
        crossAxis = startY;
        break;
    }

    var c = 0;
    for (var child in children) {
      child.layout(context, innerConstraints);

      switch (direction) {
        case Axis.vertical:
          child.box = PdfRect.fromPoints(
              PdfPoint(
                  (childCrossAxis - child.box.w) / 2.0 + crossAxis,
                  totalMain +
                      padding.bottom -
                      (childMainAxis - child.box.h) / 2.0 -
                      mainAxis -
                      child.box.h),
              child.box.size);
          break;
        case Axis.horizontal:
          child.box = PdfRect.fromPoints(
              PdfPoint(
                  (childMainAxis - child.box.w) / 2.0 + mainAxis,
                  totalCross +
                      padding.bottom -
                      (childCrossAxis - child.box.h) / 2.0 -
                      crossAxis -
                      child.box.h),
              child.box.size);
          break;
      }

      if (++c >= crossAxisCount) {
        mainAxis += childMainAxis + mainAxisSpacing;
        crossAxis = startX;
        c = 0;
      } else {
        crossAxis += childCrossAxis + crossAxisSpacing;
      }
    }

    switch (direction) {
      case Axis.vertical:
        box = constraints.constrainRect(
            width: totalCross + padding.horizontal,
            height: totalMain + padding.vertical);
        break;
      case Axis.horizontal:
        box = constraints.constrainRect(
            width: totalMain + padding.horizontal,
            height: totalCross + padding.vertical);
        break;
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
    super.paint(context);

    final mat = Matrix4.identity();
    mat.translate(box.x, box.y);
    context.canvas
      ..saveContext()
      ..setTransform(mat);
    for (var child in children) {
      child.paint(context);
    }
    context.canvas.restoreContext();
  }
}
