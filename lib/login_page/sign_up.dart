import 'package:flutter/material.dart';
import 'package:seedina/utils/style/gcolor.dart';
import 'package:seedina/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? onTap;

  const SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();
  final TextEditingController _usernamecontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isHiddenPass = true;

  void signUserUp() async {
    if (_isLoading || _formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordcontroller.text != _confirmpasswordcontroller.text) {
      showErrorMsg("Kata Sandi tidak sama");
      return;
    }
    setState(() {
      _isLoading = true;
    });

    await AuthService.signUpWithEmail(
      _usernamecontroller.text.trim(),
      _emailcontroller.text.trim(),
      _passwordcontroller.text,
      context
    );

    if (mounted) {
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
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama Pengguna tidak boleh kosong';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata Sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata Sandi minimal 6 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi Kata Sandi Pengguna tidak boleh kosong';
    }
    if (value != _passwordcontroller.text) {
      return 'Kata Sandi tidak sama';
    }
    return null;
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    _confirmpasswordcontroller.dispose();
    _usernamecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GColors.myBiru, GColors.myHijau],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        )
      ),
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
                  SizedBox(height: 36),
                  Text(
                    'Belum Punya Akun?',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Daftar dan jadilah partner kami, Farms!',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 60),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 610,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                      child: Form( 
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Daftar dengan Seedina',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: 382,
                              child: TextFormField(
                                controller: _usernamecontroller,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Nama Pengguna',
                                  hintStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                validator: _validateUsername,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: 382,
                              child: TextFormField(
                                controller: _emailcontroller,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Email Pengguna',
                                  hintStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: 382,
                              child: TextFormField(
                                controller: _passwordcontroller,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Kata Sandi Pengguna',
                                  hintStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                            SizedBox(height: 12),
                            SizedBox(
                              width: 382,
                              child: TextFormField(
                                controller: _confirmpasswordcontroller,
                                style: TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Konfirmasi Kata Sandi Pengguna',
                                  hintStyle: TextStyle(fontSize: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                                validator: _validateConfirmPassword,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GColors.myBiru,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: signUserUp,
                                child: Text(
                                  'Daftar',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sudah punya akun?', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: widget.onTap,
                                  child: Text(
                                    'Masuk',
                                    style: TextStyle(fontSize: 12, color: GColors.myBiru, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: Divider(thickness: 2)),
                                Text('Atau', style: TextStyle(fontSize: 12)),
                                Expanded(child: Divider(thickness: 2)),
                              ],
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isLoading ? null : signInWithGoogle,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Image.asset('assets/myicon/ic_google.png'),
                                    ),
                                    SizedBox(width: 12),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
