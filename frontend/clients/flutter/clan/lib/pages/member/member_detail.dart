import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/api/model/clans/clan_extra.dart';
import 'package:Clan/api/model/mqtt/user.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/http_config.dart';
import '../../providers/user_provider.dart';

class MemberDetailPage extends StatelessWidget {
  final Member member;
  final bool editable;
  const MemberDetailPage(
      {super.key, required this.member, this.editable = false});

  /// 路由跳转
  /// 如果father不为空,且member_id=0,则为新增子女
  static const routeName = '/member/detail';

  _save(BuildContext context) {
    if (member.name.isEmpty) {
      CToast.show('名字不能为空');
      return;
    }
    if (member.id == 0 && member.father != null) {
      if (member.father!.surname.isEmpty) {
        CToast.show('父亲姓氏不能为空');
        return;
      }
      if (member.father!.recognizedGeneration == 0) {
        CToast.show('父亲代数不能为0');
        return;
      }
    }

    if (member.nationality.isEmpty) {
      CToast.show('名族不能为空');
      return;
    }

    if (member.id == 0) {
      if (member.father != null) {
        member.father!.addChild(member).then((value) {
          UserProvider.of(context).loadEditList();
          Navigator.of(context).pop();
        }, onError: (e) {
          CToast.show('新增失败');
        });
      } else {
        CToast.show('未保存');
      }
    } else {
      member.update().then((v) {
        Navigator.of(context).pop();
      }, onError: (e) {
        CToast.show('保存失败');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          editable
              ? IconButton(
                  onPressed: () {
                    _save(context);
                  },
                  icon: const Icon(Icons.save),
                )
              : Container(),
        ],
      ),
      body: _MemberDetail(
        member: member,
        editable: editable,
      ),
    );
  }
}

class _MemberDetail extends StatefulWidget {
  final Member member;
  final bool editable;
  const _MemberDetail({required this.member, this.editable = false});

  @override
  State<_MemberDetail> createState() => __MemberDetailState();
}

class __MemberDetailState extends State<_MemberDetail> {
  bool _pictureUploading = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  _loadMember() async {
    setState(() {
      _loading = true;
    });
    if (widget.member.id != 0) {
      await widget.member.load();
    } else {
      if (widget.member.father != null) {
        await widget.member.father!.load();
        widget.member.recognizedGeneration =
            widget.member.father!.recognizedGeneration + 1;
      }
    }
    setState(() {
      _loading = false;
    });
  }

  _uploadPicture(ImageSource source) async {
    if (widget.member.id == 0) {
      CToast.show('新增子女,请先保存再上传图片');
      return;
    }
    if (_pictureUploading) return;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    if (statuses[Permission.storage] == PermissionStatus.denied) {
      CToast.show('需要授权存储权限才能使用该功能');
      return;
    }
    if (statuses[Permission.camera] == PermissionStatus.denied) {
      CToast.show('需要授权拍照权限才能使用该功能');
      return;
    }
    setState(() {
      _pictureUploading = true;
    });
    try {
      await widget.member.uploadProfilePicture(source);
    } catch (e) {
      print(e);
      CToast.show('无法选取图片');
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
  Widget build(BuildContext context) {
    final double picWidth = MediaQuery.of(context).size.width / 2;
    final double picHeight = picWidth / 3 * 4;
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: widget.editable ? _showUploadButton : null,
              child: Container(
                  width: picWidth,
                  height: picHeight,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: widget.member.memberProfile != null &&
                          widget.member.memberProfile!.picPath != ''
                      ? Image.network(
                          basePicUrl + widget.member.memberProfile!.picPath,
                          errorBuilder: (context, obj, st) {
                            return const Center(
                              child: Text('图片加载失败'),
                            );
                          },
                        )
                      : Container()),
            ),
            Container(
              width: picWidth - 20,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EditableTextWidget(
                    label: '名字',
                    initialValue: widget.member.name,
                    editable: widget.editable,
                    onchange: (newName) {
                      widget.member.name = newName;
                    },
                  ),
                  _EditableTextWidget(
                      label: '名族',
                      initialValue: widget.member.nationality,
                      editable: widget.editable,
                      onchange: (newNationality) {
                        widget.member.nationality = newNationality;
                      }),
                  _TextWidget(
                    label: '${widget.member.recognizedGeneration.toString()}代',
                    editable: widget.editable,
                  ),
                  _EditableTextWidget(
                    label: '出生年月',
                    initialValue: widget.member.birthRecords,
                    editable: widget.editable,
                    onchange: (newBirthRecords) {
                      widget.member.birthRecords = newBirthRecords;
                    },
                  ),
                  _EditableTextWidget(
                    label: '毕业院校',
                    initialValue: widget.member.qualifications,
                    editable: widget.editable,
                    onchange: (newQualifications) {
                      widget.member.qualifications = newQualifications;
                    },
                  ),
                  _EditableSelectWidget<int>(
                    label: '性别',
                    options: setList,
                    initialValue: _getSexOption(widget.member.sex),
                    editable: widget.editable,
                    onchange: (newSex) {
                      widget.member.sex = newSex;
                    },
                  )
                ],
              ),
            )
          ]),
          Container(
              width: MediaQuery.of(context).size.width,
              constraints: const BoxConstraints(
                minHeight: 300,
              ),
              margin: const EdgeInsets.all(10),
              child: _EditableTextWidget(
                label: '简介',
                initialValue: widget.member.introduction,
                editable: widget.editable,
                onchange: (newIntroduction) {
                  widget.member.introduction = newIntroduction;
                },
                multiline: true,
              )),
        ],
      ),
    );
  }
}

