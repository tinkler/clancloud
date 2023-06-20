import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../http.dart';
import './const.dart';
import './clan.dart';

extension UploadProfilePicture on Member {
  Future<void> uploadProfilePicture(ImageSource source) async {
    if (id == 0) {
      throw Exception('upload picture to member that its id is 0');
    }
    final XFile? result = await ImagePicker().pickImage(source: source);
    if (result == null) return;
    File file = File(result.path);
    FormData formData = FormData.fromMap({
      "member_id": id,
      "uploads": await MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last),
    });
    var response = await D.instance.dio.post(
        '$modelUrlPrefix/clan_extra/member/upload-profile-picture',
        data: formData);
    if (response.data['code'] == 0) {
      var respModel = Member.fromJson(response.data['data']['data']);
      assign(respModel);
    }
  }
}
