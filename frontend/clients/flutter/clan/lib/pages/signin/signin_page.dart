import 'package:Clan/providers/user_provider.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';

import '../../api/model/mqtt/user.dart';
import '../../const/hive.dart';
import '../home/home_page.dart';
import '../signup_page/signup_page.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  static const String routeName = '/signin';

  @override
  Widget build(BuildContext context) {
    UserProvider.of(context).resetUser();
    return Scaffold(
      body: Container(
        width: 450,
        decoration: const BoxDecoration(
            image: DecorationImage(
          alignment: Alignment.topLeft,
          image: AssetImage('assets/images/signin_bg.png'),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 240,
            ),
            Text(
              '欢迎登录',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
            const _SigninForm(),
          ],
        ),
      ),
    );
  }
}

class _SigninForm extends StatefulWidget {
  const _SigninForm();

  @override
  State<_SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<_SigninForm> {
  final _formKey = GlobalKey<FormState>();
  late FToast fToast;
  String _username = '';
  String _password = '';
  bool _rememberMe = true;
  bool _isObscure = true;
  bool _loading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && !_loading) {
      setState(() {
        _loading = true;
      });
      var sysBox = await Hive.openBox<String>(boxSys);
      var auth = Auth()
        ..username = _username
        ..password = _password;
      var deviceToken = sysBox.get(boxValSysDeviceToken);
      if (deviceToken != null) {
        auth.deviceToken = deviceToken;
      }
      try {
        var res = await auth.signin();
        if (res != null) {
          await sysBox.put(boxValSysToken, res.token);
          await sysBox.put(boxValSysDeviceToken, res.deviceToken);
          toHome();
          return;
        }
      } on Exception catch (e) {
        fToast.showCustomToast(e.toString());
        setState(() {
          _loading = false;
        });
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
            Row(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        child: const Text('自动登录')),
                  ],
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('忘记密码?')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('登录'),
                  const SizedBox(width: 16),
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
                  Navigator.pushReplacementNamed(context, SignupPage.routeName);
                },
                child: const Text('注册新账号')),
          ],
        ),
      ),
    );
  }
}
