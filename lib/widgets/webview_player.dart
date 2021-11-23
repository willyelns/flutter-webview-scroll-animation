import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../utils.dart';

class WebViewPlayer extends StatelessWidget {
  const WebViewPlayer(
      {Key key, @required this.maxHeight, @required this.onScrollChanged})
      : super(key: key);

  final double maxHeight;
  final void Function(InAppWebViewController, int, int) onScrollChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          debugPrint('on notification dispatched: $notification');
          return true;
        },
        child: InAppWebView(
          onScrollChanged: onScrollChanged,
          initialUrl: kLinkUrl,
          onLoadStart: _onLoadStart,
          onLoadStop: _onLoadStop,
          gestureRecognizers: Set()
            ..add(
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            ),
        ),
      ),
    );
  }

  void _onLoadStart(InAppWebViewController controller, String url) {
    print('WebView - Page load Started : $url');
  }

  void _onLoadStop(InAppWebViewController controller, String url) {
    print('WebView - Page load stop : $url');
  }
}
