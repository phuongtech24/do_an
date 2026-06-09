import 'package:flutter/material.dart';

class TherapyGuideCard extends StatefulWidget {
  const TherapyGuideCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lightbulb_outline,
    this.accentColor = const Color(0xFF0F8B7F),
    this.dismissible = false,
    this.initiallyVisible = true,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final bool dismissible;
  final bool initiallyVisible;

  @override
  State<TherapyGuideCard> createState() => _TherapyGuideCardState();
}

class _TherapyGuideCardState extends State<TherapyGuideCard> {
  late bool _visible;

  @override
  void initState() {
    super.initState();
    _visible = widget.initiallyVisible;
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.accentColor.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Color(0xFF4F5B5B),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                if (widget.dismissible) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _visible = false),
                      style: TextButton.styleFrom(
                        foregroundColor: widget.accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Đã hiểu'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
