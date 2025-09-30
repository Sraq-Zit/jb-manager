import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final String currency;
  final Color color;
  final Color subColor;
  final IconData footerIcon;
  final String footerName;
  final String footerValue;

  const CustomCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.footerName,
    required this.footerValue,
    this.footerIcon = LucideIcons.arrowUpRight,
    this.subColor = Colors.green,
    this.currency = 'DH',
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), // Transparent background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 16,
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color.lerp(subColor, Colors.white, 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Color.lerp(subColor, Colors.black, 0.2),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12, // text-xs
                  fontWeight: FontWeight.w500, // font-medium
                  color: Color(0xFF6B7280), // text-gray-500
                  letterSpacing: 1.2, // uppercase letter spacing
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: value,
                            style: TextStyle(
                              fontSize: 18, // text-lg
                              fontWeight: FontWeight.w900, // font-bold
                              color: Colors.grey.shade900, // text-gray-900
                            ),
                          ),
                          TextSpan(
                            text: ' ',
                          ), // Space between value and currency
                          WidgetSpan(
                            baseline: TextBaseline.alphabetic,
                            alignment: PlaceholderAlignment.aboveBaseline,
                            child: Text(
                              currency,
                              style: TextStyle(
                                fontSize: 12, // text-xs
                                color: Colors.grey.shade500, // text-gray-500
                                height:
                                    1.0, // Adjust height for superscript alignment
                              ),
                            ),
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(footerIcon, size: 16, color: Colors.grey[400]),
                        Text(
                          footerName,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          footerValue,
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
