import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password Account'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          TextField(
            controller: controller.emailC,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => authC.resetPassword(controller.emailC.text),
            child: const Text("RESET PASSWORD"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sudah punya akun?"),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("LOGIN SEKARANG!"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
