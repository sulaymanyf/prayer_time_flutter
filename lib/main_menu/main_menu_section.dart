import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/main_menu/menu_data.dart';
import "package:flare_flutter/flare_actor.dart" as flare;
import 'package:flutter_app/main_menu/menu_vignette.dart';

typedef NavigateTo(MenuItemData item);

/// This widget displays the single menu section of the [MainMenuWidget].
///
/// There are three main sections, as loaded from the menu.json file in the
/// assets folder.
/// Each section has a backgroundColor, an accentColor, a background Flare asset,
/// and a list of elements it needs to display when expanded.
///
/// Since this widget expands and contracts when tapped, it needs to maintain a [State].
class MenuSection extends StatefulWidget {
  final String title;
  final String name;
  final String time;
  final Color backgroundColor;
  final Color accentColor;
  final List<MenuItemData> menuOptions;
  final String assetId;
  final NavigateTo navigateTo;
  final bool isActive;

  MenuSection(this.title, this.name, this.time, this.backgroundColor, this.accentColor,
      this.menuOptions, this.navigateTo, this.isActive,
      {this.assetId, Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SectionState();
}

/// This [State] uses the [SingleTickerProviderStateMixin] to add [vsync] to it.
/// This allows the animation to run smoothly and avoids consuming unnecessary resources.
class _SectionState extends State<MenuSection>
    with SingleTickerProviderStateMixin {
  /// The [AnimationController] is a Flutter Animation object that generates a new value
  /// whenever the hardware is ready to draw a new frame.
  AnimationController _controller;

  /// Since the above object interpolates only between 0 and 1, but we'd rather apply a curve to the current
  /// animation, we're providing a custom [Tween] that allows to build more advanced animations, as seen in [initState()].
  static final Animatable<double> _sizeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );

  /// The [Animation] object itself, which is required by the [SizeTransition] widget in the [build()] method.
  Animation<double> _sizeAnimation;

  /// Detects which state the widget is currently in, and triggers the animation upon change.
  bool _isExpanded = false;
  double  height;

  /// Here we initialize the fields described above, and set up the widget to its initial state.
  @override
  initState() {
    super.initState();
    height = (window.physicalSize.height-120)/20;
    print(height);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// This curve is controlled by [_controller].
    final CurvedAnimation curve =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    /// [_sizeAnimation] will interpolate using this curve - [Curves.fastOutSlowIn].
    _sizeAnimation = _sizeTween.animate(curve);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Whenever a tap is detected, toggle a change in the state and move the animation forward
  /// or backwards depending on the initial status.
  _toggleExpand() {
    setState(() {
      print("---------------");
      _isExpanded = !_isExpanded;
    });
    switch (_sizeAnimation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }

  /// This method wraps the whole widget in a [GestureDetector] to handle taps appropriately.
  ///
  /// A custom [BoxDecoration] is used to render the rounded rectangle on the screen, and a
  /// [MenuVignette] is used as a background decoration for the whole widget.
  ///
  /// The [SizeTransition] opens up the section and displays the list underneath the section title.
  ///
  /// Each section sub-element is wrapped into a [GestureDetector] too so that the Timeline can be displayed
  /// when that element is tapped.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _toggleExpand,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: widget.backgroundColor
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Stack(
                  children: <Widget>[
//                    Positioned.fill(
//                        left: 0,
//                        top: 0,
//                        child: MenuVignette(
//                            gradientColor: widget.backgroundColor,
//                            isActive: widget.isActive,
//                            assetId: widget.assetId
//                        )),
                    Column(

                      children: <Widget>[
                      Container(

                          height: this.height,
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
//                              Container(
//                                height: 40.0,
//                                width: 20.0,
//                                margin: EdgeInsets.all(2.0),
//
//                                /// Another [FlareActor] widget that
//                                /// you can experiment with here: https://www.2dimensions.com/a/pollux/files/flare/expandcollapse/preview
//                                child: flare.FlareActor(
//                                    widget.title,
//                                    color: widget.accentColor,
//                                    animation:
//                                    _isExpanded ? "Collapse" : "Expand"),
//                              ),
                              Container(
                                width: 180.0,
                                height: 50,
                                child:  Text(
                                  widget.time,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 43.0,
                                      fontFamily: "RobotoMedium",
                                      color: Colors.white),
                                ),
                              ),
                              Container(
                                padding:new EdgeInsets.fromLTRB(0,0,0.1,6),
                                width: 90.0,
                                child: Text(
                                  widget.name,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: "RobotoMedium",
                                      color: widget.accentColor),
                                ),
                              ),

                            ],
                          )),
                      SizeTransition(
                          axisAlignment: 0.0,
                          axis: Axis.vertical,
                          sizeFactor: _sizeAnimation,
                          child: Container(
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 56.0, right: 20.0, top: 10.0),
                                  child: Column(
                                      children: widget.menuOptions.map((item) {
                                    return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => widget.navigateTo(item),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 20.0),
                                                      child: Text(
                                                        item.label,
                                                        style: TextStyle(
                                                            color: widget
                                                                .accentColor,
                                                            fontSize: 20.0,
                                                            fontFamily:
                                                                "RobotoMedium"),
                                                      ))),
                                              Container(
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                      "assets/right_arrow.png",
                                                      color: widget.accentColor,
                                                      height: 22.0,
                                                      width: 22.0))
                                            ]));
                                  }).toList()))))
                    ]),
                  ],
                ))));
  }
}
