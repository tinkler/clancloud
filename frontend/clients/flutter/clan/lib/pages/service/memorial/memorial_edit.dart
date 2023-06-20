import 'dart:io';

import 'package:Clan/api/http_config.dart';
import 'package:Clan/api/model/memorial/memorial.dart';
import 'package:Clan/api/model/memorial/memorial_extra.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/toast.dart';

class MemorialEditPage extends StatelessWidget {
  final Memorial memorial;
  const MemorialEditPage({super.key, required this.memorial});

  static const String routeName = '/service/memorial/edit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: memorial.id.isEmpty ? const Text('新增') : Text(memorial.name),
      ),
      body: _EditForm(
        memorial: memorial,
      ),
    );
  }
}

class _EditForm extends StatefulWidget {
  final Memorial memorial;
  const _EditForm({required this.memorial});

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  bool _pictureUploading = false;
  bool _saving = false;
  File? _pickedImage;
  late final TextEditingController _nameController;
  late final String _oldName;

  _uploadPicture(ImageSource source) async {
    if (_pictureUploading) return;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    if (statuses[Permission.storage] == PermissionStatus.denied) {
      CToast.showErr('需要授权存储权限才能使用该功能');
      return;
    }
    if (statuses[Permission.camera] == PermissionStatus.denied) {
      CToast.showErr('需要授权拍照权限才能使用该功能');
      return;
    }
    setState(() {
      _pictureUploading = true;
    });
    try {
      final XFile? result = await ImagePicker().pickImage(source: source);
      if (result == null) {
        setState(() {
          _pictureUploading = false;
        });
        return;
      }
      setState(() {
        _pickedImage = File(result.path);
      });
    } catch (e) {
      print(e);
      CToast.showErr('无法选取图片');
    }

    setState(() {
      _pictureUploading = false;
    });
  }

  _showUploadButton() {
    Scaffold.of(context).showBottomSheet((context) {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 100,
            width: MediaQuery.of(context).size.width / 3 * 2,
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _uploadPicture(ImageSource.camera);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: const Text('拍照'),
                    )),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _uploadPicture(ImageSource.gallery);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: const Text('相册选取'),
                    ))
              ],
            ),
          ),
        ),
      );
    }, backgroundColor: Colors.transparent, elevation: 0);
  }

  @override
  void initState() {
    super.initState();
    _oldName = widget.memorial.name;
    _nameController = TextEditingController(text: widget.memorial.name);
    _nameController.addListener(_nameUpdate);
  }

  _nameUpdate() {
    widget.memorial.name = _nameController.text;
  }

  Future<void> _save() async {
    if (widget.memorial.name.isEmpty) {
      CToast.show('纪念堂名字不能为空!');
      return;
    }
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
    });
    if (widget.memorial.id.isEmpty) {
      await widget.memorial.create();
      if (_pickedImage != null) {
        await widget.memorial.uploadPicture(_pickedImage!);
      }
    } else {
      if (_oldName != widget.memorial.name) {
        await widget.memorial.update();
      }
      if (_pickedImage != null) {
        await widget.memorial.uploadPicture(_pickedImage!);
      }
    }
    setState(() {
      _saving = false;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_nameUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double picWidth = MediaQuery.maybeSizeOf(context)!.width / 2;
    final double picHeight = picWidth / 3 * 4;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          GestureDetector(
            onTap: _showUploadButton,
            child: Container(
                width: picWidth,
                height: picHeight,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _pickedImage != null
                    ? Image.file(_pickedImage!)
                    : widget.memorial.picPath.isNotEmpty
                        ? Image.network(
                            basePicUrl + widget.memorial.picPath,
                            errorBuilder: (context, obj, st) {
                              return const Center(
                                child: Text('图片加载失败'),
                              );
                            },
                          )
                        : Container()),
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              label: Text('纪念堂名'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _save,
                child: _saving
                    ? const SizedBox(
                        height: 25,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('保存')),
          )
        ],
      ),
    );
  }
}
