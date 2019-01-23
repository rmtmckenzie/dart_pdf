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

/// A horizontal group of cells in a [Table].
@immutable
class TableRow {
  const TableRow({this.decoration, this.children});

  /// A decoration to paint behind this row.
  final BoxDecoration decoration;

  /// The widgets that comprise the cells in this row.
  final List<Widget> children;
}

/// A widget that uses the table layout algorithm for its children.
class Table extends Widget {
  Table({
    this.children = const <TableRow>[],
    this.decoration,
  })  : assert(children != null),
        super();

  /// The rows of the table.
  final List<TableRow> children;

  /// The style to use when painting the boundary and interior divisions of the table.
  final BoxDecoration decoration;

  final crossAxisAlignment = CrossAxisAlignment.stretch;

  @override
  void layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    // First pass
    //    Calculate required width for all row/columns
    //    Calculate width flex
    final flex = List<double>();
    final widths = List<double>();
    for (var row in children) {
      var n = 0;
      var width = 0.0;
      for (var child in row.children) {
        child.layout(context, BoxConstraints());
        final calculatedWidth =
            child.box.w == double.infinity ? 0.0 : child.box.w;
        width += calculatedWidth;
        final childFlex = child._flex.toDouble();
        if (flex.length < n + 1) {
          flex.add(childFlex);
          widths.add(calculatedWidth);
        } else {
          if (childFlex > 0) {
            flex[n] *= childFlex;
          }
          widths[n] = math.max(widths[n], calculatedWidth);
        }
        n++;
      }
    }

    final maxWidth = widths.reduce((a, b) => a + b);

    print(flex);
    print(widths);
    print(maxWidth);

    // Second pass
    //    Calculate column widths using flex and estimated width
    if (constraints.hasBoundedWidth) {
      var flexSpace = 0.0;
      for (var n = 0; n < widths.length; n++) {
        if (flex[n] == 0.0) {
          var newWidth = widths[n] / maxWidth * constraints.maxWidth;
          if (newWidth < widths[n]) {
            widths[n] = newWidth;
          }
          flexSpace += widths[n];
        }
      }
      final totalFlex = flex.reduce((a, b) => a + b);
      final spacePerFlex = totalFlex > 0.0
          ? ((constraints.maxWidth - flexSpace) / totalFlex)
          : double.nan;
      print(
          "totalFlex:$totalFlex flexSpace:$flexSpace spacePerFlex:$spacePerFlex total:${constraints.maxWidth}");

      for (var n = 0; n < widths.length; n++) {
        if (flex[n] > 0.0) {
          var newWidth = spacePerFlex * flex[n];

          ;
          print("n:$n newWidth:$newWidth flex:${flex[n]}");
          widths[n] = newWidth;
        }
      }
    }
    print(widths);
    final totalWidth = widths.reduce((a, b) => a + b);
    print("totalWidth:$totalWidth");

    // Third pass calculate final widths
    var totalHeight = 0.0;
    for (var row in children) {
      var n = 0;
      var x = 0.0;

      var lineHeight = 0.0;
      for (var child in row.children) {
        final childConstraints = BoxConstraints.tightFor(width: widths[n]);
        child.layout(context, childConstraints);
        child.box = PdfRect(x, totalHeight, child.box.w, child.box.h);
        x += widths[n];
        lineHeight = math.max(lineHeight, child.box.h);
        print(child.box);
        n++;
      }
      totalHeight += lineHeight;
    }

    // Fourth pass calculate final y position
    for (var row in children) {
      for (var child in row.children) {
        child.box = PdfRect(child.box.x,
            totalHeight - child.box.y - child.box.h, child.box.w, child.box.h);
      }
    }

    box = PdfRect(0.0, 0.0, totalWidth, totalHeight);
    print(box);
  }

  @override
  void paint(Context context) {
    if (decoration != null) {
      decoration.paintBackground(context, box);
    } else {
      super.paint(context);
    }

    final mat = Matrix4.identity();
    mat.translate(box.x, box.y);
    context.canvas
      ..saveContext()
      ..setTransform(mat);
    for (var row in children) {
      for (var child in row.children) {
        child.paint(context);
      }
    }
    context.canvas.restoreContext();

    if (decoration != null) {
      decoration.paintBorders(context, box);
    }
  }
}
