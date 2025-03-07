import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  Timer? _timer;
  final String freeTrialCreditCapKey = 'free_trial_credit_cap';
  int freeTrialCreditCap = 50000; // Default value

  Future<void> init() async {
    // Set default value for freeTrialCreditCap in case remote config is not available.
    await remoteConfig.setDefaults({
      freeTrialCreditCapKey: freeTrialCreditCap,
    });

    // Initial fetch and activate
    await _fetchRemoteConfig();

    // // Optionally, poll for updates every 5 minutes.
    // _timer = Timer.periodic(Duration(minutes: 5), (_) async {
    //   await _fetchRemoteConfig();
    // });
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      // Fetch new values from the server and activate them.
      await remoteConfig.fetchAndActivate();

      // Read the free trial credit cap value from remote config.
      final int newCap = remoteConfig.getInt(freeTrialCreditCapKey);

      // If the value has changed, update state and notify listeners.
      if (freeTrialCreditCap != newCap) {
        freeTrialCreditCap = newCap;
        notifyListeners(); // TODO: Decide whether we want to refresh when this value changes? I think probably not neede and can be deleted
      }
    } catch (e) {
      // Handle errors as needed (e.g., log the error)
      print('Error fetching remote config: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
