import 'package:flutter/material.dart';

import '../../flutter_cast_framework.dart';
import '../CastContext.dart';

const Color _defaultIconColor = Color.fromARGB(255, 255, 255, 255); // white
const Color _disabledIconColor = Color.fromARGB(255, 201, 201, 201); // gray

class CastIcon extends StatefulWidget {
  final Color color;
  final FlutterCastFramework castFramework;

  CastIcon({
    required this.castFramework,
    this.color = _defaultIconColor,
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
        return _getButton(Icons.cast, _disabledIconColor);

      case CastState.unconnected:
        return _getButton(Icons.cast, widget.color);

      case CastState.connecting:
        return _getAnimatedButton();

      case CastState.connected:
        return _getButton(Icons.cast_connected, widget.color);

      case CastState.idle:
      default:
        debugPrint("State not handled: $_castState");
        return _getButton(Icons.cast, _disabledIconColor);
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

  int _frameIndex = 0;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  _start() {
    if (!this.mounted) return;

    setState(() {
      if (!mounted) return;
      _frameIndex = 0;
      isAnimating = true;
    });
  }

  _nextFrame() async {
    if (!mounted) return;

    if (_frameIndex < _connectingAnimationFrames.length - 1) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          if (!mounted) return;
          _frameIndex += 1;
        });
      }
    } else {
      // When I reach the end, I re-start from the beginning
      await Future.delayed(const Duration(seconds: 1));
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAnimating) {
      _nextFrame();
    }

    return _getButton(Icons.cast, widget.color);
  }
}
