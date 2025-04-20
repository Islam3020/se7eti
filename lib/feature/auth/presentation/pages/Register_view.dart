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
import 'package:se7eti/feature/auth/presentation/pages/doctor_registeration_view.dart';
import 'package:se7eti/feature/auth/presentation/pages/login_view.dart';
import 'package:se7eti/feature/patient/patient_nav_bar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.userType});
  final UserType userType;

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _displayName = TextEditingController();
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
        leading: const BackButton(),
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
             log('doctor signup');
              pushAndRemoveUntil(context, const DoctorRegistrationView());
            } else {
             log('patient signup');
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'سجل حساب جديد كـ "${handleUserType()}"',
                        style: getTitleStyle(),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: _displayName,
                        style: const TextStyle(color: AppColors.black),
                        decoration: InputDecoration(
                          hintText: 'الاسم',
                          hintStyle: getbodyStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'من فضلك ادخل الاسم';
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        textAlign: TextAlign.end,
                        decoration: const InputDecoration(
                          hintText: 'Sayed@example.com',
                          prefixIcon: Icon(Icons.email_rounded),
                        ),
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
                      const Gap(30),
                      CustomButton(
                        onPressed: () async {
                           if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().register(
                                email: _emailController.text,
                                password: _passwordController.text,
                                name: _displayName.text,
                                userType: widget.userType,
                              );
                        }
                        },
                        text: "تسجيل حساب",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لدي حساب ؟',
                              style: getbodyStyle(color: AppColors.black),
                            ),
                            TextButton(
                                onPressed: () {
                                  pushReplacement(context,
                                      LoginView(userType: widget.userType));
                                },
                                child: Text(
                                  'سجل دخول',
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
}
