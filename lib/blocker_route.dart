import 'package:flutter/material.dart';

import 'package:house_helper/block.dart';
import 'package:house_helper/util/network.dart';

final _backgroundColor = Colors.blue[10];

class BlockerRoute extends StatefulWidget {
  const BlockerRoute();

  @override
  BlockerRouteState createState() => BlockerRouteState();
}

class BlockerRouteState extends State<BlockerRoute> {
  final blocks = <Block>[];
  static final network = Network();

  static const _actions = <String>[
    'block',
    'unblock',
  ];

  static final _test = <Function>[
    () => network.blockUsers(),
    () => network.unblockUsers(),
  ];

  @override
  void initState() {
    super.initState();
    for(var i = 0; i < _actions.length; i++) {
      blocks.add(Block(
        action_name: _actions[i],
        action: _test[i],
        )
      );
    }
  }

  final appBar = AppBar(
    elevation: 0.0,
    title: Text(
      'Internet Blocker',
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: _backgroundColor,
  );

  Widget _buildButtons(List<Block> actions) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) => blocks[index],
      itemCount: actions.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listView = Container(
      color: _backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: _buildButtons(blocks),
    );

    return Scaffold(
      appBar: appBar,
      body: listView,
    );
  }
}