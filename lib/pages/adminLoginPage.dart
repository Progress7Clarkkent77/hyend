import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/adminAuthController.dart';
import 'package:hyend/controllers/theme_controller.dart';

class EcommerceAdminLoginPage extends StatelessWidget {
  EcommerceAdminLoginPage({super.key});

  final adminAuth = Get.put(AdminAuthController());

  final emailCtrl = TextEditingController();

  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode;

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 450,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark.value ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 70,
                    color: isDark.value ? Colors.white : Colors.black,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Admin Access",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sign in to manage your store",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "RealStore",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Shop Real. Shop Direct."),
                          const SizedBox(height: 4),
                          // Text(
                          //   domainCtrl.fullDomain.value,
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: "Admin Email"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "6-Digit Password",
                      counterText: "",
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark.value
                            ? Colors.white
                            : Colors.black,
                        foregroundColor: isDark.value
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: adminAuth.isLoading.value
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();

                              final password = passwordCtrl.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                Get.snackbar(
                                  "Missing Fields",
                                  "Please fill in email and password",
                                );
                                return;
                              }

                              if (password.length != 6) {
                                Get.snackbar(
                                  "Invalid Password",
                                  "Password must be exactly 6 digits",
                                );
                                return;
                              }

                              await adminAuth.loginAdmin(
                                email: email,
                                password: password,
                              );
                            },
                      child: adminAuth.isLoading.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text("Logging In..."),
                              ],
                            )
                          : const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      "Back To Store",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
