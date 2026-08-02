import 'package:flutter/material.dart';

class SellerProfileScreen extends StatelessWidget {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  final String ownerName;
  final String email;
  final String businessName;
  final String businessType;
  final String businessAddress;

  const SellerProfileScreen({
    super.key,
    this.ownerName = 'Business Owner',
    this.email = '',
    this.businessName = 'My Pet Business',
    this.businessType = 'Pet Business',
    this.businessAddress = 'Business location not set',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        elevation: 0,
        title: const Text(
          'Seller Profile',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_emerald, Color(0xFF0B7A5B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: _emerald.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 11),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _cream,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.65),
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: _emerald,
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    ownerName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFD9FFF1)),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: _mint,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Approved seller',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Business details',
              style: TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2ECE7)),
              ),
              child: Column(
                children: [
                  _ProfileItem(
                    icon: Icons.storefront_rounded,
                    label: 'Business name',
                    value: businessName,
                  ),
                  const Divider(height: 27, color: Color(0xFFE8EFEB)),
                  _ProfileItem(
                    icon: Icons.category_outlined,
                    label: 'Business type',
                    value: businessType,
                  ),
                  const Divider(height: 27, color: Color(0xFFE8EFEB)),
                  _ProfileItem(
                    icon: Icons.location_on_outlined,
                    label: 'Shop address',
                    value: businessAddress,
                    multiline: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _mint.withOpacity(0.30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _mint),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: _emerald),
                  SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep your shop information accurate',
                          style: TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Correct details help customers trust your shop and receive their orders without delays.',
                          style: TextStyle(
                            color: Color(0xFF526B64),
                            height: 1.4,
                          ),
                        ),
                      ],
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

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF065F46), size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF71847D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF102A24),
                  fontWeight: FontWeight.w800,
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
