import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log-In'),
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.RESET_PASSWORD),
              child: const Text("Reset Password!"),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => authC.logIn(
              controller.emailC.text,
              controller.passC.text,
            ),
            child: const Text("LOGIN"),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Belum punya akun?"),
              TextButton(
                onPressed: () => Get.toNamed(Routes.SIGNUP),
                child: const Text("DAFTAR SEKARANG!"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
