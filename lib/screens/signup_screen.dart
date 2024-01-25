import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:instagram/utils/pick_image.dart';
import 'package:instagram/utils/show_snack_bar.dart';
import 'package:instagram/widgets/input.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(flex: 1, child: Container()),
              const _SignupForm(),
              Flexible(flex: 1, child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: () => {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen()))
                    },
                    child: const Text(
                      "Log in.",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
            ]),
      ),
    );
  }
}

class _SignupForm extends StatefulWidget {
  const _SignupForm({super.key});

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signup(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          file: _image!);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.message!);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectImage() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/instagram.svg',
              height: 48,
            ),
            const SizedBox(
              height: 36,
            ),
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 56,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : const CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(
                            'https://st3.depositphotos.com/9998432/13335/v/450/depositphotos_133351928-stock-illustration-default-placeholder-man-and-woman.jpg'),
                      ),
                Positioned(
                  bottom: -6,
                  right: 0,
                  child: IconButton(
                      onPressed: () {
                        _selectImage();
                      },
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.black54,
                      )),
                )
              ],
            ),
            const SizedBox(
              height: 28,
            ),
            Input(
              controller: _usernameController,
              hintText: 'Enter your username',
            ),
            const SizedBox(
              height: 16,
            ),
            Input(
              controller: _emailController,
              hintText: 'Enter your email',
              textInputType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 16,
            ),
            Input(
              controller: _passwordController,
              hintText: 'Enter your password',
              obscureText: true,
            ),
            const SizedBox(
              height: 24,
            ),
            GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  _onSignup();
                }
              },
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 64,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(color: Colors.white),
                        )),
            )
          ],
        ),
      ),
    );
  }
}
