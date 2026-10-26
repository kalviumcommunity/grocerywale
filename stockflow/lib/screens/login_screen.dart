import 'package:flutter/material.dart';
import '../models/store_info.dart';
import '../services/inventory_service.dart';
import '../widgets/app_button.dart';
import 'home_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'sarah.jenkins@grocerywale.com');
  final _passwordController = TextEditingController(text: '••••••••');
  final inventoryService = InventoryService();
  UserRole _selectedRole = UserRole.storeManager;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    inventoryService.setRole(_selectedRole);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeShellScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockFlow'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Shared replenishment pipeline & fast-moving stock management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 28),

              // Role Selection Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.storeManager;
                            _emailController.text = 'sarah.jenkins@grocerywale.com';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.storeManager
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedRole == UserRole.storeManager
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront,
                                size: 18,
                                color: _selectedRole == UserRole.storeManager
                                    ? const Color(0xFF2563EB)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Store Manager',
                                style: TextStyle(
                                  fontWeight: _selectedRole == UserRole.storeManager
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedRole == UserRole.storeManager
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = UserRole.warehouseManager;
                            _emailController.text = 'marcus.vance@grocerywale.com';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.warehouseManager
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedRole == UserRole.warehouseManager
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warehouse_outlined,
                                size: 18,
                                color: _selectedRole == UserRole.warehouseManager
                                    ? const Color(0xFF2563EB)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Central Warehouse',
                                style: TextStyle(
                                  fontWeight: _selectedRole == UserRole.warehouseManager
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedRole == UserRole.warehouseManager
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),

              const SizedBox(height: 24),

              AppButton(
                text: 'Login to ${_selectedRole == UserRole.storeManager ? "Store Manager" : "Warehouse Hub"}',
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 16),

              // Demo quick switcher card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demo Accounts:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Store Manager: Sarah Jenkins (Metro Downtown STR-101)\n• Warehouse Supervisor: Marcus Vance (Central Hub)',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact your chain IT administrator to register new store accounts.'),
                    ),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
