import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:greetd_ipc/greetd_ipc.dart';
import 'package:greetd_ipc/src/data/models/create_session_request.dart';
import 'package:greetd_ipc/src/data/models/error_response.dart';
import 'package:greetd_ipc/src/data/models/success_response.dart';
import 'package:mocktail/mocktail.dart' show Mock;
import 'package:rxdart/rxdart.dart' show PublishSubject;
import 'package:test/test.dart';

class MockGreetdSuccessRepository extends Mock implements GreetdRepository {
  final _stream = PublishSubject<GreetdResponse>();
  var _connected = false;

  @override
  Stream<GreetdResponse> get responses => _stream.stream;

  @override
  bool get connected => _connected;

  @override
  Future<void> connect({Map<String, String>? environment}) async {
    _connected = true;
  }

  @override
  Future<void> sendRequest(GreetdRequest request) async {
    final response = GreetdResponse.fromJson(const {
      'type': 'success',
    });
    _stream.add(response);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }
}

class MockGreetdErrorRepository extends Mock implements GreetdRepository {
  final _stream = PublishSubject<GreetdResponse>();
  var _connected = false;

  @override
  Stream<GreetdResponse> get responses => _stream.stream;

  @override
  bool get connected => _connected;

  @override
  Future<void> connect({Map<String, String>? environment}) async {
    _connected = true;
  }

  @override
  Future<void> sendRequest(GreetdRequest request) async {
    final response = GreetdResponse.fromJson(const {
      'type': 'error',
      'error_type': 'auth_error',
      'description': 'description_test',
    });
    _stream.add(response);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }
}

