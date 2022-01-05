/* dart */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* enum */
import '../enums/expire_status.dart';

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
        borderRadius: BorderRadius.circular(15.0),
        color: expireStatus == ExpireStatus.Expired
            ? Colors.redAccent.withOpacity(0.7)
            : expireStatus == ExpireStatus.ExpiringToday
                ? Colors.yellow.withOpacity(0.7)
                : Colors.grey.withOpacity(0.7),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          expireStatus == ExpireStatus.Expired
              ? "EXPIRED"
              : expireStatus == ExpireStatus.ExpiringToday
                  ? "Expiring today"
                  : 'Exp: ${DateFormat('dd MMM yyyy').format(expiration)}',
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
