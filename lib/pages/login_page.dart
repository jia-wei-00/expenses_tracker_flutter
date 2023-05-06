import 'package:expenses_tracker/components/text.dart';
import 'package:expenses_tracker/cubit/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 50),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage("assets/images/logo.png"),
                      width: 200,
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 50, right: 50, bottom: 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30, right: 30, left: 30),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.person),
                                  prefixIconColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please enter your email address';
                                  }
                                  // Validate email format here
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  prefixIconColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please enter your password';
                                  }
                                  // Validate password strength here
                                  return null;
                                },
                                onFieldSubmitted: (_) => context
                                    .read<AuthCubit>()
                                    .signIn(_emailController.text,
                                        _passwordController.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    state is AuthLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              SizedBox(
                                width: 220,
                                child: ElevatedButton(
                                  onPressed: () => context
                                      .read<AuthCubit>()
                                      .signIn(_emailController.text,
                                          _passwordController.text),
                                  child: const Text('Login'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: mediumFont("or"),
                              ),
                              SizedBox(
                                width: 220,
                                child: state is AuthSuccess
                                    ? ElevatedButton(
                                        onPressed: () =>
                                            context.read<AuthCubit>().logOut(),
                                        child: const Text("Logout"),
                                      )
                                    : ElevatedButton(
                                        onPressed: () => context
                                            .read<AuthCubit>()
                                            .googleSignIn(),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Image(
                                              image: AssetImage(
                                                  'assets/images/google.png'),
                                              width: 15,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('Sign in with Google'),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
