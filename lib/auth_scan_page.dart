import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/dialog.dart';
import 'package:purity_auth/top_bar.dart';

class AuthScanPage extends StatefulWidget {
  const AuthScanPage({super.key});

  @override
  _AuthScanPageState createState() => _AuthScanPageState();
}

class _AuthScanPageState extends State<AuthScanPage> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isScanningAllowed = true;
  bool _isProcessing = false;
  CameraLensDirection _currentCameraLensDirection = CameraLensDirection.back;

  static List<CameraDescription> _availableCameras = <CameraDescription>[];
  CameraController? _cameraController;
  int _selectedCameraIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _stopCameraFeed();
    _isScanningAllowed = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _cameraController == null ? Container() : CameraPreview(_cameraController!),
            Align(
                alignment: Alignment.topCenter,
                child: TopBar(
                  context,
                  '扫描二维码',
                  rightIcon: enableFlash ? Icons.flash_off : Icons.flash_on,
                  rightOnPressed: flash,
                )),
          ],
        ),
      ),
    );
  }

  /// 处理并扫描图像
  /// [context] 当前上下文
  /// [inputImage] 输入的图像
  Future<void> _processAndScanImage(BuildContext context, InputImage inputImage) async {
    if (!_isScanningAllowed || _isProcessing) return;

    _isProcessing = true;
    final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      if (barcodes.length > 1) {
        showAlertDialog(context, '扫描结果', '识别到多个二维码');
        return;
      }

      try {
        final Barcode barcode = barcodes.first;
        final String rawValue = barcode.rawValue ?? '';
        final AuthenticationConfig config = AuthenticationConfig.parse(rawValue);
        await GetIt.I<AuthRepository>().insert(config);

        _isScanningAllowed = false;
        Navigator.popUntil(context, (Route route) => route.settings.name == '/');
        showAlertDialog(context, '扫描结果', '添加成功');

        return;
      } on ArgumentError catch (e) {
        showAlertDialog(context, '参数错误', e.message as String?);
        return;
      } on FormatException catch (e) {
        showAlertDialog(context, '格式错误', e.message);
        return;
      } catch (e) {
        showAlertDialog(context, '未知错误', e.toString());
        return;
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    _isProcessing = false;
    if (mounted) setState(() {});
  }

  /// 初始化相机和视频流
  Future<void> _initializeCamera() async {
    if (_availableCameras.isEmpty) {
      _availableCameras = await availableCameras();
    }
    for (int i = 0; i < _availableCameras.length; i++) {
      if (_availableCameras[i].lensDirection == _currentCameraLensDirection) {
        _selectedCameraIndex = i;
        break;
      }
    }
    if (_selectedCameraIndex != -1) {
      _startCameraFeed();
    }
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
        setState(() => _currentCameraLensDirection = camera.lensDirection);
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
    // widget.onImageCaptured(inputImage);
    _processAndScanImage(context, inputImage);
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

  bool enableFlash = false;

  void flash(BuildContext context) {
    if (enableFlash) {
      _cameraController?.setFlashMode(FlashMode.off);
      setState(() {
        enableFlash = false;
      });
    } else {
      _cameraController?.setFlashMode(FlashMode.torch);
      setState(() {
        enableFlash = true;
      });
    }
  }
}
