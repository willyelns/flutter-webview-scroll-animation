import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:scorm_player/utils.dart';

import 'widgets/comments_section.dart';
import 'widgets/webview_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key key}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();

  Offset _scrollOffeset;
  bool _showComments = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, _) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
            )
          ];
        },
        body: LayoutBuilder(builder: (context, constraints) {
          final biggestSize = constraints.biggest;
          final maxHeight = biggestSize.height;
          return Stack(
            children: [
              WebViewPlayer(
                onScrollChanged: _onScrollChanged,
                maxHeight: maxHeight,
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: CommentsSection(
                  showComments: _showComments,
                  maxHeight: maxHeight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _onScrollChanged(InAppWebViewController controller, int dx, int dy) {
    if (_scrollOffeset == null) {
      _scrollOffeset = Offset(dx.toDouble(), dy.toDouble());
    }
    if (dy <= 0) {
      _animateToMin();
      _updateShowComments(true);
    }
    final currentDy = _scrollOffeset.dy + 50;
    if (currentDy < dy) {
      _animateToMax();
      _updateShowComments(false);
      _scrollOffeset = Offset(dx.toDouble(), dy.toDouble());
    }
    if (_scrollOffeset.dy > dy) {
      _animateToMin();
      _updateShowComments(true);
      _scrollOffeset = Offset(dx.toDouble(), dy.toDouble());
    }
  }

  void _updateShowComments(bool show) {
    if (_showComments != show) {
      setState(() => _showComments = show);
    }
  }

  void _animateToMin() {
    final scrollPosition = _scrollController.position;
    _scrollAnimation(scrollPosition.minScrollExtent);
  }

  void _animateToMax() {
    final scrollPosition = _scrollController.position;
    _scrollAnimation(scrollPosition.maxScrollExtent);
  }

  void _scrollAnimation(double to) {
    _scrollController.animateTo(
      to,
      duration: Duration(milliseconds: kAnimationDuration),
      curve: Curves.ease,
    );
  }
}
