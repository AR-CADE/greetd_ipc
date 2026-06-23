import 'dart:async';
import 'dart:io';

import 'package:greetd_ipc/greetd_ipc.dart';

void main() {
  final greetdRepository = GreetdRepository();
  final bloc = GreetdBloc(repository: greetdRepository);
  StreamSubscription<GreetdState>? subscription;

  //
  // Execute a CreateSession
  //
  stdout.write('Execute a `CreateSession` command:\n');

  bloc.add(const CreateAuthSession(username: 'username', password: 'password'));

  subscription = bloc.stream.listen((value) {
    stdout.write('\nGreetdState.status ${DateTime.now()}: ${value.status}\n');
    if (value.promptMessage != null) {
      stdout.write(
        '\nGreetdStatee.promptMessage '
        '${DateTime.now()}: ${value.promptMessage}\n',
      );
    }
    if (value.promptType != null) {
      stdout.write(
        '\nGreetdState.promptType ${DateTime.now()}: ${value.promptType}\n',
      );
    }
    if (value.error != null) {
      stdout.write('\nGreetdState.error ${DateTime.now()}: ${value.error}\n');
    }
  });

  //
  // Don't forget to close the repository and the bloc when the program exit as
  // follow, or you use the on_exit package (https://pub.dev/packages/on_exit)
  //
  final signals = [ProcessSignal.sigint];
  if (!Platform.isWindows) {
    signals.add(ProcessSignal.sigterm);
  }

  for (final signal in signals) {
    signal.watch().listen((signal) async {
      await subscription?.cancel();
      await bloc.close();
      await greetdRepository.disconnect();
      exit(0);
    });
  }
}
