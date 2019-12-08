package com.example.example;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import net.nfet.flutter.printing.PrintingPlugin;


public class MainActivity extends FlutterActivity {
  // TODO(<github-username>): Remove this once v2 of
  // GeneratedPluginRegistrant rolls to stable.
  // https://github.com/flutter/flutter/issues/42694
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new PrintingPlugin());
  }
}
