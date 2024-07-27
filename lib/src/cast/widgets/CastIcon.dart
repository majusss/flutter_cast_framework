import 'dart:async';

import 'package:flutter/material.dart';

import '../../flutter_cast_framework.dart';
import '../CastContext.dart';

const Color _defaultIconColor = Color.fromARGB(255, 255, 255, 255); // white
const Color _disabledIconColor = Color.fromARGB(255, 201, 201, 201); // gray

class CastIcon extends StatefulWidget {
  final Color color;
  final Color disabledColor;
  final FlutterCastFramework castFramework;

  CastIcon({
    required this.castFramework,
    this.color = _defaultIconColor,
    this.disabledColor = _disabledIconColor,
  });

  @override
  _CastIconState createState() => _CastIconState();
}

Widget _getButton(IconData icon, Color color) {
  return Icon(
    icon,
    color: color,
  );
}

class _CastIconState extends State<CastIcon> with TickerProviderStateMixin {
  late CastState _castState;
  CastState get castState => _castState;

  @override
  void initState() {
    super.initState();
    var castContext = widget.castFramework.castContext;

    _castState = castContext.state.value;
    castContext.state.addListener(_onCastStateChanged);
  }

  void _onCastStateChanged() {
    if (!mounted) return;

    setState(() {
      if (!mounted) return;
      _castState = widget.castFramework.castContext.state.value;
    });
  }

  Widget _getAnimatedButton() => _ConnectingIcon(color: widget.color);

  @override
  Widget build(BuildContext context) {
    switch (_castState) {
      case CastState.unavailable:
        return _getButton(Icons.cast, widget.disabledColor);

      case CastState.unconnected:
        return _getButton(Icons.cast, widget.color);

      case CastState.connecting:
        return _getAnimatedButton();

      case CastState.connected:
        return _getButton(Icons.cast_connected, widget.color);

      case CastState.idle:
      default:
        debugPrint("State not handled: $_castState");
        return _getButton(Icons.cast, widget.disabledColor);
    }
  }
}

class _ConnectingIcon extends StatefulWidget {
  final Color color;

  _ConnectingIcon({required this.color});

  @override
  _ConnectingIconState createState() => _ConnectingIconState();
}

class _ConnectingIconState extends State<_ConnectingIcon> {
  static final List<IconData> _connectingAnimationFrames = [
    Icons.cast,
    Icons.cast_connected
  ];

  IconData _currentIcon = _connectingAnimationFrames[0];

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      const Duration(milliseconds: 400),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _currentIcon = _currentIcon == _connectingAnimationFrames[0]
              ? _connectingAnimationFrames[1]
              : _connectingAnimationFrames[0];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getButton(_currentIcon, widget.color);
  }
}
