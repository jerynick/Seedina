import 'package:flutter/material.dart';
import 'package:seedina/login_page/forgot_pass.dart';
import 'package:seedina/utils/rewidgets/global/mynav.dart';
import 'package:seedina/utils/style/gcolor.dart';
import 'package:seedina/services/auth_service.dart';

class SignInPage extends StatefulWidget {
  final Function()? onTap;

  const SignInPage({super.key, required this.onTap});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isHiddenPass = true;

  void signUserIn() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    await AuthService.signInWithEmail(
      _emailcontroller.text.trim(),
      _passwordcontroller.text,
      context
    );

    if(mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void signInWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await AuthService.signInWithGoogle(context);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showErrorMsg (String errorMessage) {
    if (!mounted) return;

    final snackBar = SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [GColors.myBiru, GColors.myHijau],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(top: 144),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  width: 124,
                  height: 192,
                  child: Image.asset('assets/logo_app/logo_app-gold.png'),
                ),
                const SizedBox(
                  height: 36,
                ),
                const Text(
                  'Selamat Datang Farms!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Kembangin inovasi pertanian mulai dari kamu yuk!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(
                  height: 60,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 470,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 40, bottom: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Masuk dengan Seedina',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            width: 382,
                            child: TextFormField(
                              controller: _emailcontroller,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Email Pengguna',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            width: 382,
                            child: TextFormField(
                              controller: _passwordcontroller,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Kata Sandi Pengguna',
                                hintStyle: const TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                    suffixIcon: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _isHiddenPass = !_isHiddenPass;
                                      });
                                    },
                                    icon: _isHiddenPass ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
                                  )
                                ),
                                obscureText: _isHiddenPass,
                              validator: _validatePassword,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  GNav.slideNavStateless(context, ForgotPass());
                                },
                                child: const Text(
                                  'Lupa kata sandi kamu?',
                                  style: TextStyle(
                                      color: GColors.myBiru,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                ),
                              )),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: _isLoading
                            ? const Center(child: CircularProgressIndicator(),)
                            : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: GColors.myBiru,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              onPressed: signUserIn,
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun?',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              GestureDetector(
                                onTap: widget.onTap,
                                child: const Text(
                                  'Gabung',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: GColors.myBiru,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                thickness: 2,
                              )),
                              const Text(
                                '   Atau masuk dengan   ',
                                style: TextStyle(fontSize: 12),
                              ),
                              const Expanded(
                                  child: Divider(
                                thickness: 2,
                              )),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading ? null : signInWithGoogle,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/myicon/ic_google.png'),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      _isLoading
                                      ? CircularProgressIndicator(strokeWidth: 2)
                                      : Text(
                                        'Masuk dengan Google',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ))),
      );
  }
}
