import 'package:biopet/services/api_service.dart';
import 'package:flutter/material.dart';

import '../../services/business_service.dart';
import 'business_pending_screen.dart';

class BusinessSubmitScreen extends StatefulWidget {
  const BusinessSubmitScreen({super.key});

  @override
  State<BusinessSubmitScreen> createState() => _BusinessSubmitScreenState();
}

class _BusinessSubmitScreenState extends State<BusinessSubmitScreen> {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  bool loading = false;
  final BusinessService service = BusinessService();

  Future<void> submit() async {
    if (loading) return;
    setState(() => loading = true);

    try {
      final token = await ApiService.getToken();

      if (token == null) {
        if (mounted) {
          _showMessage('Your session has expired. Please sign in again.');
        }
        return;
      }

      final success = await service.submitBusiness(token);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BusinessPendingScreen()),
        );
      } else {
        _showMessage('Application submission failed. Please try again.');
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to submit application: $error');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink,
      ),
    );
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
          'Submit Application',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_mint, _cream],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _emerald.withOpacity(0.13),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 66,
                  color: _emerald,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Everything is ready',
                style: TextStyle(
                  color: _ink,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Review the checklist below, then submit your business for admin verification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF60736E),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: const Color(0xFFE2ECE7)),
                ),
                child: const Column(
                  children: [
                    _ReadyItem(
                      icon: Icons.handshake_outlined,
                      title: 'Agreement accepted',
                    ),
                    Divider(height: 26, color: Color(0xFFE8EFEB)),
                    _ReadyItem(
                      icon: Icons.location_on_outlined,
                      title: 'Shop location selected',
                    ),
                    Divider(height: 26, color: Color(0xFFE8EFEB)),
                    _ReadyItem(
                      icon: Icons.store_mall_directory_outlined,
                      title: 'Business information complete',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _cream,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF1E4BF)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: _emerald),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'After submission, your application cannot be edited until the review is complete.',
                        style: TextStyle(color: _ink, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emerald,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _emerald.withOpacity(0.42),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    loading ? 'Submitting...' : 'Submit for Review',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
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

class _ReadyItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ReadyItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFA7F3D0).withOpacity(0.42),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF065F46), size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF102A24),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF065F46),
          size: 22,
        ),
      ],
    );
  }
}
