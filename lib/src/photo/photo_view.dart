import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/s.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui_application/ui_application.dart';
import 'package:path/path.dart' as p;

import '../camera/device_camera_model.dart';
import '../camera/photo_button_info.dart';
import '../camera/manager.dart';
import '../camera/photo_button.dart';
import '../dependency_injection/aurora_di.dart';
import '../dependency_injection/di.dart';
import '../log/log.dart';
import '../routes/app_router.dart';
import 'photo_check_manager.dart';

@RoutePage()
class PhotoScreen extends ConsumerStatefulWidget {
  const PhotoScreen({super.key});

  @override
  ConsumerState<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends ConsumerState<PhotoScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  StreamSubscription<DeviceCameraModel>? _subscription;
  String description = '';
  FlashMode flashMode = FlashMode.always;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final camerasManager = getIt.get<CamerasManager>();
    _subscription ??= camerasManager.stream.listen(_onCamerasMangerEvent);
  }

  void _onCamerasMangerEvent(DeviceCameraModel cameraModel) =>
      cameraModel.when<void>(
        available: (cameras) {
          CameraDescription cameraDesc = cameras.first;
          for (final camera in cameras) {
            if (camera.lensDirection == CameraLensDirection.back) {
              cameraDesc = camera;
              break;
            }
          }
          unawaited(onNewCameraSelected(cameraDesc));
          setState(() {});
        },
        empty: () {
          description = 'Нет доступных камер';
          setState(() {});
        },
        rejected: () {
          description = 'Нажмите, чтобы дать разрешение к камере';
          setState(() {});
        },
        error: (message) {
          description = 'Произошла ошибка';
          setState(() {});
        },
        idle: () {
          description = 'Загрузка...';
          setState(() {});
        },
      );

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      unawaited(cameraController.dispose());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_initializeCameraController(cameraController.description));
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoCheckNotifier =
        ref.watch(AuroraDi.photoCheckProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: InfoButton(
          onPressed: () {
            unawaited(
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(S.of(context).auroraPhotoTestDesc),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(S.of(context).ok),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          SettingsButton(
            onTap: () async {
              await context.router.push(const SettingsRoute());
            },
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: _cameraPreviewWidget(),
              ),
            ),
          ),
          InkWell(
            onTap: controller != null && controller!.value.isInitialized
                ? () async =>
                    onTakePictureButtonPressed(context, photoCheckNotifier)
                : null,
            child: const Align(
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: PhotoButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return GestureDetector(
        child: Text(
          description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        onTap: () async {
          final camerasManager = getIt.get<CamerasManager>();
          final cameras = await availableCameras();
          camerasManager.updateCameras(cameras);
        },
      );
    } else {
      return CameraPreview(
        controller!,
      );
    }
  }

  Future<void> onTakePictureButtonPressed(
      BuildContext context, PhotoCheckManager photoCheckNotifier) async {
    await takePicture().then(
      (XFile? xfile) async {
        if (mounted) {
          if (xfile != null) {
            // Get bytes
            final bytes = await xfile.readAsBytes();
            // Get path
            final directory = await getExternalStorageDirectories(
              type: StorageDirectory.pictures,
            );
            // Save to file
            final file = await bytes.writeToFile(directory![0], xfile);
            getIt.get<Log>().d(file.path);
            photoCheckNotifier.checkPhoto(file.path);
            final camerasManager = getIt.get<CamerasManager>();
            camerasManager.turnOff();
            await context.router.push(const PhotoCheckRoute());
          }
        }
      },
    );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      _showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      getIt.get<Log>().e('Error: ${e.code}\n${e.description}');
      _showInSnackBar('Error: ${e.code}\n${e.description}');
      return null;
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        _showInSnackBar(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.off);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          _showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          _showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          _showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          _showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          _showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          _showInSnackBar('Audio access is restricted.');
        default:
          getIt.get<Log>().e('Error: ${e.code}\n${e.description}');
          _showInSnackBar('Error: ${e.code}\n${e.description}');
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _subscription?.cancel();
    super.dispose();
  }
}

extension ExtUint8List on Uint8List {
  Future<File> writeToFile(Directory directory, XFile file) {
    if (file.name.isEmpty) {
      return File(p.join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      )).writeAsBytes(this);
    } else {
      return File(p.join(directory.path, file.name)).writeAsBytes(this);
    }
  }
}

