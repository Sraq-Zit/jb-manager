class HttpException implements Exception {
  final String _message;
  final int? _statusCode;

  String get message => _message;
  int? get statusCode => _statusCode;

  HttpException(this._message, [this._statusCode]);

  @override
  String toString() {
    if (_statusCode != null) {
      return 'HttpException: $_message (Status code: $_statusCode)';
    }
    return 'HttpException: $_message';
  }
}
