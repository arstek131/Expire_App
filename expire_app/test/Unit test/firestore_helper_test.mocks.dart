// Mocks generated by Mockito 5.0.17 from annotations
// in expire_app/test/Unit%20test/firestore_helper_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:expire_app/helpers/user_info.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

/// A class which mocks [UserInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserInfo extends _i1.Mock implements _i2.UserInfo {
  MockUserInfo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set userId(dynamic userId) =>
      super.noSuchMethod(Invocation.setter(#userId, userId),
          returnValueForMissingStub: null);
  @override
  set familyId(dynamic familyId) =>
      super.noSuchMethod(Invocation.setter(#familyId, familyId),
          returnValueForMissingStub: null);
  @override
  set displayName(dynamic displayName) =>
      super.noSuchMethod(Invocation.setter(#displayName, displayName),
          returnValueForMissingStub: null);
  @override
  set email(dynamic email) =>
      super.noSuchMethod(Invocation.setter(#email, email),
          returnValueForMissingStub: null);
  @override
  _i3.Future<void> initUserInfoProvider() =>
      (super.noSuchMethod(Invocation.method(#initUserInfoProvider, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
}
