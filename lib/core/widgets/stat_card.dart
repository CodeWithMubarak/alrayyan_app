import 'package:flutter/material.dart';

/// بطاقة إحصائية أنيقة
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                (backgroundColor ?? Colors.white),
                (backgroundColor ?? Colors.white).withAlpha(240),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
