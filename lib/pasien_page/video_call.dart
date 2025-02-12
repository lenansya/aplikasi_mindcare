import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  const VideoCallPage({super.key, required this.channelName});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  static const String appId = "890f63271fdf4cb7b7a19529d352189c";
  static const String tempToken = "665dffd1bf1a4ea388d91b465f5d0f06";

  late RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMicMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitAgora();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInitAgora() async {
    final permissions = await [Permission.camera, Permission.microphone].request();
    if (permissions[Permission.camera]?.isGranted == true &&
        permissions[Permission.microphone]?.isGranted == true) {
      _initAgoraEngine();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera and Microphone permissions are required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initAgoraEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.enableVideo(); // Enable video
    await _engine.enableLocalVideo(true); // Make sure camera is on
    await _engine.startPreview(); // Start preview immediately
    setState(() {
      _localUserJoined = true; // Ensure local preview renders
    });

    await _engine.joinChannel(
      token: tempToken,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call - Channel: ${widget.channelName}'),
        backgroundColor: const Color(0xFF5EA8A7),
      ),
      body: Stack(
        children: [
          Center(
            child: _renderRemoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              height: 160,
              child: _renderLocalPreview(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _videoCallControls(),
    );
  }

  Widget _renderLocalPreview() {
    if (_localUserJoined && !_isCameraOff) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else if (_isCameraOff) {
      return const Center(child: Text("Camera Off", style: TextStyle(color: Colors.grey)));
    } else {
      return const Center(child: Text("Loading local video..."));
    }
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid!),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Center(child: Text("Menunggu psikolog untuk bergabung..."));
    }
  }

  Widget _videoCallControls() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic),
            color: Colors.white,
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam),
            color: Colors.white,
            onPressed: _toggleCamera,
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: _endCall,
          ),
        ],
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
    _engine.muteLocalAudioStream(_isMicMuted);
  }

  void _toggleCamera() async {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });

    if (_isCameraOff) {
      await _engine.enableLocalVideo(false);
    } else {
      await _engine.enableLocalVideo(true);
    }
  }

  void _endCall() {
    _engine.leaveChannel();
    Navigator.pop(context);
  }
}
