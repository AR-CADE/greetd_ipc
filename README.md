# greetd_ipc

A "Greetd" client library written in Dart, which can be used to create beautiful greeters using Flutter.

| [flgreet](https://github.com/AR-CADE/flgreet) | ??? |
|--|--|
| [![screenshot](https://github.com/AR-CADE/flgreet/blob/main/assets/flgreet.png?raw=true "flgreet")](https://github.com/AR-CADE/flgreet/blob/main/assets/flgreet.png?raw=true) | [![screenshot](https://github.com/AR-CADE/greetd_ipc/blob/main/assets/screenshot1.png?raw=true "screenshot")](https://github.com/AR-CADE/greetd_ipc/blob/main/assets/screenshot1.png?raw=true) |

# (re)generate serializers

run:

```$ dart run build_runner build -r```

# current test coverage

[![screenshot](https://github.com/AR-CADE/greetd_ipc/raw/main/assets/screenshot-coverage.png?raw=true "coverage")](https://github.com/AR-CADE/greetd_ipc/raw/main/assets/screenshot-coverage.png?raw=true)
 
to generate this html report, first install `lcov`, then run:

```

$ flutter test --coverage

$ genhtml coverage/lcov.info -o coverage/html

$ open coverage/html/index.html

```

# contact

arm-cade@proton.me