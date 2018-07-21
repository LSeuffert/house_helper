import 'package:flutter/material.dart';

final _rowHeight = 64.0;
final _highlightColor = Colors.amberAccent;

class Block extends StatelessWidget {
  final String action_name;
  final Function action;

  const Block({
    Key key,
    @required this.action_name,
    @required this.action,
  }) : assert(action_name != null),
       assert(action != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
          highlightColor: _highlightColor,
          splashColor: _highlightColor,
          onTap: action,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    action_name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}