void main() {
  group('GreetdRepository', () {
    group('sendRequest', () {
      late GreetdRepository succesRepository;
      late GreetdRepository errorRepository;
      setUp(() async {
        succesRepository = MockGreetdSuccessRepository();
        errorRepository = MockGreetdErrorRepository();
        await succesRepository.connect();
        await errorRepository.connect();
      });

      tearDown(() async {
        await succesRepository.disconnect();
        await errorRepository.disconnect();
      });
      test('with success', () async {
        unawaited(
          succesRepository.responses.first.then((response) {
            expect(
              succesRepository.connected,
              true,
            );
            expect(
              response is SuccessResponse,
              true,
            );

            expect(
              response.type,
              'success',
            );
          }),
        );

        await succesRepository.sendRequest(
          const CreateSessionRequest('username'),
        );
      });

      test('with error', () async {
        unawaited(
          errorRepository.responses.first.then((response) {
            expect(
              succesRepository.connected,
              true,
            );
            expect(
              response is ErrorResponse,
              true,
            );

            expect(
              response.type,
              'success',
            );
          }),
        );
        await succesRepository.sendRequest(
          const CreateSessionRequest('username'),
        );
      });
    });

    group('Socket Framing Tests', () {
      late ServerSocket server;
      late String socketPath;
      late GreetdRepository repository;
      late Directory tempDir;
      final clientSockets = <Socket>[];
      final receivedBytes = <Uint8List>[];

      setUp(() async {
        receivedBytes.clear();
        clientSockets.clear();

        tempDir = await Directory.systemTemp.createTemp('greetd_uds_test');
        socketPath = '${tempDir.path}/greetd.sock';

        server =
            await ServerSocket.bind(
                InternetAddress(socketPath, type: InternetAddressType.unix),
                0,
              )
              ..listen((socket) {
                clientSockets.add(socket);
                socket.listen(receivedBytes.add);
              });

        repository = GreetdRepository();
      });

      tearDown(() async {
        await repository.disconnect();
        for (final s in clientSockets) {
          await s.close();
        }
        await server.close();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      test(
        'connect throws Exception if GREETD_SOCK is missing or empty',
        () async {
          expect(
            () => repository.connect(environment: {}),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('GREETD_SOCK not set'),
              ),
            ),
          );
        },
      );

      test('connect establishes UDS connection successfully', () async {
        expect(repository.connected, isFalse);
        await repository.connect(environment: {'GREETD_SOCK': socketPath});
        expect(repository.connected, isTrue);
      });

      test('sendRequest sends serialized bytes with length header', () async {
        await repository.connect(environment: {'GREETD_SOCK': socketPath});
        expect(repository.connected, isTrue);

        const request = CreateSessionRequest('test_user');
        await repository.sendRequest(request);

        // Wait a moment for server to receive
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(receivedBytes, isNotEmpty);
        final rawBytes = receivedBytes.first;

        expect(rawBytes.length, greaterThan(4));
        final length = ByteData.sublistView(
          rawBytes,
          0,
          4,
        ).getUint32(0, Endian.host);
        expect(rawBytes.length, equals(4 + length));

        final jsonString = utf8.decode(rawBytes.sublist(4));
        final decodedJson = jsonDecode(jsonString) as Map<String, dynamic>;
        expect(decodedJson['username'], equals('test_user'));
        expect(decodedJson['type'], equals('create_session'));
      });

      test('processes single complete message from server', () async {
        await repository.connect(environment: {'GREETD_SOCK': socketPath});

        // Prepare SuccessResponse json
        final responseJson = jsonEncode({'type': 'success'});
        final payloadBytes = utf8.encode(responseJson);
        final headerBytes = ByteData(4)
          ..setUint32(0, payloadBytes.length, Endian.host);
        final finalBytes = Uint8List(4 + payloadBytes.length)
          ..setRange(0, 4, headerBytes.buffer.asUint8List())
          ..setRange(4, 4 + payloadBytes.length, payloadBytes);

        final responseCompleter = Completer<GreetdResponse>();
        final sub = repository.responses.listen(responseCompleter.complete);

        // Send from server UDS socket to client
        expect(clientSockets, isNotEmpty);
        clientSockets.first.add(finalBytes);

        final receivedResponse = await responseCompleter.future.timeout(
          const Duration(seconds: 1),
        );
        expect(receivedResponse, isA<SuccessResponse>());

        await sub.cancel();
      });

      test('handles fragmented message delivery correctly', () async {
        await repository.connect(environment: {'GREETD_SOCK': socketPath});

        final responseJson = jsonEncode({'type': 'success'});
        final payloadBytes = utf8.encode(responseJson);
        final headerBytes = ByteData(4)
          ..setUint32(0, payloadBytes.length, Endian.host);
        final finalBytes = Uint8List(4 + payloadBytes.length)
          ..setRange(0, 4, headerBytes.buffer.asUint8List())
          ..setRange(4, 4 + payloadBytes.length, payloadBytes);

        final responseCompleter = Completer<GreetdResponse>();
        final sub = repository.responses.listen(responseCompleter.complete);

        // Send header first
        clientSockets.first.add(finalBytes.sublist(0, 4));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(responseCompleter.isCompleted, isFalse);

        // Send payload body
        clientSockets.first.add(finalBytes.sublist(4));

        final receivedResponse = await responseCompleter.future.timeout(
          const Duration(seconds: 1),
        );
        expect(receivedResponse, isA<SuccessResponse>());

        await sub.cancel();
      });

      test('handles coalesced messages in a single packet', () async {
        await repository.connect(environment: {'GREETD_SOCK': socketPath});

        final json1 = jsonEncode({'type': 'success'});
        final payload1 = utf8.encode(json1);
        final header1 = ByteData(4)..setUint32(0, payload1.length, Endian.host);
        final bytes1 = Uint8List(4 + payload1.length)
          ..setRange(0, 4, header1.buffer.asUint8List())
          ..setRange(4, 4 + payload1.length, payload1);

        final json2 = jsonEncode({
          'type': 'error',
          'error_type': 'error',
          'description': 'desc',
        });
        final payload2 = utf8.encode(json2);
        final header2 = ByteData(4)..setUint32(0, payload2.length, Endian.host);
        final bytes2 = Uint8List(4 + payload2.length)
          ..setRange(0, 4, header2.buffer.asUint8List())
          ..setRange(4, 4 + payload2.length, payload2);

        final coalescedBytes = Uint8List(bytes1.length + bytes2.length)
          ..setRange(0, bytes1.length, bytes1)
          ..setRange(bytes1.length, bytes1.length + bytes2.length, bytes2);

        final responses = <GreetdResponse>[];
        final sub = repository.responses.listen(responses.add);

        clientSockets.first.add(coalescedBytes);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(responses.length, equals(2));
        expect(responses[0], isA<SuccessResponse>());
        expect(responses[1], isA<ErrorResponse>());

        await sub.cancel();
      });

      test('handles invalid JSON bytes by emitting stream error', () async {
        await repository.connect(environment: {'GREETD_SOCK': socketPath});

        final payloadBytes = utf8.encode('invalid_json_payload');
        final headerBytes = ByteData(4)
          ..setUint32(0, payloadBytes.length, Endian.host);
        final finalBytes = Uint8List(4 + payloadBytes.length)
          ..setRange(0, 4, headerBytes.buffer.asUint8List())
          ..setRange(4, 4 + payloadBytes.length, payloadBytes);

        final errorCompleter = Completer<Object>();
        final sub = repository.responses.listen(
          (_) {},
          onError: errorCompleter.complete,
        );

        clientSockets.first.add(finalBytes);

        final error = await errorCompleter.future.timeout(
          const Duration(seconds: 1),
        );
        expect(error.toString(), contains('Parse error'));

        await sub.cancel();
      });

      test('disconnect closes connections and shuts down listener', () async {
        await repository.connect(environment: {'GREETD_SOCK': socketPath});
        expect(repository.connected, isTrue);

        await repository.disconnect();
        expect(repository.connected, isFalse);
      });

      test(
        'server closed connection terminates client repository connection',
        () async {
          await repository.connect(environment: {'GREETD_SOCK': socketPath});
          expect(repository.connected, isTrue);

          final doneCompleter = Completer<void>();
          final sub = repository.responses.listen(
            (_) {},
            onDone: doneCompleter.complete,
          );

          // Close from server
          await clientSockets.first.close();

          await doneCompleter.future.timeout(const Duration(seconds: 1));
          expect(repository.connected, isFalse);

          await sub.cancel();
        },
      );
    });
  });
}
