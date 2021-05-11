// Mocks generated by Mockito 5.0.7 from annotations
// in action_log/test/action_log_helper_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i4;
import 'dart:io' as _i2;

import 'package:action_log/src/internal/file_handler.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

// ignore_for_file: prefer_const_constructors

// ignore_for_file: avoid_redundant_argument_values

class _FakeDirectory extends _i1.Fake implements _i2.Directory {}

/// A class which mocks [FileHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockFileHandler extends _i1.Mock implements _i3.FileHandler {
  MockFileHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Directory> getCurrentDirectory() =>
      (super.noSuchMethod(Invocation.method(#getCurrentDirectory, []),
              returnValue: Future<_i2.Directory>.value(_FakeDirectory()))
          as _i4.Future<_i2.Directory>);
}