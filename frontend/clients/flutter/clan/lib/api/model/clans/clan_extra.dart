import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../http.dart';
import './const.dart';
import './clan.dart';

extension UploadProfilePicture on Member {
  Future<void> uploadProfilePicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'gif'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
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
