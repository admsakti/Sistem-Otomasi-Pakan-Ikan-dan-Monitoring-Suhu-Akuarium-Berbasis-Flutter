import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-Up'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          TextField(
            controller: controller.emailC,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          Obx(
            () => TextField(
              controller: controller.passC,
              decoration: InputDecoration(
                labelText: "Password",
                suffix: IconButton(
                  onPressed: () => controller.togglePasswordVisibility(),
                  icon: Icon(controller.isPasswordHidden.value
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              obscureText: controller.isPasswordHidden.value,
              enableSuggestions: false,
              autocorrect: false,
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => authC.signUp(
              controller.emailC.text,
              controller.passC.text,
            ),
            child: const Text("DAFTAR"),
          ),
          const SizedBox(height: 10),
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
