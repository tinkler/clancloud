import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../http.dart';
import './const.dart';
import './memorial.dart';

extension UploadProfilePicture on Memorial {
  Future<void> uploadPicture(File file) async {
    if (id.isEmpty) {
      throw Exception('upload picture to memorial with its id is empty');
    }
    FormData formData = FormData.fromMap({
      "memorial_id": id,
      "uploads": await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });
    var response = await D.instance.dio.post(
        '$modelUrlPrefix/memorial_extra/memorial/upload-memorial-picture',
        data: formData);
    if (response.data['code'] == 0) {
      var respModel = Memorial.fromJson(response.data['data']['data']);
      assign(respModel);
    }
  }
}
