import 'package:flutter/material.dart';

/// Premium explainer for the service fee.
///
/// Lists what the fee covers and how it is settled. The product page uses the
/// short version ([explainWhatsApp] = false: only a hint that the fee is agreed
/// before the order is placed); the cart and checkout use the full version,
/// which walks the customer through the WhatsApp confirmation.
class ServiceFeeNotice extends StatelessWidget {
  const ServiceFeeNotice({
    super.key,
    required this.tile,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    this.explainWhatsApp = false,
  });

  final Color tile;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;

  /// true  = cart / checkout: full explanation including the WhatsApp step.
  /// false = product page: covers list + "agreed before you order" hint only.
  final bool explainWhatsApp;

  static const _covers = <_Cover>[
    _Cover(
      Icons.local_shipping_outlined,
      'Shipping & freight',
      'Moving your goods from our suppliers to us.',
    ),
    _Cover(
      Icons.assignment_turned_in_outlined,
      'Customs clearing',
      'Clearing, documentation and port handling.',
    ),
    _Cover(
      Icons.inventory_2_outlined,
      'Handling & logistics',
      'Packing, sorting and other handling charges.',
    ),
    _Cover(
      Icons.location_on_outlined,
      'Delivery to you',
      'To your chosen location, within or outside Enugu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tile,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ──
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(Icons.receipt_long_rounded, size: 17, color: onAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About the service fee',
                      style: TextStyle(
                        color: text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'What it covers, and how it is settled',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: border),
          const SizedBox(height: 14),

          // ── what it covers ──
          Text(
            'WHAT IT COVERS',
            style: TextStyle(
              color: muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          for (final c in _covers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(c.icon, size: 18, color: text),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: TextStyle(
                            color: text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          c.subtitle,
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (explainWhatsApp) ...[
            const SizedBox(height: 4),
            Divider(height: 1, color: border),
            const SizedBox(height: 14),
            Text(
              'HOW IT IS SETTLED',
              style: TextStyle(
                color: muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            _step(
              1,
              'Send your order',
              'Place your order and it opens in WhatsApp, ready to send to us.',
            ),
            _step(
              2,
              'Agree the service fee',
              'In the chat we confirm your delivery location and agree the '
                  'service fee with you.',
            ),
            _step(
              3,
              'Pay and we process',
              'Once the fee is agreed, you pay the full amount and your '
                  'order is activated.',
              last: true,
            ),
            const SizedBox(height: 14),
            _note(
              Icons.info_outline_rounded,
              'The total shown here is for your goods only. The service fee '
              'is added once it has been agreed on WhatsApp.',
            ),
          ] else ...[
            const SizedBox(height: 4),
            _note(
              Icons.verified_outlined,
              'The service fee is agreed with you before your order is '
              'placed, so there are no surprises.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _step(int n, String title, String body, {bool last = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    color: onAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    body,
                    style: TextStyle(color: muted, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: text),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: text,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover {
  const _Cover(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}
