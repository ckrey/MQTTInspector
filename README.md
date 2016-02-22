MQTTInspector
=============

A general MQTT testing app for iOS (iPhone and iPad)

# Features 
* Supports all MQTT features 3.1, 3.1.1, cleansession, TLS, Websockets, etc.
* Pre-configured Subscriptions, Publications, and Filters (stored for later use)
* Ad-hoc and pre-configured PUBs
* PUB payload can contain `%t` and `%c`, replaced by timestamp and clientID respectively
* Support for viewing UTF-8 printable, binary and JSON payloads
* Panel scrolling incoming sub's, latest on top, color-coded topics according to SUBs
* Panel toggable to 'Topic'-mode. In this, incoming msgs do NOT scroll. Instead, last msg overwrites prev on a per/topic basis. Think: temp/outdoors and webserv/status where I see last value without panel scrolling moving: just values on topics change.
* Panel showing low-level communication with broker
* Panels can be frozen (halts all display activity) for, say, taking screenshots
* Screen does not time-out

# New features in 2.1.0
* [NEW] Add additional MQTT brokers closes #79
* [FIX] Command display closes #78
* [FIX] JSON display precision #75
* [FIX] incorrect screen redraw #72, closes #74
* [FIX] Session setup screen layout
* [FIX] Message detail display modes

# New features in 2.0.3
* [NEW] use Testflight crash reporting, drop Fabric/Crashlytics
* [NEW] Disable idle timeout while active / "monitor" mode
* [NEW] MQTT over WebSocket support
* [NEW] Self-signed Certs support
* [NEW] UI feedback when dragging view divider
* [NEW] UI feedback in ad hoc publish and filter edit
* [NEW] flip layout from horizontal to vertical divides by long pressing on message view
* [NEW] use UISplitviewcontroller for all devices, adds split view to iPhone 6+

* [FIX] distorted split screen on iPad when changing orientation closes #72
* [FIX] crashes when dragging view divider far to the left on iPads closes #66, closes #65, closes #64
* [FIX] timeout on connect, closes #68
* [FIX] ignore non-UTF8 topics, avoiding crash
* [FIX] correctly closing input stream after error, avoiding crash

# New features in 1.71
* [FIX] crash on disconnect closes #63

# New features in 1.7
* [NEW] show version number in lauch screen
* [NEW] Fabric.io Crashlytics included
* [NEW] Cocoalumberjack Pod included
* [NEW] SB4Json as Pod
* [FIX] crash when trying to display connect error
* [FIX] crash when receiving binary payload closes #62
* [NEW] return key in text fields closes keyboard

# New features in 1.3
* Drag to adjust screen sizes
* Export (share) edit, and import your complete session settings via email / json
* Filter incoming messages using regular expressions on topics, data and attributes

# Testimonials

* “@Sine_Wave_Tech: #MQTT going mainstream, hit the #Apple #appstore - great advance for #IoT https://t.co/3oXRJDsXYp”
* “@voluntas: MQTTInspector 買ってみた。 http://t.co/0Wxbb0OTmG” (http://translate.google.de/#auto/en/買ってみた。
* “@dobermai: Don’t know what I would have done without the MQTTInspector App by @ChristophKrey today. Mandatory #mqtt app for every iOS device!”
* “@OwnTracks: Looking for a versatile MQTT debugging app? Check out MQTT Inspector for iOS by @ChristophKrey http://t.co/pTAR928DrW I'm loving it! [JP]”
* “@jpmens: If you want to see a demo of what MQTT Inspector for iOS will look like, @ChristophKrey has a video here http://t.co/JhiRJL5soy”
* “@jpmens: MQTT Inspector for iOS with app-side filtering & settings import/export https://t.co/Re2yQPYsUC (info: http://t.co/z26ATPPIX4)”

# Future enhancements
* View traps
* Automatically repeating PUBs (and other scripting)
* Formatted message display
* Edit subscriptions, publishes and filters directly from session screen

