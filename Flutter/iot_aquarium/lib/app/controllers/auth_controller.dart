import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<User?> get streamAuthStatus => auth.authStateChanges();

  // signUp
  void signUp(String email, String password) async {
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.sendEmailVerification();
      Get.defaultDialog(
        title: "Verifikasi Email!",
        middleText:
            "Email verifikasi telah dikirimkan, segera lakukan verifikasi!",
        textConfirm: "Ya, saya mengerti!",
        onConfirm: () {
          Get.back(); // menutup dialog
          Get.back(); // menuju halaman login
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Get.defaultDialog(
          title: "An Error Occured!",
          middleText: "The password provided is too weak.",
        );
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Get.defaultDialog(
          title: "An Error Occured!",
          middleText: "The account already exists for that email.",
        );
      }
    } catch (e) {
      print(e);
      Get.defaultDialog(
        title: "An Error Occured!",
        middleText: "Tidak dapat mendaftarkan akun email ini!",
      );
    }
  }

  // logIn
  void logIn(String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user!.emailVerified) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.defaultDialog(
          title: "Verifikasi Email!",
          middleText:
              "Lakukan verifikasi terlebih dahulu. Apakah ingin dikirimkan ulang email verifikasi?",
          onConfirm: () async {
            // tidak bisa mengirim ulang email secara terus-menerus! harus restart aplikasi
            await credential.user!.sendEmailVerification();
            Get.back();
          },
          textConfirm: "Kirim ulang email verifikasi!",
          textCancel: "Kembali",
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        Get.defaultDialog(
          title: "An Error Occured!",
          middleText: "No user found for that email.",
        );
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Get.defaultDialog(
          title: "An Error Occured!",
          middleText: "Wrong password provided for that user.",
        );
      }
    } catch (e) {
      print(e);
      Get.defaultDialog(
        title: "An Error Occured!",
        middleText: "Tidak dapat login dengan akun ini!",
      );
    }
  }

  // logOut
  void logOut() async {
    await auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  // resetPassword
  void resetPassword(String email) async {
    if (email != "" && GetUtils.isEmail(email)) {
      try {
        await auth.sendPasswordResetEmail(email: email);
        Get.defaultDialog(
          title: "Berhasil!",
          middleText: "Email reset password telah dikirimkan ke $email!",
          onConfirm: () {
            Get.back(); // menutup dialog
            Get.back(); // menuju halaman login
          },
          textConfirm: "Ya, saya mengerti!",
        );
      } catch (e) {
        print(e);
        Get.defaultDialog(
          title: "An Error Occured!",
          middleText: "Tidak dapat melakukan reset password pada akun ini!",
        );
      }
    } else {
      Get.defaultDialog(
        title: "An Error Occured!",
        middleText: "Email tidak valid!",
      );
    }
  }
}
