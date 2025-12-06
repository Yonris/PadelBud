import 'package:flutter/material.dart';
import '../../models/club_model.dart';

class ClubImageWidget extends StatelessWidget {
  final ClubModel club;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ClubImageWidget({
    required this.club,
    this.width = 55,
    this.height = 55,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: club.imageUrl != null && club.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              child: Image.network(
                club.imageUrl!,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackIcon();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: width * 0.4,
                      height: height * 0.4,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        Icons.sports_tennis,
        size: width * 0.6,
        color: Colors.blue,
      ),
    );
  }
}
