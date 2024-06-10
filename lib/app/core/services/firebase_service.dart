import 'dart:developer';

import 'package:aco_plus/app/core/client/firestore/firestore_client.dart';
import 'package:aco_plus/app/core/client/http/fcm/fcm_provider.dart';
import 'package:aco_plus/app/core/models/service_model.dart';
import 'package:aco_plus/app/core/services/push_notification_service.dart';
import 'package:aco_plus/app/modules/usuario/usuario_controller.dart';
import 'package:aco_plus/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class FirebaseService implements Service {
  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirestoreClient.init();
      initFirebaseMessaging().then((e) {
        if (usuarioCtrl.usuarioStream.value != null) {
          FCMProvider.putToken();
        }
      });
    } catch (_, __) {
      log(_.toString());
      log(__.toString());
    }
  }

  static Future<String> uploadFile({
    required String name,
    required Uint8List bytes,
    required String mimeType,
    required String path,
  }) async {
    final folderRef = FirebaseStorage.instance.ref().child(path);
    final Reference fileRef = folderRef.child(name);
    await fileRef.putData(bytes, SettableMetadata(contentType: mimeType));
    return await fileRef.getDownloadURL();
  }
}
