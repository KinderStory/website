import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class PrivacyScreen extends StatelessWidget {
  final String iframeId = 'iubenda-iframe';

  PrivacyScreen({super.key}) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      iframeId,
          (int viewId) => html.IFrameElement()
        ..src = 'https://www.iubenda.com/privacy-policy/10893086/legal'
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Datenschutzerklärung')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Datenschutzerklärung',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: HtmlElementView(viewType: 'iubenda-iframe'),
          ),
        ],
      ),
    );
  }
}
