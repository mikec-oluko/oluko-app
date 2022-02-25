import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

const double _kPanelHeaderCollapsedHeight = 48.0;
const double _kPanelHeaderExpandedHeight = 64.0;
const EdgeInsets _kPanelHeaderExpandedDefaultPadding = EdgeInsets.symmetric(
  vertical: 64.0 - _kPanelHeaderCollapsedHeight,
);

class CustomExpansionPanelListRadio extends StatelessWidget {
  CustomExpansionPanelListRadio(
      {Key key,
      this.children = const <ExpansionPanelRadio>[],
      this.expansionCallback,
      this.animationDuration = kThemeAnimationDuration,
      this.initialOpenPanelValue,
      this.expandedHeaderPadding = _kPanelHeaderExpandedDefaultPadding,
      this.dividerColor,
      this.elevation = 2})
      : assert(children != null),
        assert(animationDuration != null),
        super(key: key);

  final List<ExpansionPanelRadio> children;
  final ExpansionPanelCallback expansionCallback;
  final Duration animationDuration;

  /// The value of the panel that initially begins open. (This value is
  /// only used when initializing with the [ExpansionPanelList.radio]
  /// constructor.)
  final Object initialOpenPanelValue;

  /// The padding that surrounds the panel header when expanded.
  ///
  /// By default, 16px of space is added to the header vertically (above and below)
  /// during expansion.
  final EdgeInsets expandedHeaderPadding;

  /// Defines color for the divider when [ExpansionPanel.isExpanded] is false.
  ///
  /// If `dividerColor` is null, then [DividerThemeData.color] is used. If that
  /// is null, then [ThemeData.dividerColor] is used.
  final Color dividerColor;

  /// Defines elevation for the [ExpansionPanel] while it's expanded.
  ///
  /// By default, the value of elevation is 2.
  final double elevation;

  bool _isChildExpanded(int index) {
    return children[index].isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    const EdgeInsets kExpandedEdgeInsets = const EdgeInsets.symmetric(vertical: _kPanelHeaderExpandedHeight - _kPanelHeaderCollapsedHeight);

    for (int index = 0; index < children.length; index += 1) {
      if (_isChildExpanded(index) && index != 0 && !_isChildExpanded(index - 1)) {
        items.add(
          Divider(
            key: _SaltedKey<BuildContext, int>(context, index * 2 - 1),
            height: 15.0,
            color: Colors.transparent,
          ),
        );
      }

      final Row header = Row(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.fastOutSlowIn,
              margin: _isChildExpanded(index) ? kExpandedEdgeInsets : EdgeInsets.zero,
              child: Container(
                child: children[index].headerBuilder(
                  context,
                  children[index].isExpanded,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(end: 8.0),
            child: ExpandIcon(
              color: OlukoColors.grayColor,
              isExpanded: _isChildExpanded(index),
              padding: const EdgeInsets.all(25.0),
              onPressed: (bool isExpanded) {
                if (expansionCallback != null) {
                  expansionCallback(index, !isExpanded);
                  //     //TODO: missing scroll controller to stick to index class
                  //     // for (var i = 0; i < children.length; i++) {
                  //     //   if (i != index) {
                  //     //     expansionCallback(i, false);
                  //     //   }
                  //     // }
                }
              },
            ),
          ),
        ],
      );

      double _radiusValue = 8.0;
      items.add(
        Container(
          key: _SaltedKey<BuildContext, int>(context, index * 2),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Material(
              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
              elevation: 2.0,
              borderRadius: BorderRadius.all(Radius.circular(_radiusValue)),
              child: Column(
                children: <Widget>[
                  header,
                  AnimatedCrossFade(
                    firstChild: Container(height: 0.0),
                    secondChild: children[index].body,
                    firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                    secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                    sizeCurve: Curves.fastOutSlowIn,
                    crossFadeState: _isChildExpanded(index) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: animationDuration,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (_isChildExpanded(index) && index != children.length - 1) {
        items.add(
          Divider(
            key: _SaltedKey<BuildContext, int>(context, index * 2 + 1),
            height: 15.0,
          ),
        );
      }
    }

    return Column(
      children: items,
    );
  }
}

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final dynamic typedOther = other;
    return salt == typedOther.salt && value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, salt, value);
}
