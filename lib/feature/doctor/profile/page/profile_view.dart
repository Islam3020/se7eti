import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se7eti/core/utils/colors.dart';
import 'package:se7eti/core/utils/text_style.dart';
import 'package:se7eti/feature/doctor/profile/page/settings_view.dart';
import 'package:se7eti/feature/patient/profile/widgets/appointments_list.dart';
import 'package:se7eti/feature/patient/search/widgets/item_tile.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfileView> {
  String? _imagePath;
  File? file;
  String? profileUrl;

  String? userId;


  @override
  void initState() {
    super.initState();
    _getUser();
  }



  Future<void> _getUser() async {
    userId = FirebaseAuth.instance.currentUser?.uid;
    setState(() {}); // لتحديث الـ state بعد الحصول على userId
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
        backgroundColor: AppColors.color1,
        elevation: 0,
        title: const Text(
          'الحساب الشخصي',
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.settings,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (contex) => const UserSettings()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              var userData = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.white,
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.white,
                                    radius: 60,
                                    backgroundImage: (userData?['image'] != '')
                                        ? NetworkImage(userData?['image'])
                                        : (_imagePath != null)
                                            ? FileImage(File(_imagePath!))
                                                as ImageProvider
                                            : const AssetImage(
                                                'assets/images/doc.png'),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await _pickImage(); // يفتح الجاليري
                                    if (file != null) {
                                      final url = await uploadImageToCloudinary(
                                          file!); // رفع للصورة
                                      if (url != null) {
                                        await FirebaseFirestore.instance
                                            .collection('doctors')
                                            .doc(userId)
                                            .update({'image': url}); // تحديث الصورة في Firestore

                                        setState(() {
                                          profileUrl = url;
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم تحديث الصورة بنجاح')),
                                        );
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
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 20,
                                      // color: AppColors.color1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${userData!['name']}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: getTitleStyle(),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    userData['specialization'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: getbodyStyle(),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          "نبذه تعريفيه",
                          style: getbodyStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          userData['bio'] == '' ? 'لم تضاف' : userData['bio'],
                          style: getSmallStyle(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "معلومات التواصل",
                          style: getbodyStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.accentColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TileWidget(
                                  text: userData['email'] ?? 'لم تضاف',
                                  icon: Icons.email),
                              const SizedBox(
                                height: 15,
                              ),
                              TileWidget(
                                  text: userData['phone1'], icon: Icons.call),
                            ],
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.accentColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TileWidget(
                                  text:
                                      '${userData['openHour']}:00 - ${userData['closeHour']}:00',
                                  icon: Icons.email),
                              const SizedBox(
                                height: 15,
                              ),
                              TileWidget(
                                  text: userData['phone1'], icon: Icons.call),
                            ],
                          ),
                        ),
                        Text(
                          "حجوزاتي",
                          style: getbodyStyle(fontWeight: FontWeight.w600),
                        ),
                        const MyAppointmentsHistory()
                      ],
                    )),
              );
            }),
      ),
    );
  }
}
