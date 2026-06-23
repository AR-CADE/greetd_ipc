import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:greetd_ipc/src/data/models/greetd_request.dart'
    show GreetdRequest;
import 'package:greetd_ipc/src/data/models/greetd_response.dart'
    show GreetdResponse;
import 'package:rxdart/rxdart.dart';

const defaultPort = 0;

class GreetdRepository {
  GreetdRepository();

  RawSocket? _socket;
  bool _connected = false;

  final PublishSubject<GreetdResponse> _responseSubject =
      PublishSubject<GreetdResponse>();
  StreamSubscription<RawSocketEvent>? _streamListener;
  final BytesBuilder _incomingBuffer = BytesBuilder();

  Stream<GreetdResponse> get responses => _responseSubject.stream;
  bool get connected => _connected;

  Future<void> connect({Map<String, String>? environment}) async {
    final getenv = environment ?? Platform.environment;

    final socketPath = getenv['GREETD_SOCK'];
    if (socketPath == null || socketPath.isEmpty) {
      throw Exception('GREETD_SOCK not set');
    }

    const timeout = Duration(seconds: 3);

    final host = InternetAddress(socketPath, type: InternetAddressType.unix);
    _socket = await RawSocket.connect(host, defaultPort, timeout: timeout);

    _connected = true;

    _listenForResponses();
  }

  void _listenForResponses() {
    _streamListener = _socket!.listen(
      (event) async {
        if (event == RawSocketEvent.read) {
          final data = _socket!.read();
          if (data != null) {
            _incomingBuffer.add(data);
            _processIncomingBuffer();
          }
        } else if (event == RawSocketEvent.closed ||
            event == RawSocketEvent.readClosed) {
          await disconnect();
        }
      },
      cancelOnError: true,
      onError: (Object error) async {
        if (!_responseSubject.isClosed) {
          _responseSubject.addError(error);
        }
        await disconnect();
      },
      onDone: () async {
        await disconnect();
      },
    );
  }

  void _processIncomingBuffer() {
    while (_incomingBuffer.length >= 4) {
      final bytes = _incomingBuffer.toBytes();
      final length = ByteData.sublistView(
        bytes,
        0,
        4,
      ).getUint32(0, Endian.host);

      if (bytes.length < 4 + length) {
        break;
      }

      final messageBytes = bytes.sublist(0, 4 + length);

      _incomingBuffer.clear();
      if (bytes.length > 4 + length) {
        _incomingBuffer.add(bytes.sublist(4 + length));
      }

      try {
        final response = GreetdResponse.fromBytes(messageBytes);
        if (!_responseSubject.isClosed) {
          _responseSubject.add(response);
        }
      } on Exception catch (e) {
        if (!_responseSubject.isClosed) {
          _responseSubject.addError(Exception('Parse error: $e'));
        }
      }
    }
  }

  Future<void> sendRequest(GreetdRequest request) async {
    if (_socket == null) {
      await _clientAbort('Socket not connected');
    }

    final bytes = request.toBytes();

    final written = _socket!.write(bytes);

    if (written == -1) {
      await _clientAbort('Unable to send IPC msg');
    }
  }

  Future<void> _clientAbort(String message) async {
    if (!_responseSubject.isClosed) {
      _responseSubject.addError(Exception(message));
    }

    await disconnect();
    throw Exception(message);
  }

  Future<void> disconnect() async {
    _connected = false;
    _incomingBuffer.clear();
    if (!_responseSubject.isClosed) {
      await _responseSubject.close();
    }
    await _streamListener?.cancel();
    await _socket?.close();
  }
}
