/* dart */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* enum */
import '../enums/expire_status.dart';

/* styles */
import '../app_styles.dart' as styles;

class ExpireClip extends StatelessWidget {
  ExpireStatus expireStatus;
  DateTime expiration;

  ExpireClip(this.expireStatus, this.expiration);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: expireStatus == ExpireStatus.Expired
                ? Colors.red.shade600
                : expireStatus == ExpireStatus.ExpiringToday
                    ? Colors.yellow.shade400
                    : Colors.black,
            width: 1),
        borderRadius: BorderRadius.circular(5.0),
        color: expireStatus == ExpireStatus.Expired
            ? Colors.redAccent.withOpacity(0.7)
            : expireStatus == ExpireStatus.ExpiringToday
                ? Colors.yellow.withOpacity(0.7)
                : Colors.grey.withOpacity(0.7),
      ),
      padding: EdgeInsets.symmetric(vertical: 1, horizontal: 15),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          expireStatus == ExpireStatus.Expired
              ? "Expired"
              : expireStatus == ExpireStatus.ExpiringToday
                  ? "Expiring today"
                  : 'Exp: ${DateFormat('dd MMM yyyy').format(expiration)}',
          style: TextStyle(color: Colors.black87, fontFamily: styles.currentFontFamily),
        ),
      ),
    );
  }
}
