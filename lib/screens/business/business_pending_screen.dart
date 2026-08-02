import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'business_dashboard.dart';

class BusinessPendingScreen extends StatefulWidget {
  const BusinessPendingScreen({super.key});

  @override
  State<BusinessPendingScreen> createState() =>
      _BusinessPendingScreenState();
}

class _BusinessPendingScreenState extends State<BusinessPendingScreen> {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  Timer? timer;
  bool checking = false;
  String? lastError;

  @override
  void initState() {
    super.initState();
    checkStatus();
    startChecking();
  }

  void startChecking() {
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkStatus(),
    );
  }

  Future<void> checkStatus() async {
    if (checking) return;
    if (mounted) setState(() => checking = true);

    try {
      final data = await ApiService.getCurrentUser();
      final user = data?['user'];
      final profile = user is Map ? user['businessProfile'] : null;
      final status = profile is Map
          ? profile['verificationStatus']?.toString().toLowerCase()
          : null;

      if (!mounted) return;

      setState(() => lastError = null);

      if (status == 'approved') {
        timer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessDashboard()),
        );
      }
    } catch (error) {
      if (mounted) setState(() => lastError = error.toString());
      debugPrint('BUSINESS STATUS CHECK ERROR: $error');
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        elevation: 0,
        title: const Text(
          'Application Status',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _cream,
                  shape: BoxShape.circle,
                  border: Border.all(color: _mint, width: 12),
                  boxShadow: [
                    BoxShadow(
                      color: _emerald.withOpacity(0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      size: 64,
                      color: _emerald,
                    ),
                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: _emerald,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Your application is under review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'BioPet is checking your business information. This page will open your seller dashboard automatically after approval.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF60736E),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2ECE7)),
                ),
                child: const Column(
                  children: [
                    _StatusStep(
                      icon: Icons.check_circle_rounded,
                      title: 'Application submitted',
                      subtitle: 'Your details were sent successfully.',
                      completed: true,
                    ),
                    _StepLine(),
                    _StatusStep(
                      icon: Icons.manage_search_rounded,
                      title: 'Admin review',
                      subtitle: 'Verification is currently in progress.',
                      active: true,
                    ),
                    _StepLine(),
                    _StatusStep(
                      icon: Icons.verified_rounded,
                      title: 'Seller dashboard',
                      subtitle: 'Available immediately after approval.',
                    ),
                  ],
                ),
              ),
              if (lastError != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Status could not be refreshed. Check your connection and try again.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: checking ? null : checkStatus,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _emerald,
                    side: const BorderSide(color: _emerald),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _emerald,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    checking ? 'Checking status...' : 'Check Now',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool completed;
  final bool active;

  const _StatusStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.completed = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed || active
        ? const Color(0xFF065F46)
        : const Color(0xFFAEBBB6);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: completed
                ? const Color(0xFFA7F3D0).withOpacity(0.45)
                : active
                    ? const Color(0xFFFFF8E7)
                    : const Color(0xFFF0F3F1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6A7C76),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      width: 2,
      margin: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
      color: const Color(0xFFDCE7E2),
    );
  }
}
