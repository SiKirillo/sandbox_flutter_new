part of '../common.dart';

/// Biometric types supported by the device (face, fingerprint).
enum BiometricSupportedType {
  face,
  fingerprint,
}

/// Handles biometric authentication (face/fingerprint) via [LocalAuthentication].
/// Use [authenticate] to prompt; [canAuthenticate] / [getSupportedBiometrics] to check support.
class BiometricService {
  final _localAuthentication = LocalAuthentication();
  Timer? _manyAttemptsTimer;
  bool _isInit = false;

  /// Prompts for biometric auth with [localizedReason]; returns [Failure] on cancel/error.
  Future<dartz.Either<Failure, bool>> authenticate(String localizedReason) async {
    final isSupported = await canAuthenticate();
    if (!isSupported) {
      LoggerService.logWarning('BiometricService -> authenticate(): biometricUnsupported');
      return dartz.Left(BiometricFailureType.biometricUnsupported.get());
    }

    try {
      final response = await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          IOSAuthMessages(
            cancelButton: BiometricFailureType.biometricBlocked.get().message,
          ),
        ],
        biometricOnly: true,
      );

      if (response) {
        _manyAttemptsTimer?.cancel();
        _manyAttemptsTimer = null;
        return dartz.Right(response);
      } else {
        LoggerService.logWarning('BiometricService -> authenticate(): biometricCanceled');
        return dartz.Left(BiometricFailureType.biometricCanceled.get());
      }
    } on PlatformException catch (e) {
      LoggerService.logWarning('BiometricService -> authenticate(): $e');
      if (e.code == 'LockedOut' || (e.message ?? '').contains('API is locked')) {
        if (_manyAttemptsTimer?.isActive ?? false || !_isInit) {
          LoggerService.logWarning('BiometricService -> authenticate(): biometricToManyAttemptsDelay');
          return dartz.Left(BiometricFailureType.biometricToManyAttemptsDelay.get());
        }

        _manyAttemptsTimer = Timer(const Duration(seconds: 30), () {});
        LoggerService.logWarning('BiometricService -> authenticate(): biometricToManyAttempts');
        return dartz.Left(BiometricFailureType.biometricToManyAttempts.get());
      }

      _manyAttemptsTimer?.cancel();
      _manyAttemptsTimer = null;

      if (e.code == 'PermanentlyLockedOut' || (e.message ?? '').contains('The operation was canceled because ERROR_LOCKOUT occurred too many times')) {
        LoggerService.logWarning('BiometricService -> authenticate(): biometricBlocked');
        return dartz.Left(BiometricFailureType.biometricBlocked.get());
      }

      if (e.code == 'Authentication canceled' || (e.message ?? '').contains('Authentication canceled')) {
        LoggerService.logWarning('BiometricService -> authenticate(): biometricCanceled');
        return dartz.Left(BiometricFailureType.biometricCanceled.get());
      }

      LoggerService.logWarning('BiometricService -> authenticate(): biometricIncorrect');
      return dartz.Left(BiometricFailureType.biometricIncorrect.get());
    } catch (e) {
      LoggerService.logWarning('BiometricService -> authenticate(): $e');
      _manyAttemptsTimer?.cancel();
      _manyAttemptsTimer = null;
      LoggerService.logWarning('BiometricService -> authenticate(): biometricIncorrect');
      return dartz.Left(BiometricFailureType.biometricIncorrect.get());
    } finally {
      _isInit = true;
    }
  }

  /// True if device supports and has at least one biometric enrolled.
  Future<bool> canAuthenticate() async {
    final isSupported = await _localAuthentication.isDeviceSupported();
    final availableBiometrics = await _localAuthentication.getAvailableBiometrics();

    if (Platform.isAndroid) {
      return isSupported && availableBiometrics.isNotEmpty;
    }

    return isSupported;
  }

  /// Returns list of available biometric types (face, fingerprint).
  Future<List<BiometricSupportedType>> getSupportedBiometrics() async {
    final availableBiometrics = await _localAuthentication.getAvailableBiometrics();
    return [
      if (availableBiometrics.contains(BiometricType.face))
        BiometricSupportedType.face,
      if (availableBiometrics.contains(BiometricType.fingerprint))
        BiometricSupportedType.fingerprint,
    ];
  }
}