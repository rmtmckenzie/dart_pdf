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

abstract class BasePage {
  final PdfPageFormat pageFormat;

  BasePage({this.pageFormat}) : assert(pageFormat != null);

  @protected
  void build(Document document);
}

class Document {
  static var debug = false;

  final PdfDocument document;

  TextStyle _defaultTextStyle;

  TextStyle get defaultTextStyle {
    if (_defaultTextStyle == null) {
      _defaultTextStyle =
          TextStyle(color: PdfColor.black, font: PdfFont.helvetica(document));
    }
    return _defaultTextStyle;
  }

  Document({PdfPageMode pageMode = PdfPageMode.none, DeflateCallback deflate})
      : document = PdfDocument(pageMode: pageMode, deflate: deflate);

  void addPage(BasePage page) {
    page.build(this);
  }
}

class Page extends BasePage {
  final EdgeInsets margin;
  final Widget child;

  Page(
      {PdfPageFormat pageFormat = PdfPageFormat.a4,
      this.child,
      EdgeInsets margin})
      : margin = margin ??
            EdgeInsets.fromLTRB(pageFormat.marginLeft, pageFormat.marginTop,
                pageFormat.marginRight, pageFormat.marginBottom),
        super(pageFormat: pageFormat);

  void debugPaint(Context context) {
    context.canvas
      ..setColor(PdfColor.lightGreen)
      ..moveTo(0.0, 0.0)
      ..lineTo(pageFormat.width, 0.0)
      ..lineTo(pageFormat.width, pageFormat.height)
      ..lineTo(0.0, pageFormat.height)
      ..moveTo(margin.left, margin.bottom)
      ..lineTo(margin.left, pageFormat.height - margin.top)
      ..lineTo(pageFormat.width - margin.right, pageFormat.height - margin.top)
      ..lineTo(pageFormat.width - margin.right, margin.bottom)
      ..fillPath();
  }

  @override
  void build(Document document) {
    final pdfPage = PdfPage(document.document, pageFormat: pageFormat);
    final canvas = pdfPage.getGraphics();
    final constraints = BoxConstraints(
        maxWidth: pageFormat.width, maxHeight: pageFormat.height);

    final context = Context(pdfPage, document.defaultTextStyle, canvas);
    _layout(context, constraints);
    _paint(context);
  }

  void _layout(Context context, BoxConstraints constraints,
      {parentUsesSize = false}) {
    if (child != null) {
      final childConstraints = BoxConstraints(
          minWidth: constraints.minWidth,
          minHeight: constraints.minHeight,
          maxWidth: constraints.hasBoundedWidth
              ? constraints.maxWidth - margin.horizontal
              : margin.horizontal,
          maxHeight: constraints.hasBoundedHeight
              ? constraints.maxHeight - margin.vertical
              : margin.vertical);
      child.layout(context, childConstraints, parentUsesSize: parentUsesSize);
      child.box = PdfRect(
          margin.left,
          pageFormat.height - child.box.h - margin.top,
          child.box.w,
          child.box.h);
    }
  }

  void _paint(Context context) {
    if (Document.debug) debugPaint(context);

    if (child != null) {
      child.paint(context);
    }
  }
}

typedef Widget BuildCallback(Context context);

class MultiPage extends Page {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final BuildCallback header;
  final BuildCallback footer;

  MultiPage(
      {PdfPageFormat pageFormat = PdfPageFormat.a4,
      this.children,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.header,
      this.footer,
      EdgeInsets margin})
      : super(pageFormat: pageFormat, margin: margin);

  @override
  void build(Document document) {
    final constraints = BoxConstraints(
        maxWidth: pageFormat.width, maxHeight: pageFormat.height);
    final childConstraints =
        BoxConstraints(maxWidth: constraints.maxWidth - margin.horizontal);
    Context context;
    double offsetEnd;
    double offsetStart;
    var index = 0;

    while (index < children.length) {
      final child = children[index];

      if (context == null) {
        final pdfPage = PdfPage(document.document, pageFormat: pageFormat);
        final canvas = pdfPage.getGraphics();
        context = Context(pdfPage, document.defaultTextStyle, canvas);
        if (Document.debug) debugPaint(context);
        offsetStart = pageFormat.height - margin.top;
        offsetEnd = margin.bottom;
        if (header != null) {
          final headerWidget = header(context);
          if (headerWidget != null) {
            headerWidget.layout(context, childConstraints,
                parentUsesSize: false);
            headerWidget.box = PdfRect(
                margin.left,
                offsetStart - headerWidget.box.h,
                headerWidget.box.w,
                headerWidget.box.h);
            headerWidget.paint(context);
            offsetStart -= headerWidget.box.h;
          }
        }

        if (footer != null) {
          final footerWidget = footer(context);
          if (footerWidget != null) {
            footerWidget.layout(context, childConstraints,
                parentUsesSize: false);
            footerWidget.box = PdfRect(margin.left, margin.bottom,
                footerWidget.box.w, footerWidget.box.h);
            footerWidget.paint(context);
            offsetEnd += footerWidget.box.h;
          }
        }
      }

      child.layout(context, childConstraints, parentUsesSize: false);

      if (offsetStart - child.box.h < offsetEnd) {
        context = null;
        continue;
      }

      child.box = PdfRect(
          margin.left, offsetStart - child.box.h, child.box.w, child.box.h);
      child.paint(context);
      offsetStart -= child.box.h;
      index++;
    }
  }
}
