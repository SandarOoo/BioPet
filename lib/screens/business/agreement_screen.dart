import 'package:biopet/services/api_service.dart';
import 'package:flutter/material.dart';

import '../../services/business_service.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  bool accepted = false;
  bool loading = false;

  final BusinessService service = BusinessService();

  Future<void> submit() async {
    if (!accepted) {
      _showMessage('Please accept the agreement to continue.');
      return;
    }

    setState(() => loading = true);

    try {
      final token = await ApiService.getToken();

      if (token == null) {
        if (mounted) _showMessage('Your session has expired. Please sign in again.');
        return;
      }

      final success = await service.acceptAgreement(token);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/business-location');
      } else {
        _showMessage('Failed to accept the agreement. Please try again.');
      }
    } catch (error) {
      if (mounted) _showMessage('Something went wrong: $error');
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
    const terms = <_AgreementTermData>[
      _AgreementTermData(
        icon: Icons.badge_outlined,
        title: 'Correct information',
        description: 'Provide accurate owner and shop information.',
      ),
      _AgreementTermData(
        icon: Icons.location_on_outlined,
        title: 'Real shop location',
        description: 'The selected location must match the actual shop.',
      ),
      _AgreementTermData(
        icon: Icons.verified_user_outlined,
        title: 'Verification',
        description: 'BioPet may review and verify submitted information.',
      ),
      _AgreementTermData(
        icon: Icons.report_gmailerrorred_outlined,
        title: 'Honest application',
        description:
            'False information may result in rejection or account action.',
      ),
      _AgreementTermData(
        icon: Icons.manage_accounts_outlined,
        title: 'Owner responsibility',
        description:
            'Business owners are responsible for keeping shop data correct.',
      ),
    ];

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        elevation: 0,
        title: const Text(
          'Business Agreement',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_emerald, Color(0xFF0C7B5D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: _emerald.withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          _AgreementHeroIcon(),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'A trusted marketplace starts here',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  'Please review these rules before setting up your BioPet business.',
                                  style: TextStyle(
                                    color: Color(0xFFD9FFF1),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Owner responsibilities',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...terms.map(
                      (term) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE3ECE7)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _mint.withOpacity(0.42),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(term.icon, color: _emerald, size: 22),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    term.title,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    term.description,
                                    style: const TextStyle(
                                      color: Color(0xFF60736E),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5ECE8))),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: loading
                        ? null
                        : () => setState(() => accepted = !accepted),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accepted ? _mint.withOpacity(0.34) : _cream,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: accepted,
                            activeColor: _emerald,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: loading
                                ? null
                                : (value) =>
                                    setState(() => accepted = value ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'I have read and agree to the terms and conditions.',
                              style: TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _emerald,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _emerald.withOpacity(0.42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      icon: loading
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        loading ? 'Saving...' : 'Accept & Continue',
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
          ],
        ),
      ),
    );
  }
}

class _AgreementHeroIcon extends StatelessWidget {
  const _AgreementHeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(21),
      ),
      child: const Icon(
        Icons.handshake_outlined,
        color: Color(0xFF065F46),
        size: 34,
      ),
    );
  }
}


class _AgreementTermData {
  final IconData icon;
  final String title;
  final String description;

  const _AgreementTermData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
