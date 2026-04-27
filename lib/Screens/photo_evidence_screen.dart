import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoEvidenceScreen extends StatefulWidget {
  final String assetId;

  const PhotoEvidenceScreen({super.key, required this.assetId});

  @override
  State<PhotoEvidenceScreen> createState() => _PhotoEvidenceScreenState();
}

class _PhotoEvidenceScreenState extends State<PhotoEvidenceScreen> {
  List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  String _selectedCondition = 'Working - Good Condition';
  final List<String> _conditions = [
    'Working - Good Condition',
    'Working - Minor Wear & Tear',
    'Faulty - Needs Electrical Repair',
    'Camera/GPS Offline',
    'Damaged - Body Work Needed',
    'Damaged - Severe (Accident)',
    'Not Working - Idle',
    'Needs Total Replacement',
    'Under Maintenance'
  ];


  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                child: Center(
                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue, size: 30),
                title: const Text('Take a Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green, size: 30),
                title: const Text('Choose from Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 30);
    if (photo != null) setState(() => _imageFiles.add(File(photo.path)));
  }

  Future<void> _pickFromGallery() async {
    final List<XFile> photos = await _picker.pickMultiImage(imageQuality: 30);
    if (photos.isNotEmpty) {
      setState(() {
        for (var photo in photos) {
          _imageFiles.add(File(photo.path));
        }
      });
    }
  }

  void _removePicture(int index) {
    setState(() => _imageFiles.removeAt(index));
  }


  Future<void> _saveDataToFirebase() async {
    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one photo!')));
      return;
    }


    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: User not logged in!')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      List<String> base64ImagesList = [];
      for (File file in _imageFiles) {
        List<int> imageBytes = await file.readAsBytes();
        base64ImagesList.add(base64Encode(imageBytes));
      }


      await FirebaseFirestore.instance.collection('surveys').add({
        'asset_id': widget.assetId,
        'condition': _selectedCondition,
        'photo_count': _imageFiles.length,
        'images_data': base64ImagesList,
        'date_time': FieldValue.serverTimestamp(),
        'uid': user.uid,
        'user_email': user.email,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Survey Saved Successfully!')));
      Navigator.popUntil(context, (route) => route.isFirst);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Condition & Photos'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssetIdCard(),
            const SizedBox(height: 20),
            const Text('Equipment Condition', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildConditionDropdown(),
            const SizedBox(height: 25),
            _buildPhotoHeader(),
            const SizedBox(height: 10),
            Expanded(child: _imageFiles.isEmpty ? _buildEmptyPlaceholder() : _buildPhotoGrid()),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetIdCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.shade200)),
      child: Text('Asset ID: ${widget.assetId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCondition, isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: (v) => setState(() => _selectedCondition = v!),
    );
  }

  Widget _buildPhotoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Photo Evidence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: _showPhotoOptions,
          icon: const Icon(Icons.add_a_photo),
          label: Text('${_imageFiles.length} Photos'),
          style: TextButton.styleFrom(backgroundColor: Colors.blue.shade50),
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder() {
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        width: double.infinity, height: 150,
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid)
        ),
        child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text('Tap here to add photos', style: TextStyle(color: Colors.grey))
            ]
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      itemCount: _imageFiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (context, index) => Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_imageFiles[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
          Positioned(
              right: 0, top: 0,
              child: GestureDetector(
                  onTap: () => _removePicture(index),
                  child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white))
              )
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
        onPressed: _isSaving ? null : _saveDataToFirebase,
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Survey to Cloud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}