import 'package:flutter/material.dart';

class MaximizedCommentsSection extends StatelessWidget {
  const MaximizedCommentsSection({
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
