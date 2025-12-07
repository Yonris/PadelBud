import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padel_bud/core/app_localizations.dart';
import 'package:padel_bud/models/search_request.dart';
import 'package:padel_bud/presentation/pages/booking_page.dart';
import 'package:padel_bud/presentation/widgets/club_image_widget.dart';
import '../../models/club_model.dart';

class CourtCard extends StatelessWidget {
  final ClubModel club;
  final GeoPoint? userLocation;

  const CourtCard({
    required this.club,
    this.userLocation,
    Key? key,
  }) : super(key: key);

  String _getDistanceText() {
    if (userLocation == null) return '';
    
    final distanceKm = SearchRequestModel.getDistanceToClub(userLocation!, club);
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = _getDistanceText();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.shade600,
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Club Image section
            ClubImageWidget(
              club: club,
              width: 55,
              height: 55,
              borderRadius: 12,
            ),

            const SizedBox(width: 16),

            // Club info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (distanceText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        distanceText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Book Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BookingPage(club: club),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context).bookCourt,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
