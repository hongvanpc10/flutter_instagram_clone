import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/signup_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:instagram/utils/show_snack_bar.dart';
import 'package:instagram/widgets/input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Flexible(flex: 1, child: Container()),
        const _LoginForm(),
        Flexible(flex: 1, child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?"),
            const SizedBox(
              width: 4,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SignupScreen()));
              },
              child: const Text(
                "Sign up.",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
      ])),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({super.key});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().login(
          email: _emailController.text, password: _passwordController.text);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const FeedScreen()));
      }
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (context.mounted) {
        showSnackBar(context, 'Email or password is incorrect');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            Input(
              controller: _emailController,
              hintText: 'Enter your email',
              textInputType: TextInputType.emailAddress,
              validator: (value) =>
                  value!.isEmpty ? 'PLease enter your email' : null,
            ),
            const SizedBox(
              height: 16,
            ),
            Input(
              controller: _passwordController,
              hintText: 'Enter your password',
              obscureText: true,
              validator: (value) =>
                  value!.isEmpty ? 'PLease enter your password' : null,
            ),
            const SizedBox(
              height: 24,
            ),
            GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  _onLogin();
                }
              },
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  height: 64,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Log in',
                          style: TextStyle(color: Colors.white),
                        )),
            )
          ],
        ),
      ),
    );
  }
}
