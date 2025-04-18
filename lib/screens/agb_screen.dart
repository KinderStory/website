import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class AgbScreen extends StatelessWidget {
  final String viewType = 'iubenda-agb';

  AgbScreen({super.key}) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewType,
          (int viewId) {
        final container = html.DivElement();

        container.setInnerHtml('''
<a href="https://www.iubenda.com/terms-and-conditions/10893086" class="iubenda-white iubenda-noiframe iubenda-embed iubenda-noiframe" title="Allgemeine Geschäftsbedingungen">AGB</a>
<script type="text/javascript">
(function (w,d) {
  var loader = function () {
    var s = d.createElement("script"), tag = d.getElementsByTagName("script")[0];
    s.src="https://cdn.iubenda.com/iubenda.js";
    tag.parentNode.insertBefore(s,tag);
  };
  if(w.addEventListener){w.addEventListener("load", loader, false);}
  else if(w.attachEvent){w.attachEvent("onload", loader);}
  else{w.onload = loader;}
})(window, document);
</script>
        ''', treeSanitizer: html.NodeTreeSanitizer.trusted);

        return container;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('AGB')),
      body: Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Allgemeine Geschäftsbedingungen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: HtmlElementView(viewType: 'iubenda-agb'),
          ),
        ],
      ),
    );
  }
}
