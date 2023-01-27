import 'package:geolocator/geolocator.dart';

Future<String> getPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  String status;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
     return Future.error("Service not enabled");
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.whileInUse) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      status = 'denied';
    } else if (permission == LocationPermission.whileInUse) {
      status = 'askEveryTime';
    } else {
      status = 'always';
    }
  } else if (permission == LocationPermission.unableToDetermine) {
      return Future.error("Unable to Determine");
  } else if (permission == LocationPermission.deniedForever) {
    status =  'deniedForever';
  }

  else {
    (status = 'always');
  }

  return status;
}

Future<Position> determinePosition() async {
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
}