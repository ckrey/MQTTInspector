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

# Net features in 1.2
* Pinch to size SUBs display
* Rotate to size Messages display

# Future enhancements
* View filters
* View traps
* automatically repeating PUBs

