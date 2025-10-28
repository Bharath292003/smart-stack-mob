import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';

class CameraScannerPage extends StatefulWidget {
  final bool startInGallery;
  const CameraScannerPage({super.key, this.startInGallery = false});

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();

  // Queue of selected/taken images
  final List<_QueuedPhoto> _queue = [];
  // Currently captured image pending confirmation
  Uint8List? _capturedBytes;
  String? _capturedName;
  String? _capturedPath; // useful for mobile crop

  @override
  void initState() {
    super.initState();
    if (widget.startInGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickFromGallery();
      });
    } else {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final cameraPermission = await Permission.camera.request();
    
    if (cameraPermission.isGranted) {
      try {
        _cameras = await availableCameras();
        if (_cameras!.isNotEmpty) {
          _cameraController = CameraController(
            _cameras![0],
            ResolutionPreset.high,
          );
          
          await _cameraController!.initialize();
          
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        }
      } catch (e) {
        _showTopRightAlert('Error initializing camera: $e');
      }
    } else {
      _showTopRightAlert('Camera permission denied');
    }
  }

  void _showTopRightAlert(String message) {
    if (!mounted) return;
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile picture = await _cameraController!.takePicture();
        final imageBytes = await picture.readAsBytes();
        setState(() {
          _capturedBytes = imageBytes;
          _capturedName = picture.name;
          _capturedPath = picture.path;
        });
      } catch (e) {
        _showTopRightAlert('Error taking picture: $e');
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      if (kIsWeb) {
        // Web: allow multiple
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result != null) {
          for (final file in result.files) {
            if (file.bytes != null) {
              _queue.add(_QueuedPhoto(bytes: file.bytes!, name: file.name));
            }
          }
          // If we were launched explicitly to start in gallery, auto-return
          if (widget.startInGallery && _queue.isNotEmpty) {
            if (mounted) {
              Navigator.pop(context, {
                'success': true,
                'multiple': true,
                'images': _queue
                    .map((e) => {
                          'bytes': e.bytes,
                          'name': e.name,
                        })
                    .toList(),
              });
            }
            return;
          }
          if (mounted) setState(() {});
        }
      } else {
        // Mobile: multi-select
        final List<XFile> images = await _imagePicker.pickMultiImage(imageQuality: 80);
        for (final image in images) {
          final bytes = await image.readAsBytes();
          _queue.add(_QueuedPhoto(bytes: bytes, name: image.name, path: image.path));
        }
        // If we were launched explicitly to start in gallery, auto-return
        if (widget.startInGallery && _queue.isNotEmpty) {
          if (mounted) {
            Navigator.pop(context, {
              'success': true,
              'multiple': true,
              'images': _queue
                  .map((e) => {
                        'bytes': e.bytes,
                        'name': e.name,
                      })
                  .toList(),
            });
          }
          return;
        }
        if (mounted) setState(() {});
      }
    } catch (e) {
      _showTopRightAlert('Error selecting image: $e');
    }
  }

  // Confirm current captured photo: add to queue
  void _confirmCaptured() {
    if (_capturedBytes != null) {
      _queue.add(_QueuedPhoto(bytes: _capturedBytes!, name: _capturedName ?? 'captured.jpg', path: _capturedPath));
      setState(() {
        _capturedBytes = null;
        _capturedName = null;
        _capturedPath = null;
      });
    }
  }

  // Retry: discard current preview
  void _retryCapture() {
    setState(() {
      _capturedBytes = null;
      _capturedName = null;
      _capturedPath = null;
    });
  }

  Future<void> _cropCaptured() async {
    if (_capturedPath == null) {
      // Cropping from bytes is not supported in image_cropper; limit to mobile path
      _showTopRightAlert('Crop is only available on mobile captures.');
      return;
    }
    try {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: _capturedPath!,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Crop Photo', hideBottomControls: false),
          IOSUiSettings(title: 'Crop Photo'),
        ],
      );
      if (cropped != null) {
        final bytes = await cropped.readAsBytes();
        setState(() {
          _capturedBytes = bytes;
          _capturedName = _capturedName ?? 'captured.jpg';
          _capturedPath = cropped.path;
        });
      }
    } catch (e) {
      _showTopRightAlert('Crop failed: $e');
    }
  }

  Future<void> _editQueued(int index) async {
    final item = _queue[index];
    if (item.path == null) {
      _showTopRightAlert('Edit is only available for mobile photos.');
      return;
    }
    try {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: item.path!,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Edit Photo', hideBottomControls: false),
          IOSUiSettings(title: 'Edit Photo'),
        ],
      );
      if (cropped != null) {
        final bytes = await cropped.readAsBytes();
        setState(() {
          _queue[index] = _QueuedPhoto(bytes: bytes, name: item.name, path: cropped.path);
        });
      }
    } catch (e) {
      _showTopRightAlert('Edit failed: $e');
    }
  }

  void _removeQueued(int index) {
    setState(() {
      _queue.removeAt(index);
    });
  }

  void _proceed() {
    if (_queue.isEmpty) {
      _showTopRightAlert('No photos selected.');
      return;
    }
    Navigator.pop(context, {
      'success': true,
      'multiple': true,
      'images': _queue
          .map((e) => {
                'bytes': e.bytes,
                'name': e.name,
              })
          .toList(),
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Business Card',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pickFromGallery,
            tooltip: 'Choose from Gallery',
          ),
        ],
      ),
      body: (widget.startInGallery || _isCameraInitialized)
          ? Stack(
              children: [
                // Camera Preview (only in camera mode)
                if (!widget.startInGallery && _isCameraInitialized)
                  Positioned.fill(
                    child: CameraPreview(_cameraController!),
                  ),

                // Overlay with scanning frame (only in camera mode)
                if (!widget.startInGallery && _isCameraInitialized)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8 * 0.63,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF6C63FF),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Instructions
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Position the business card within the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Capture Button (only in camera mode)
                if (!widget.startInGallery && _isCameraInitialized)
                  Positioned(
                    bottom: 150,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF6C63FF),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF6C63FF),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom queue bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      border: const Border(top: BorderSide(color: Colors.white24, width: 0.5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 60,
                          child: _queue.isEmpty
                              ? Center(
                                  child: Text(
                                    'No photos yet. Capture or upload.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _queue.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final item = _queue[index];
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(
                                            item.bytes,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 2,
                                          top: 2,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _editQueued(index),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _removeQueued(index),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _queue.isNotEmpty ? _proceed : null,
                                icon: const Icon(Icons.send),
                                label: const Text('Done'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (widget.startInGallery)
                              OutlinedButton.icon(
                                onPressed: _pickFromGallery,
                                icon: const Icon(Icons.photo_library, color: Colors.white),
                                label: const Text('Upload Photos'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Captured preview overlay
                if (_capturedBytes != null && !widget.startInGallery)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.8),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Image.memory(
                                _capturedBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _retryCapture,
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _cropCaptured,
                                  icon: const Icon(Icons.crop, color: Colors.white),
                                  label: const Text('Crop', style: TextStyle(color: Colors.white)),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: _confirmCaptured,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF6C63FF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QueuedPhoto {
  final Uint8List bytes;
  final String name;
  final String? path; // mobile path for editing
  _QueuedPhoto({required this.bytes, required this.name, this.path});
}