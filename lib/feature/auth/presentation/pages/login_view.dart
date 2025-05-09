import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:se7eti/core/enum/user_type_enum.dart';
import 'package:se7eti/core/functions/dialogs.dart';
import 'package:se7eti/core/functions/email_validate.dart';
import 'package:se7eti/core/functions/navigation.dart';
import 'package:se7eti/core/utils/colors.dart';
import 'package:se7eti/core/utils/text_style.dart';
import 'package:se7eti/core/widgets/custom_button.dart';
import 'package:se7eti/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:se7eti/feature/auth/presentation/cubit/auth_state.dart';
import 'package:se7eti/feature/auth/presentation/pages/Register_view.dart';
import 'package:se7eti/feature/doctor/nav_bar_widget.dart';
import 'package:se7eti/feature/patient/patient_nav_bar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.userType});
  final UserType userType;

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isVisible = true;

  String handleUserType() {
    return widget.userType == UserType.doctor ? 'دكتور' : 'مريض';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: const BackButton(
          color: AppColors.color1,
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
              Navigator.pop(context);
              showErrorDialog(context, state.error);
            } else if (state is AuthLoadingState) {
              showLoadingDialog(context);
            } else if (state is AuthSuccessState) {
              if (widget.userType == UserType.doctor) {
                log('doctor');
                pushAndRemoveUntil(context, const DoctorNavBar());
              } else {
               log('patient');
                pushAndRemoveUntil(context, const PatientNavBarWidget());
              }
            }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'سجل دخول الان كـ "${handleUserType()}"',
                        style: getTitleStyle(),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        textAlign: TextAlign.end,
                        decoration: const InputDecoration(
                          hintText: 'Sayed@example.com',
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'من فضلك ادخل الايميل';
                          } else if (!emailValidate(value)) {
                            return 'من فضلك ادخل الايميل صحيحا';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        textAlign: TextAlign.end,
                        style: const TextStyle(color: AppColors.black),
                        obscureText: isVisible,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          hintText: '********',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon((isVisible)
                                  ? Icons.remove_red_eye
                                  : Icons.visibility_off_rounded)),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.isEmpty) return 'من فضلك ادخل كلمة السر';
                          return null;
                        },
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(top: 5, right: 10),
                        child: Text(
                          'نسيت كلمة السر ؟',
                          style: getSmallStyle(),
                        ),
                      ),
                      const Gap(20),
                      CustomButton(
                        onPressed: () async {
                           if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                          }
                        },
                        text: "تسجيل الدخول",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لدي حساب ؟',
                              style: getbodyStyle(color: AppColors.black),
                            ),
                            TextButton(
                                onPressed: () {
                                  pushReplacement(context,
                                      RegisterView(userType: widget.userType));
                                },
                                child: Text(
                                  'سجل الان',
                                  style: getbodyStyle(color: AppColors.color1),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
