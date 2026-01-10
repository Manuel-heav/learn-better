import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload audio recording
  Future<String> uploadAudioRecording({
    required String uid,
    required File audioFile,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('recordings/$uid/$fileName');
      final uploadTask = ref.putFile(audioFile);
      
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload audio recording';
    }
  }

  // Upload PDF
  Future<String> uploadPDF({
    required String uid,
    required File pdfFile,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('pdfs/$uid/$fileName');
      final uploadTask = ref.putFile(pdfFile);
      
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload PDF';
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('profile_images/$uid/avatar.jpg');
      final uploadTask = ref.putFile(imageFile);
      
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload profile image';
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete file';
    }
  }

  // Get download URL
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to get download URL';
    }
  }

  // List user recordings
  Future<List<String>> listUserRecordings(String uid) async {
    try {
      final ref = _storage.ref().child('recordings/$uid');
      final result = await ref.listAll();
      
      final urls = <String>[];
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw 'Failed to list recordings';
    }
  }
}

