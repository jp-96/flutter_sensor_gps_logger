# Flutter GNSS and motion sensor logger

A Flutter application that can be used to test different GNSS walking distance estimation configurations, log motion sensor data and send it to an external web server in .csv format.

## Supported Platforms

- iOS
- Android

# mod

**pubspec.yaml**

``` pubspec.yaml
environment:
  #sdk: ">=2.0.0-dev.68.0 <3.0.0"
  # https://github.com/firebase/flutterfire/pull/10946
  sdk: '>=2.18.0 <4.0.0'

```

****

```
flutter pub add geolocator sensors share path_provider http pedometer device_info
```

## geolocator

https://pub.dev/packages/geolocator


```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```


**GPS**
https://pmatatias.medium.com/im-having-trouble-getting-the-gps-location-in-the-background-flutter-70acf559f5f4


## sensors

https://pub.dev/packages/sensors

=> https://pub.dev/packages/sensors_plus

## pedometer

https://pub.dev/packages/pedometer

Permissions 
For Android 10 and above add the following permission to the Android manifest:

```
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

For iOS, add the following entries to your Info.plist file in the Runner xcode project:

```
<key>NSMotionUsageDescription</key>
<string>This application tracks your steps</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

```
flutter pub add permission_handler
```

```
await Permission.activityRecognition.request().isGranted;
```

## Buttons

- FlatButton => TextButton
- RaisedButton => ElevatedButton
- OutlineButton => OutlinedButton
