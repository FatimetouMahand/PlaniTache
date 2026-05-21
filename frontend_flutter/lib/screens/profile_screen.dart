import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider =
        Provider.of<AuthProvider>(context);

    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Mon profil",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.softShadow,
              ),

              child: Column(
                children: [

                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primaryLight,

                    child: Text(
                      user?.username
                              .substring(0, 1)
                              .toUpperCase() ??
                          "U",

                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    user?.username ?? "Utilisateur",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    user?.email ?? "",
                    style: const TextStyle(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),

              child: Column(
                children: [

                  _tile(
                    Icons.person_outline,
                    "Compte utilisateur",
                  ),

                  _tile(
                    Icons.lock_outline,
                    "Sécurité",
                  ),

                  _tile(
                    Icons.notifications_none,
                    "Notifications",
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () async {

                  await authProvider.logout();

                  if (context.mounted) {
                    Navigator.of(context)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.priorityHigh,

                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(Icons.logout),

                label: const Text(
                  "Déconnexion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),

      title: Text(title),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
    );
  }
}