import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // Header: Avatar & Name
          if (user != null)
            Center(
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 50,
                     backgroundColor: Colors.deepPurple.shade100,
                     child: Text(
                       user.email?.substring(0, 1).toUpperCase() ?? 'U',
                       style: const TextStyle(fontSize: 40, color: Colors.deepPurple),
                     ),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     user.displayName ?? 'User',
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     user.email ?? '',
                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                   ),
                ],
              ),
            )
          else
            Center(
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Вы не авторизованы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Войти / Зарегистрироваться'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          
          // Options List
          const Divider(),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('My Listings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (user == null) {
                context.push('/login');
              } else {
                context.push('/my-listings');
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Balance & Payments'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Text('EN'),
            onTap: () {},
          ),
          const Divider(),
          const SizedBox(height: 32),
          
          // Logout Button
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(loginProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Log Out', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
