import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController scrollController;
  final PanelController panelController;
  final List<Widget> contentForPanel;
  const PanelWidget(
      {this.scrollController, this.panelController, this.contentForPanel});

  @override
  _PanelWidgetState createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        clipBehavior: Clip.none,
        shrinkWrap: true,
        children: widget.contentForPanel,
      ),
    );
  }
}
