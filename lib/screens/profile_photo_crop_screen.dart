import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePhotoCropScreen extends StatefulWidget {
  final File source;

  const ProfilePhotoCropScreen({super.key, required this.source});

  @override
  State<ProfilePhotoCropScreen> createState() => _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState extends State<ProfilePhotoCropScreen> {
  ui.Image? _sourceImage;
  Uint8List? _imageBytes;
  double _scale = 1;
  double _startScale = 1;
  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  double _lastCropSize = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.source.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _sourceImage = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _sourceImage;
    final bytes = _imageBytes;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Edit Foto Profil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: image == null || bytes == null
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final cropSize = math.min(
                            constraints.maxWidth - 32,
                            constraints.maxHeight - 32,
                          );
                          _lastCropSize = cropSize;

                          return _CropViewport(
                            imageBytes: bytes,
                            imageWidth: image.width.toDouble(),
                            imageHeight: image.height.toDouble(),
                            cropSize: cropSize,
                            scale: _scale,
                            offset: _offset,
                            onScaleStart: (details) {
                              _startScale = _scale;
                              _startOffset = _offset;
                              _startFocalPoint = details.focalPoint;
                            },
                            onScaleUpdate: (details) {
                              final nextScale = (_startScale * details.scale)
                                  .clamp(1.0, 5.0)
                                  .toDouble();
                              final nextOffset =
                                  _startOffset +
                                  details.focalPoint -
                                  _startFocalPoint;

                              setState(() {
                                _scale = nextScale;
                                _offset = _clampOffset(
                                  offset: nextOffset,
                                  cropSize: cropSize,
                                  imageWidth: image.width.toDouble(),
                                  imageHeight: image.height.toDouble(),
                                  scale: nextScale,
                                );
                              });
                            },
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _isSaving || image == null ? null : _saveCroppedImage,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1A5E35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _clampOffset({
    required Offset offset,
    required double cropSize,
    required double imageWidth,
    required double imageHeight,
    required double scale,
  }) {
    final baseScale = math.max(cropSize / imageWidth, cropSize / imageHeight);
    final displayedWidth = imageWidth * baseScale * scale;
    final displayedHeight = imageHeight * baseScale * scale;
    final maxX = math.max(0.0, (displayedWidth - cropSize) / 2);
    final maxY = math.max(0.0, (displayedHeight - cropSize) / 2);

    return Offset(
      offset.dx.clamp(-maxX, maxX).toDouble(),
      offset.dy.clamp(-maxY, maxY).toDouble(),
    );
  }

  Future<void> _saveCroppedImage() async {
    final image = _sourceImage;
    if (image == null) return;

    setState(() => _isSaving = true);

    try {
      final cropSize = _lastCropSize;
      if (cropSize <= 0) {
        throw Exception('Area crop belum siap.');
      }
      final baseScale = math.max(
        cropSize / image.width,
        cropSize / image.height,
      );
      final displayedWidth = image.width * baseScale * _scale;
      final displayedHeight = image.height * baseScale * _scale;
      final left = cropSize / 2 + _offset.dx - displayedWidth / 2;
      final top = cropSize / 2 + _offset.dy - displayedHeight / 2;
      final sourceX = ((-left) / displayedWidth * image.width).clamp(
        0.0,
        math.max(0.0, image.width - 1.0),
      ).toDouble();
      final sourceY = ((-top) / displayedHeight * image.height).clamp(
        0.0,
        math.max(0.0, image.height - 1.0),
      ).toDouble();
      final maxSourceSize = math.max(
        1.0,
        math.min(image.width - sourceX, image.height - sourceY),
      );
      final sourceSize = (cropSize / displayedWidth * image.width)
          .clamp(1.0, maxSourceSize)
          .toDouble();

      final outputSize = sourceSize.round().clamp(256, 1080).toInt();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
      final sourceRect = ui.Rect.fromLTWH(
        sourceX,
        sourceY,
        sourceSize,
        sourceSize,
      );
      final outputRect = ui.Rect.fromLTWH(
        0,
        0,
        outputSize.toDouble(),
        outputSize.toDouble(),
      );

      canvas.drawImageRect(image, sourceRect, outputRect, paint);

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(outputSize, outputSize);
      final byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Gagal membuat hasil crop.');
      }

      final directory = await getTemporaryDirectory();
      final outputFile = File(
        '${directory.path}/profile_crop_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await outputFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      Navigator.pop(context, outputFile);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal crop foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _CropViewport extends StatelessWidget {
  final Uint8List imageBytes;
  final double imageWidth;
  final double imageHeight;
  final double cropSize;
  final double scale;
  final Offset offset;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;

  const _CropViewport({
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.cropSize,
    required this.scale,
    required this.offset,
    required this.onScaleStart,
    required this.onScaleUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final baseScale = math.max(cropSize / imageWidth, cropSize / imageHeight);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: cropSize,
          height: cropSize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onScaleStart: onScaleStart,
            onScaleUpdate: onScaleUpdate,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: offset,
                  child: Transform.scale(
                    scale: scale,
                    child: Image.memory(
                      imageBytes,
                      width: imageWidth * baseScale,
                      height: imageHeight * baseScale,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: Container(
            width: cropSize,
            height: cropSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