class _TextWidget extends StatelessWidget {
  final String label;
  // 编辑模式下的样式
  final bool editable;
  const _TextWidget({required this.label, this.editable = false});

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16.0, color: Colors.grey),
      ),
    );
    if (!editable) {
      return child;
    }
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(5),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
            bottom:
                BorderSide(color: Theme.of(context).dividerColor, width: 1.0)),
      ),
      child: child,
    );
  }
}

class _EditableTextWidget extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onchange;
  final bool multiline;
  final bool editable;
  const _EditableTextWidget(
      {required this.label,
      required this.initialValue,
      required this.onchange,
      this.multiline = false,
      this.editable = false});

  @override
  _EditableTextWidgetState createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<_EditableTextWidget> {
  bool _isEditing = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      widget.onchange(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 13.0),
      child: widget.initialValue.isNotEmpty && _controller.text.isNotEmpty
          ? Text(
              widget.initialValue,
              style: const TextStyle(fontSize: 16.0),
            )
          : Text(
              widget.label,
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
    );
    if (!widget.editable) {
      return child;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _isEditing = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerColor, width: 1.0)),
          color: _isEditing
              ? Colors.white
              : Theme.of(context).colorScheme.background,
        ),
        child: _isEditing
            ? TextField(
                controller: _controller,
                autofocus: true,
                onEditingComplete: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                keyboardType: widget.multiline
                    ? TextInputType.multiline
                    : TextInputType.text,
                maxLines: widget.multiline ? null : 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.label,
                ),
              )
            : child,
      ),
    );
  }
}

class _SelectOption<T> {
  final String label;
  final T value;
  const _SelectOption(this.label, this.value);
}

const setList = [
  _SelectOption('未设定', 0),
  _SelectOption('男', 1),
  _SelectOption('女', 2),
  _SelectOption('保密', 3),
];

_SelectOption<int> _getSexOption(int value) {
  return setList[value];
}

class _EditableSelectWidget<T> extends StatefulWidget {
  final String label;
  final List<_SelectOption<T>> options;
  final _SelectOption<T> initialValue;
  final ValueChanged<T> onchange;
  final bool editable;
  const _EditableSelectWidget(
      {required this.label,
      required this.options,
      required this.initialValue,
      required this.onchange,
      this.editable = false});

  @override
  _EditableSelectWidgetState<T> createState() =>
      _EditableSelectWidgetState<T>();
}

class _EditableSelectWidgetState<T> extends State<_EditableSelectWidget<T>> {
  bool _isEditing = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  _SelectOption<T>? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialValue;
    _controller.addListener(() {
      if (_selectedOption != null) {
        widget.onchange(_selectedOption!.value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
        padding: const EdgeInsets.symmetric(vertical: 13.0),
        child: _selectedOption != null
            ? Text(
                _selectedOption!.label,
                style: const TextStyle(fontSize: 16.0),
              )
            : Text(
                widget.label,
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              ));
    if (!widget.editable) {
      return child;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
        _focusNode.requestFocus();
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerColor, width: 1.0)),
          color: _isEditing
              ? Colors.white
              : Theme.of(context).colorScheme.background,
        ),
        child: _isEditing
            ? DropdownButtonFormField<_SelectOption<T>>(
                value: _selectedOption,
                onChanged: (newValue) {
                  setState(() {
                    _selectedOption = newValue;
                    if (newValue != null) {
                      _controller.text = newValue.toString();
                    }
                    _isEditing = false;
                  });
                },
                onSaved: (newValue) {
                  setState(() {
                    _selectedOption = newValue;
                    if (newValue != null) {
                      _controller.text = newValue.toString();
                    }
                    _isEditing = false;
                  });
                },
                items: widget.options.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option.label),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.label,
                ),
              )
            : child,
      ),
      onTapCancel: () {
        setState(() {
          _isEditing = false;
        });
      },
    );
  }
}
