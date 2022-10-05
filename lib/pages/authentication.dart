import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/page_layout.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage();

  @override
  State<AuthenticationPage> createState() => _AuthenticationPage();
}

class _AuthenticationPage extends State<AuthenticationPage> {
  static final LocalAuthentication localAuth = LocalAuthentication();

  Future<bool> biometricsIsAvailable() async {
    final isDeviceSupported = await localAuth.isDeviceSupported();
    final isAvailable = await localAuth.canCheckBiometrics;
    print("isAvailable: $isAvailable, isDeviceSupported: $isDeviceSupported");
    return isAvailable && isDeviceSupported;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (await biometricsIsAvailable()) {
      try {
        final isAuthenticated = await localAuth.authenticate(
            localizedReason: 'Authenticate with biometrics',
            options: const AuthenticationOptions(
                useErrorDialogs: true, stickyAuth: true));
        print('Is authenticated: ${isAuthenticated}');
        return true;
      } catch (e) {
        print('Error: $e');
        return false;
      }
    } else {
      print("biometrics not available");
      return false;
    }
  }

  _callCreatePassword() async {
    final password = "1234";
    createPassword(password);
  }

  Future<void> createPassword(String password) async {
    ReefAppState.instance.storage.setValue(StorageKey.password.name, password);
    print('Password ${password} saved');
  }

  _callAuthenticateWithPassword() async {
    final password = "1234";
    authenticateWithPassword(password);
  }

  Future<void> authenticateWithPassword(String value) async {
    final password =
        await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    bool isValid = password != null && password == value;
    print('Is valid password: ${isValid}');
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
      );
    } else {
      print('Invalid password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: biometricsIsAvailable,
                child: const Text('Has biometrics support')),
            TextButton(
                onPressed: authenticateWithBiometrics,
                child: const Text('Authenticate with biometrics')),
            TextButton(
                onPressed: _callCreatePassword,
                child: const Text('Create password')),
            TextButton(
                onPressed: _callAuthenticateWithPassword,
                child: const Text('Authenticate with password')),
          ],
        ),
      ),
    );
  }
}
