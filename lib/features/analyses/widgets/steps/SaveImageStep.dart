import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legumi/features/analyses/components/ImageOptionCard.dart';

class SaveImageStep extends StatefulWidget {
  final void Function(String imagePath)? onImageSelected;

  const SaveImageStep({super.key, this.onImageSelected});

  @override
  State<SaveImageStep> createState() => _SaveImageStepState();
}

class _SaveImageStepState extends State<SaveImageStep> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _imagePath = photo.path);
      widget.onImageSelected?.call(photo.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
      widget.onImageSelected?.call(image.path);
    }
  }

  void _removeImage() {
    setState(() => _imagePath = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cards de selección ──────────────────
        Row(
          children: [
            Expanded(
              child: ImageOptionCard(
                icon: Icons.camera_alt_outlined,
                label: 'Tomar foto',
                onTap: _takePhoto,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ImageOptionCard(
                icon: Icons.add_photo_alternate_outlined,
                label: 'Subir imagen',
                onTap: _pickFromGallery,
              ),
            ),
          ],
        ),

        // ── Preview de la imagen ────────────────
        if (_imagePath != null) ...[
          const SizedBox(height: 20),
          Stack(
            children: [
              // Imagen seleccionada
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              // Botón para eliminar la imagen
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
