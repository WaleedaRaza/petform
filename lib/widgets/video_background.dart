import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  final Widget child;
  final String videoPath;
  final bool loop;
  final bool mute;

  const VideoBackground({
    super.key,
    required this.child,
    required this.videoPath,
    this.loop = true,
    this.mute = true,
  });

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.videoPath);
    
    try {
      await _controller.initialize();
      if (widget.loop) {
        _controller.setLooping(true);
      }
      if (widget.mute) {
        _controller.setVolume(0.0);
      }
      _controller.play();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show black background if video fails to load
      return Container(
        color: Colors.black,
        child: widget.child,
      );
    }

    return Stack(
      children: [
        // Video background
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        // Content overlay
        widget.child,
      ],
    );
  }
} 