MQTTInspector
=============

A great IOS (and Android) generalized MQTT testing app. (thanks to @andypiper for setting the objective)

# Features (feel free to comment)
* Multiple SUBs, saved for later use
* Multiple PUBs, saved for later use

* Panel scrolling incoming sub's, latest on top, color-coded topics according to SUBs
* Panel toggable to 'static' mode. In this, incoming msgs do NOT scroll. Instead, last msg overwrites prev on a per/topic basis. Think: temp/outdoors and webserv/status
  where I see last value without panel scrolling moving: just values on topics change.


# Restrictions
* Conn to 1 broker sufficient
* LWT unnecessary


# Future enhancements
* View filters
* View traps
* automatically repeating PUBs

