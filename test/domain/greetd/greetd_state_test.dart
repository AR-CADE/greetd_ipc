import 'package:greetd_ipc/greetd_ipc.dart' show GreetdState;
import 'package:greetd_ipc/src/domain/greetd/greetd_bloc.dart'
    show GreetdStatus;
import 'package:test/test.dart';

void main() {
  group('GreetdState', () {
    group('GreetdState.initial', () {
      test('supports value comparisons', () {
        expect(
          GreetdState.initial(),
          GreetdState.initial(),
        );
      });

      test('props are correct', () {
        expect(
          GreetdState.initial().props,
          equals([GreetdStatus.initial, '', null, null, null]),
        );
      });
    });

    group('copyWith', () {
      test('supports value comparisons', () {
        expect(
          GreetdState.initial().copyWith(
            status: GreetdStatus.success,
            username: 'username',
          ),
          GreetdState.initial().copyWith(
            status: GreetdStatus.success,
            username: 'username',
          ),
        );
      });

      test('props are correct', () {
        expect(
          GreetdState.initial()
              .copyWith(
                status: GreetdStatus.success,
                username: 'username',
              )
              .props,
          equals([GreetdStatus.success, 'username', null, null, null]),
        );
      });
    });
  });
}
