# greetd_ipc
An Greetd client library written in Dart... that can eventually be used to build something like that:

| [flgreet]() | ??? |
|--|--|
| [![sreenshot](https://github.com/AR-CADE/flgreet/blob/main/assets/flgreet.png?raw=true "snapshot")](https://github.com/AR-CADE/flgreet/blob/main/assets/flgreet.png?raw=true "snapshot") | [![sreenshot](./assets/screenshot1.png?raw=true "snapshot")](./assets/screenshot1.png?raw=true "snapshot") |

# (re)generate serializers
run:

```$ dart run build_runner build -r```

# current test coverage

[![sreenshot](./assets/screenshot-coverage.png?raw=true "coverage")](./assets/screenshot-coverage.png?raw=true "coverage")

 to generate this html report, first install `lcov`, then run: 

 ```
    $ flutter test --coverage
    $ genhtml coverage/lcov.info -o coverage/html
    $ open coverage/html/index.html
 ```


# contact
arm-cade@proton.me
