import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:typed_data';
import 'api_helper.dart';
import 'package:smart_stack/app_colors.dart';

class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage({super.key});

  @override
  State<CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<CameraScannerPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();
  
  // State for dual image capture
  Uint8List? _firstImageBytes;
  String? _firstImageFileName;
  String? _firstImagePath;
  
  Uint8List? _secondImageBytes;
  String? _secondImageFileName;
  String? _secondImagePath;
  bool _isCapturingSecondImage = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

  void _showImageConfirmationDialog(List<int> imageBytes, String fileName, String imagePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: AppColors.slate100,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Business Card Images',
                              style: TextStyle(
                                color: AppColors.slate100,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Images Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Capture both sides of the business card for better extraction',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.slate300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // Two image slots
                          Row(
                            children: [
                              // First image slot
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Front Side',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.slate100,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.slate600,
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: _firstImageBytes != null
                                            ? Image.memory(
                                                _firstImageBytes!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                            : Image.memory(
                                                Uint8List.fromList(imageBytes),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Second image slot
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Back Side (Optional)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.slate100,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () => _captureSecondImage(setState),
                                      child: Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.slate600,
                                            width: 1,
                                          ),
                                          color: _secondImageBytes == null 
                                              ? AppColors.slate800.withOpacity(0.3)
                                              : null,
                                        ),
                                        child: _secondImageBytes != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.memory(
                                                  _secondImageBytes!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              )
                                            : const Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.add_a_photo,
                                                      color: AppColors.slate400,
                                                      size: 32,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Tap to add',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.slate400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Action Buttons
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Reset state and close dialog
                                _resetImageState();
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: AppColors.slate400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.slate400,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                _processImages(imageBytes, fileName, imagePath);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Process Images',
                                style: TextStyle(
                                  color: AppColors.slate100,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();
      final fileName = 'captured_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (_isCapturingSecondImage) {
        // Store as second image and show updated dialog
        setState(() {
          _secondImageBytes = Uint8List.fromList(imageBytes);
          _secondImageFileName = fileName;
          _secondImagePath = image.path;
          _isCapturingSecondImage = false;
        });
        
        // Show confirmation dialog with both images
        _showImageConfirmationDialog(
          _firstImageBytes!, 
          _firstImageFileName!, 
          _firstImagePath!
        );
      } else {
        // Store as first image and show confirmation dialog
        setState(() {
          _firstImageBytes = Uint8List.fromList(imageBytes);
          _firstImageFileName = fileName;
          _firstImagePath = image.path;
        });
        
        // Show confirmation dialog with dual image support
        _showImageConfirmationDialog(imageBytes, fileName, image.path);
      }
    } catch (e) {
      _showTopRightAlert('Error taking picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      if (kIsWeb) {
        // Use file_picker for web compatibility
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.single.bytes != null) {
          final fileBytes = result.files.single.bytes!;
          final fileName = result.files.single.name;
          
          _showTopRightAlert('Processing image...');
          
          try {
            // Send image to backend for processing
            final response = await ApiHelper.uploadImageForCardExtraction(
              fileBytes,
              fileName,
            );
            
            if (response.statusCode == 200) {
              final responseData = json.decode(response.body);
              _showTopRightAlert('Card processed successfully!');
              
              // Navigate back with success and response data
              if (mounted) {
                Navigator.pop(context, {
                  'success': true,
                  'data': responseData,
                  'bytes': fileBytes,
                  'name': fileName,
                  'path': fileName,
                });
              }
            } else {
              _showTopRightAlert('Processing failed: ${response.statusCode}');
              
              // Navigate back with error info
              if (mounted) {
                Navigator.pop(context, {
                  'success': false,
                  'error': 'Processing failed: ${response.statusCode}',
                  'bytes': fileBytes,
                  'name': fileName,
                  'path': fileName,
                });
              }
            }
          } catch (apiError) {
            _showTopRightAlert('Network error: $apiError');
            
            // Navigate back with error info
            if (mounted) {
              Navigator.pop(context, {
                'success': false,
                'error': 'Network error: $apiError',
                'bytes': fileBytes,
                'name': fileName,
                'path': fileName,
              });
            }
          }
        }
      } else {
        // Use image_picker for mobile platforms
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        
        if (image != null) {
          _showTopRightAlert('Processing image...');
          
          try {
            // Read image bytes for mobile
            final imageBytes = await image.readAsBytes();
            final fileName = image.name;
            
            // Send image to backend for processing
            final response = await ApiHelper.uploadImageForCardExtraction(
              imageBytes,
              fileName,
            );
            
            if (response.statusCode == 200) {
              final responseData = json.decode(response.body);
              _showTopRightAlert('Card processed successfully!');
              
              // Navigate back with success and response data
              if (mounted) {
                Navigator.pop(context, {
                  'success': true,
                  'data': responseData,
                  'path': image.path,
                });
              }
            } else {
              _showTopRightAlert('Processing failed: ${response.statusCode}');
              
              // Navigate back with error info
              if (mounted) {
                Navigator.pop(context, {
                  'success': false,
                  'error': 'Processing failed: ${response.statusCode}',
                  'path': image.path,
                });
              }
            }
          } catch (apiError) {
            _showTopRightAlert('Network error: $apiError');
            
            // Navigate back with error info
            if (mounted) {
              Navigator.pop(context, {
                'success': false,
                'error': 'Network error: $apiError',
                'path': image.path,
              });
            }
          }
        }
      }
    } catch (e) {
      _showTopRightAlert('Error selecting image: $e');
    }
  }

  void _captureSecondImage(StateSetter setState) async {
    // Close the dialog and return to camera view to capture second image
    Navigator.of(context).pop();
    
    // Set a flag to indicate we're capturing the second image
    setState(() {
      _isCapturingSecondImage = true;
    });
    
    // Show a message to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Position the back side of the card and tap the capture button'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resetImageState() {
    setState(() {
      _firstImageBytes = null;
      _firstImageFileName = null;
      _firstImagePath = null;
      _secondImageBytes = null;
      _secondImageFileName = null;
      _secondImagePath = null;
      _isCapturingSecondImage = false;
    });
  }

  void _processImages(List<int> firstImageBytes, String firstFileName, String firstImagePath) {
    // Set the first image if not already set
    if (_firstImageBytes == null) {
      _firstImageBytes = Uint8List.fromList(firstImageBytes);
      _firstImageFileName = firstFileName;
      _firstImagePath = firstImagePath;
    }

    // Navigate back to home with both images
    Navigator.pop(context, {
      'success': true,
      'firstImageBytes': _firstImageBytes,
      'firstImageFileName': _firstImageFileName,
      'firstImagePath': _firstImagePath,
      'secondImageBytes': _secondImageBytes,
      'secondImageFileName': _secondImageFileName,
      'secondImagePath': _secondImagePath,
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
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Camera Preview
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                
                // Overlay with scanning frame
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8 * 0.63, // Business card ratio
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
                
                // Capture Button
                Positioned(
                  bottom: 50,
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