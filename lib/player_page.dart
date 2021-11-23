import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:scorm_player/utils.dart';

const int kAnimationDuration = 300;
const double kBottomCommentBarHeight = 80.0;

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

class CommentsSection extends StatefulWidget {
  const CommentsSection({
    @required this.showComments,
    @required this.maxHeight,
    Key key,
  }) : super(key: key);
  final bool showComments;
  final double maxHeight;

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection>
    with SingleTickerProviderStateMixin {
  Animation<double> _showCommentsAnimation;
  AnimationController _showCommentsAnimationController;

  @override
  void initState() {
    super.initState();
    _showCommentsAnimationSetup();
  }

  void _showCommentsAnimationSetup() {
    _showCommentsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: kAnimationDuration),
    )..forward();
    _showCommentsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _showCommentsAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _showCommentsAnimationController.dispose();
    super.dispose();
  }

  @override
  didUpdateWidget(CommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAnimationStatus();
  }

  void _checkAnimationStatus() {
    if (!_showCommentsAnimationController.isAnimating) {
      if (widget.showComments) {
        _showCommentsAnimationController.forward();
      } else {
        _showCommentsAnimationController.reverse();
      }
    }
  }

  bool _isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _showCommentsAnimation,
      alignment: Alignment.bottomCenter,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: kAnimationDuration),
        switchInCurve: Curves.decelerate,
        switchOutCurve: Curves.fastOutSlowIn,
        transitionBuilder: (child, animation) =>
            SizeTransition(child: child, sizeFactor: animation),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _isFullScreen
            ? MaximazedCommentsSection(
                maxHeight: widget.maxHeight,
                onTap: _updateFullScreenState,
              )
            : MinimizedCommentsSection(
                onTap: _updateFullScreenState,
              ),
      ),
    );
  }

  void _updateFullScreenState() {
    setState(() => _isFullScreen = !_isFullScreen);
  }
}

class MinimizedCommentsSection extends StatelessWidget {
  const MinimizedCommentsSection({
    Key key,
    @required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: ValueKey('min'),
        color: Colors.white,
        width: size.width,
        height: kBottomCommentBarHeight,
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ver comentários',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            RotatedBox(
              quarterTurns: 45,
              child: Icon(Icons.chevron_left_sharp, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class MaximazedCommentsSection extends StatelessWidget {
  const MaximazedCommentsSection({
    Key key,
    @required this.maxHeight,
    @required this.onTap,
  }) : super(key: key);

  final double maxHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    return Container(
      key: ValueKey('max'),
      color: Colors.white,
      width: size.width,
      height: maxHeight,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comentários',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                  ),
                ),
                RotatedBox(
                  quarterTurns: -45,
                  child: Icon(Icons.chevron_left_sharp, size: 32),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.purpleAccent,
                  ),
                  height: 150,
                  width: size.width,
                  margin: const EdgeInsets.all(8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
