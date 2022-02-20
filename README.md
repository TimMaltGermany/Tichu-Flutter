# Tichu

A new Flutter project.

## Getting Started

run node js server as follows:
- cd .../Tichu-Server
- tsc;node dist/server/session.js

Do not forget to run `flutter pub run build_runner build` to (re-)generate the generated code in `models`

## TODOs
- Tichu announcement not seen by others
- "schupfed" cards may be outside of visible area
- show DOGS
- show who's turn it is
- compute score
- assign Drake-trick

## additional packages
Add these further packages using `flutter pub add`
- provider
- http
- flame
- shared_preferences
- tuple
- web_socket_channel
- audioplayers
- json_annotation
- optional

Also install build_runner to generate dart code:
dart pub add build_runner --dev