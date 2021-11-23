import 'package:flutter/material.dart';

import '../utils.dart';

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
