/* dart */
import 'package:flutter/material.dart';

/* helpers */
import '../enums/sign_in_method.dart';

/* models */
import '../models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _familyId;
}
