MQTTInspector
=============

A general MQTT testing app for iOS (iPhone and iPad)

# Features 
* Multiple sessions
* Pre-configured Subscriptions and Publications (stored for later use)
* Ad-hoc PUB
* PUB payload can contain `%t` and `%c`, replaced by timestamp and clientID respectively
* Support for viewing UTF-8 printable payloads as well as very long payloads
* Supports hex-dump of payloads when not printable
* Panel scrolling incoming sub's, latest on top, color-coded topics according to SUBs
* Panel toggable to 'Topic'-mode. In this, incoming msgs do NOT scroll. Instead, last msg overwrites prev on a per/topic basis. Think: temp/outdoors and webserv/status where I see last value without panel scrolling moving: just values on topics change.
* Panel showing low-level communication with broker
* Panels can be frozen (halts all display activity) for, say, taking screenshots

# New features in 1.3
* Drag to adjust screen sizes
* Export (share) edit, and import your complete session settings via email / json
* Filter incoming messages using regular expressions on topics, data and attributes

# Future enhancements
* View traps
* automatically repeating PUBs

![alt 1](apps/ios/MQTTInspector/dist/App Store/ipad-1.png "1")
![alt 2](apps/ios/MQTTInspector/dist/App Store/ipad-2.png "2")
![alt 3](apps/ios/MQTTInspector/dist/App Store/ipad-3.png "3")
![alt 4](apps/ios/MQTTInspector/dist/App Store/ipad-4.png "4")
![alt 5](apps/ios/MQTTInspector/dist/App Store/ipad-5.png "5")
![alt 6](apps/ios/MQTTInspector/dist/App Store/ipad-6.png "6")
![alt 7](apps/ios/MQTTInspector/dist/App Store/ipad-7.png "7")


