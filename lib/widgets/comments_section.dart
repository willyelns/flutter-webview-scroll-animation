import 'package:flutter/material.dart';

import '../utils.dart';
import 'maximized_comments_section.dart';
import 'minimized_comments_section.dart';

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
            ? MaximizedCommentsSection(
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
