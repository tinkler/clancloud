import 'package:Clan/pages/signin/signin_page.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';

import '../../api/model/mqtt/user.dart';
import '../../const/hive.dart';
import '../../providers/user_provider.dart';
import '../home/home_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  static const String routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 450,
        decoration: const BoxDecoration(
            image: DecorationImage(
          alignment: Alignment.topLeft,
          image: AssetImage('assets/images/signup_bg.png'),
        )),
        child: Column(
          children: [
            const SizedBox(
              height: 140,
            ),
            Text(
              '注册',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            const _SignupForm(),
          ],
        ),
      ),
    );
  }
}

class _SignupForm extends StatefulWidget {
  const _SignupForm();

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  late FToast fToast;
  String _username = '';
  String _password = '';
  bool _isAgree = true;
  bool _isObscure = true;
  bool _isObscureConfirm = true;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var auth = Auth()
        ..username = _username
        ..password = _password;
      try {
        var res = await auth.signup();
        if (res != null) {
          var box = await Hive.openBox<String>(boxSys);
          await box.put(boxValSysToken, res.token);
          await box.put(boxValSysDeviceToken, res.deviceToken);
          toHome();
          return;
        }
      } on Exception catch (e) {
        fToast.showCustomToast(e.toString());
      }
    }
  }

  void toHome() {
    UserProvider.of(context).setSignedIn(true).then((value) {
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    });
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  labelText: '用户名/手机号/邮箱',
                  // hintText: 'Enter your username',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入手机号/邮箱/用户名';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                TextFormField(
                  obscureText: _isObscure,
                  decoration: const InputDecoration(
                      labelText: '密码',
                      // hintText: 'Enter your password',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                ),
                _isObscure
                    ? Positioned(
                        right: 0,
                        top: 10,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2,
                              left: 16,
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 2,
                                      offset: Offset(1, 0),
                                    ),
                                  ],
                                ),
                                child: Text('\\',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26)),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_red_eye_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    : Positioned(
                        right: 0,
                        top: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                TextFormField(
                  obscureText: _isObscureConfirm,
                  decoration: const InputDecoration(
                      labelText: '确认密码',
                      // hintText: 'Enter your password',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请再次输入密码';
                    }
                    if (value != _password) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                _isObscureConfirm
                    ? Positioned(
                        right: 0,
                        top: 10,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2,
                              left: 16,
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 2,
                                      offset: Offset(1, 0),
                                    ),
                                  ],
                                ),
                                child: Text('\\',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26)),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_red_eye_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscureConfirm = !_isObscureConfirm;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    : Positioned(
                        right: 0,
                        top: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirm = !_isObscureConfirm;
                            });
                          },
                        ),
                      ),
              ],
            ),
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isAgree,
                      onChanged: (value) {
                        setState(() {
                          _isAgree = value!;
                        });
                      },
                    ),
                    const Text('我已阅读并同意'),
                    GestureDetector(
                      onTap: () {
                        fToast.showCustomToast('开发中...');
                      },
                      child: const Text(
                        '《用户协议》',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('注册'),
                  SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      fToast.showCustomToast('开发中...');
                    },
                    child: const Icon(
                      Icons.wechat,
                      size: 48,
                      color: Colors.green,
                    ),
                  )
                ],
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, SigninPage.routeName);
                },
                child: const Text('我已经有账号了，去登录')),
          ],
        ),
      ),
    );
  }
}
