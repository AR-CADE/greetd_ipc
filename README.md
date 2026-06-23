# greetd_ipc
An Greetd client library written in Dart... that can eventually be used to build something like that:


![Alt text](/assets/screenshot1.png?raw=true "snapshot") ![Alt text](/assets/screenshot2.png?raw=true "snapshot") ![Alt text](/assets/screenshot3.png?raw=true "snapshot")



# (re)generate serializers
run:

```$ dart run build_runner build -r```

# current test coverage

 ![Alt text](/assets/screenshot-coverage.png?raw=true "snapshot")

 to generate this html report, first install `lcov`, then run: 

 ```
    $ flutter test --coverage
    $ genhtml coverage/lcov.info -o coverage/html
    $ open coverage/html/index.html
 ```


# contact
arm-cade@proton.me
