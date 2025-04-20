import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:se7eti/core/constants/specialization_data.dart';
import 'package:se7eti/core/functions/dialogs.dart';
import 'package:se7eti/core/functions/navigation.dart';
import 'package:se7eti/core/utils/colors.dart';
import 'package:se7eti/core/utils/text_style.dart';
import 'package:se7eti/core/widgets/custom_button.dart';
import 'package:se7eti/feature/auth/data/models/doctor_model.dart';
import 'package:se7eti/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:se7eti/feature/auth/presentation/cubit/auth_state.dart';
import 'package:se7eti/feature/doctor/nav_bar_widget.dart';

class DoctorRegistrationView extends StatefulWidget {
  const DoctorRegistrationView({super.key});

  @override
  _DoctorRegistrationViewState createState() => _DoctorRegistrationViewState();
}

class _DoctorRegistrationViewState extends State<DoctorRegistrationView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _phone1 = TextEditingController();
  final TextEditingController _phone2 = TextEditingController();
  String _specialization = specialization[0];

  late String _startTime =
      DateFormat('hh').format(DateTime(2023, 9, 7, 10, 00));
  late String _endTime = DateFormat('hh').format(DateTime(2023, 9, 7, 22, 00));

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  String? _imagePath;
  File? file;
  String? profileUrl;

  String? userID;

  Future<void> _getUser() async {
    userID = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _pickImage() async {
    _getUser();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        file = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      String cloudName = 'dubu310vx'; // Cloudinary cloud name
      String uploadPreset = 'profile_images'; // Your preset name

      String url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': uploadPreset,
      });

      Response response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      } else {
        print('Upload failed: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إكمال عملية التسجيل'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessState) {
            Navigator.pop(context);
          log( 'doctor signup');
           pushAndRemoveUntil(context, const DoctorNavBar());
          } else if (state is AuthErrorState) {
            Navigator.pop(context);
            showErrorDialog(context, state.error);
          } else if (state is AuthLoadingState) {
            showLoadingDialog(context);
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            // backgroundColor: AppColors.lightBg,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: (_imagePath != null)
                                  ? FileImage(File(_imagePath!))
                                  : const AssetImage('assets/images/doc.png'),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _pickImage(); // يفتح الجاليري
                              if (file != null) {
                                final url = await uploadImageToCloudinary(
                                    file!); // رفع للصورة
                                if (url != null) {
                                  setState(() {
                                    profileUrl = url; // خزن لينك الصورة
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('حدث خطأ أثناء رفع الصورة'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 20,
                                // color: AppColors.color1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        child: Row(
                          children: [
                            Text(
                              'التخصص',
                              style: getbodyStyle(color: AppColors.black),
                            )
                          ],
                        ),
                      ),
                      // التخصص---------------
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppColors.accentColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: DropdownButton(
                          isExpanded: true,
                          iconEnabledColor: AppColors.color1,
                          icon: const Icon(Icons.expand_circle_down_outlined),
                          value: _specialization,
                          onChanged: (String? newValue) {
                            setState(() {
                              _specialization = newValue ?? specialization[0];
                            });
                          },
                          items: specialization.map((element) {
                            return DropdownMenuItem(
                              value: element,
                              child: Text(element),
                            );
                          }).toList(),
                        ),
                      ),
                      const Gap(10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'نبذة تعريفية',
                              style: getbodyStyle(color: AppColors.black),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        maxLines: 5,
                        controller: _bio,
                        style: const TextStyle(color: AppColors.black),
                        decoration: const InputDecoration(
                            hintText:
                                'سجل المعلومات الطبية العامة مثل تعليمك الأكاديمي وخبراتك السابقة...'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'من فضلك ادخل النبذة التعريفية';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'عنوان العيادة',
                              style: getbodyStyle(color: AppColors.black),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _address,
                        style: const TextStyle(color: AppColors.black),
                        decoration: const InputDecoration(
                          hintText: '5 شارع مصدق - الدقي - الجيزة',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'من فضلك ادخل عنوان العيادة';
                          } else {
                            return null;
                          }
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'ساعات العمل من',
                                    style: getbodyStyle(color: AppColors.black),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'الي',
                                    style: getbodyStyle(color: AppColors.black),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // ---------- Start Time ----------------
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      await showStartTimePicker();
                                    },
                                    icon: const Icon(
                                      Icons.watch_later_outlined,
                                      color: AppColors.color1,
                                    )),
                                hintText: _startTime,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),

                          // ---------- End Time ----------------
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      await showEndTimePicker();
                                    },
                                    icon: const Icon(
                                      Icons.watch_later_outlined,
                                      color: AppColors.color1,
                                    )),
                                hintText: _endTime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'رقم الهاتف 1',
                              style: getbodyStyle(color: AppColors.black),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _phone1,
                        style: const TextStyle(color: AppColors.black),
                        decoration: const InputDecoration(
                          hintText: '+20xxxxxxxxxx',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'من فضلك ادخل الرقم';
                          } else {
                            return null;
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'رقم الهاتف 2 (اختياري)',
                              style: getbodyStyle(color: AppColors.black),
                            )
                          ],
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _phone2,
                        style: const TextStyle(color: AppColors.black),
                        decoration: const InputDecoration(
                          hintText: '+20xxxxxxxxxx',
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.only(top: 25.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomButton(
            onPressed: () async {
              if (file == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('من فضلك قم بتحميل صورتك الشخصية')),
    );
    return;
  }

  if (_formKey.currentState!.validate()) {
    profileUrl = await uploadImageToCloudinary(file!); // <-- هنا التعديل

    if (profileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحميل الصورة')),
      );
      return;
    }

    context.read<AuthCubit>().updateDoctorRegistration(DoctorModel(
          uid: userID,
          image: profileUrl,
          phone1: _phone1.text,
          phone2: _phone2.text,
          address: _address.text,
          specialization: _specialization,
          openHour: _startTime,
          closeHour: _endTime,
          bio: _bio.text,
        ));
  }
            },
            text: "التسجيل",
          ),
        ),
      ),
    );
  }

  showStartTimePicker() async {
    final startTimePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTimePicked != null) {
      setState(() {
        _startTime = startTimePicked.hour.toString();
      });
    }
  }

  showEndTimePicker() async {
    final endTimePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          DateTime.now().add(const Duration(minutes: 15))),
    );

    if (endTimePicked != null) {
      setState(() {
        _endTime = endTimePicked.hour.toString();
      });
    }
  }
}
