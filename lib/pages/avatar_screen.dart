import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyend/controllers/theme_controller.dart';
import 'package:hyend/userAuth/account_controller.dart';

class AvatarSelectionScreen extends StatelessWidget {
  const AvatarSelectionScreen({super.key});

  static final List<String> avatars = [
    'assets/images/female1.png',
    'assets/images/female2.png',
    'assets/images/female3.png',
    'assets/images/female4.png',
    'assets/images/female5.png',
    'assets/images/female6.png',
    'assets/images/female7.png',
    'assets/images/female8.png',
    'assets/images/female9.png',
    'assets/images/male1.png',
    'assets/images/male2.png',
    'assets/images/male3.png',
    'assets/images/male4.png',
    'assets/images/male5.png',
    'assets/images/male6.png',
    'assets/images/male7.png',
    'assets/images/male8.png',
    'assets/images/male9.png',
    'assets/images/male10.png',
    'assets/images/male11.png',
    'assets/images/male12.png',
    'assets/images/male13.png',
    'assets/images/male14.png',
    'assets/images/male15.png',
    'assets/images/male16.png',
    'assets/images/female10.png',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeController themeCtrl = Get.find<ThemeController>();
    final AccountController accountCtrl = Get.find<AccountController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 0,
          title: const Text('Select Avatar'),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: avatars.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // ✅ FOUR IN A ROW
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final avatarPath = avatars[index];
            // final avatarName =
            //     avatarPath.split('/').last.replaceAll('.png', '');

            return GestureDetector(
              onTap: () {
                final avatarName = avatarPath
                    .split('/')
                    .last
                    .replaceAll('.png', '');

                accountCtrl.setAvatar(avatarName);

                print('Selected avatar: $avatarName');
                Get.back();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    avatarPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
