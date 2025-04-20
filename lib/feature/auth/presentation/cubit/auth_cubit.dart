import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:se7eti/core/enum/user_type_enum.dart';
import 'package:se7eti/core/services/local_storage.dart';
import 'package:se7eti/feature/auth/data/models/doctor_model.dart';
import 'package:se7eti/feature/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState());

  login(String email, String password) async {
    emit(AuthLoadingState());
    try {
      var userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user!;
      AppLocalStorage.cacheData(
          key: AppLocalStorage.userToken, value: user.uid);
      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthErrorState("الحساب غير موجود"));
      } else if (e.code == 'wrong-password') {
        emit(AuthErrorState("كلمة المرور غير صحيحة"));
      } else {
        emit(AuthErrorState("حدث خطأ ما."));
      }
    } catch (e) {
      emit(AuthErrorState('حدث خطأ ما.'));
    }
  }

  register(
      {required String name,
      required String email,
      required String password,
      required UserType userType}) async {
    emit(AuthLoadingState());
    try {
      var userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = userCredential.user!;
      user.updateDisplayName(name);
      // store user data into our database
      if (userType == UserType.patient) {
        await FirebaseFirestore.instance
            .collection("patients")
            .doc(user.uid)
            .set({
          'name': name,
          'image': '',
          'age': '',
          'email': email,
          'phone': '',
          'bio': '',
          'city': '',
          'uid': user.uid,
        });
      } else {
        await FirebaseFirestore.instance
            .collection("doctors")
            .doc(user.uid)
            .set({
          'name': name,
          'image': '',
          'specialization': '',
          'rating': 3,
          'email': email,
          'phone1': '',
          'phone2': '',
          'bio': '',
          'openHour': '',
          'closeHour': '',
          'address': '',
          'uid': user.uid,
        });
      }
      AppLocalStorage.cacheData(
          key: AppLocalStorage.userToken, value: user.uid);
      emit(AuthSuccessState());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthErrorState('كلمة المرور ضعيفة.'));
      } else if (e.code == 'email-already-in-use') {
        emit(AuthErrorState('الحساب مستخدم بالفعل.'));
      }
    } catch (e) {
      emit(AuthErrorState('حدث خطأ ما.'));
    }
  }

  updateDoctorRegistration(DoctorModel model) async {
    emit(AuthLoadingState());

    try {
      await FirebaseFirestore.instance
          .collection("doctors")
          .doc(model.uid)
          .update({
        'image': model.image,
        'specialization': model.specialization,
        'phone1': model.phone1,
        'phone2': model.phone2,
        'bio': model.bio,
        'openHour': model.openHour,
        'closeHour': model.closeHour,
        'address': model.address,
      });

      emit(AuthSuccessState());
    } on Exception catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}