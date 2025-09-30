import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:jbmanager/providers/ui_provider.dart';
import 'package:provider/provider.dart';

class FrozenWidget extends StatefulWidget {
  final Widget child;
  final String identifier;
  const FrozenWidget({
    super.key,
    required this.child,
    required this.identifier,
  });

  @override
  State<FrozenWidget> createState() => _FrozenWidgetState();
}

class _FrozenWidgetState extends State<FrozenWidget> {
  final GlobalKey _repaintKey = GlobalKey();

  Uint8List? _cachedBytes;
  String _identifier = '';

  Future<void> _rasterize() async {
    if (_identifier != widget.identifier) {
      // identifier changed, clear cache
      _cachedBytes = null;
      _identifier = widget.identifier;
    }
    if (_cachedBytes != null) return; // already cached

    if (_repaintKey.currentContext == null) return;

    final boundary =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final imageBytes = byteData.buffer.asUint8List();
      if (mounted) {
        Provider.of<UiProvider>(
          context,
          listen: false,
        ).cacheImage(widget.identifier, imageBytes);
        _cachedBytes = imageBytes;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // capture after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _rasterize());
    _cachedBytes = Provider.of<UiProvider>(
      context,
      listen: false,
    ).getCachedImage(widget.identifier);
  }

  @override
  Widget build(BuildContext context) {
    // print(_repaintKey.hashCode);
    if (_cachedBytes != null) {
      // show cached image
      print(
        'Showing ${widget.identifier} cached image with size: ${_cachedBytes!.lengthInBytes}',
      );
      return Image.memory(_cachedBytes!);
    }
    // print('Rendering ${widget.identifier} widget normally');
    // first render widget normally
    return RepaintBoundary(key: _repaintKey, child: widget.child);
  }

  void freeze() => _rasterize();
  void unfreeze() => setState(() => _cachedBytes = null);
}
