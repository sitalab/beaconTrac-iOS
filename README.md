beaconTrac-iOS
==============

The beaconTrac app is a demo iPhone app built in Objective C showing how to call the [SITA iBeacon Common Use Registry](https://www.developer.aero/BeaconRegistry).

What it does
============

The app is a simple use case showing how to use the three key APIs from the SITA iBeacon Common Use Registry. 

- Get nearest airport.
- Get list of beacons at that airport
- Get details about beacon nearest to your device.

The first two APIs are called on app startup. The third API is called when the user comes into proximity of an iBeacon, to get the meta-details for that iBeacon.

FAQ
===
- Can I get access to the iBeacons deployed at airports
  - Currently access is still limited to airlines, airports and ground handlers. The plan is to open access to general 3rd parties in the future. 
- How do I build the project
  - To build the project, check out the code (don't forget to use the --recursive option) and run the beaconTrac project in Xcode.
  - Update constants.h with your own API and Google Maps SDK keys.  
  - Update constants.h the appid.


Contributors
============
* [bilalitani](https://github.com/bilalitani) / Bilal Itani
* [kosullivansita](https://github.com/kosullivansita) / [Kevin O'Sullivan](http://www.sita.aero/surveys-reports/sita-lab)

License
=======

This project is licensed under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).
