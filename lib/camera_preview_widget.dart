import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purity_auth/dialog.dart';

/// 相机视图组件
class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    super.key,
    required this.onImageCaptured,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back,
  });

  /// 用于处理输入图像的回调函数
  final Function(InputImage inputImage) onImageCaptured;

  /// 相机视频流准备好时的可选回调
  final VoidCallback? onCameraFeedReady;

  /// 检测器视图模式更改时的可选回调
  final VoidCallback? onDetectorViewModeChanged;

  /// 相机镜头方向更改时的可选回调
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  /// 初始相机镜头方向，默认为后置摄像头
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  static List<CameraDescription> _availableCameras = <CameraDescription>[];
  CameraController? _cameraController;
  int _selectedCameraIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// 初始化相机和视频流
  Future<void> _initializeCamera() async {
    if (_availableCameras.isEmpty) {
      _availableCameras = await availableCameras();
    }
    for (int i = 0; i < _availableCameras.length; i++) {
      if (_availableCameras[i].lensDirection == widget.initialCameraLensDirection) {
        _selectedCameraIndex = i;
        break;
      }
    }
    if (_selectedCameraIndex != -1) {
      _startCameraFeed();
    }
  }

  @override
  void dispose() {
    _stopCameraFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null) {
      return Container();
    }
    return CameraPreview(_cameraController!);
  }

  /// 启动实时视频流
  Future<void> _startCameraFeed() async {
    final CameraDescription camera = _availableCameras[_selectedCameraIndex];
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    _cameraController?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController?.startImageStream(_processCameraImage).then((_) {
        widget.onCameraFeedReady?.call();
        widget.onCameraLensDirectionChanged?.call(camera.lensDirection);
      });
      setState(() {});
    }, onError: (e) {
      if (e is CameraException) {
        if (e.code == 'CameraAccessDenied') {
          _showPermissionAlert();
        } else {
          showAlertDialog(context, e.code, e.description);
        }
      } else {
        showAlertDialog(context, '发生了一些意料之外的错误', '$e');
      }
    });
  }

  /// 停止实时视频流并释放相机控制器
  Future<void> _stopCameraFeed() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
  }

  /// 处理相机捕获的图像
  void _processCameraImage(CameraImage image) {
    final InputImage? inputImage = _createInputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImageCaptured(inputImage);
  }

  final Map<DeviceOrientation, int> _orientations = <DeviceOrientation, int>{
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// 从相机图像生成输入图像
  /// 返回生成的输入图像，如果无法生成则返回 null
  InputImage? _createInputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final CameraDescription camera = _availableCameras[_selectedCameraIndex];
    final int sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      int? rotationCompensation = _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      rotationCompensation = (camera.lensDirection == CameraLensDirection.front) ? (sensorOrientation + rotationCompensation) % 360 : (sensorOrientation - rotationCompensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw as int);
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final Plane plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// 显示权限不足提示框
  void _showPermissionAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('权限不足'),
          content: const Text('需要相机权限'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (Route route) => route.settings.name == '/AuthAddPage'),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.popUntil(context, (Route route) => route.settings.name == '/AuthAddPage');
                openAppSettings();
              },
              child: const Text('申请相机权限'),
            ),
          ],
        );
      },
    );
  }
}
