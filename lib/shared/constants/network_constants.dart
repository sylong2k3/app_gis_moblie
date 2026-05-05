class NetworkConstants {
  // Headers
  static const String headerIfNoneMatch = 'If-None-Match';
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerUserAgent = 'User-Agent';
  static const String headerAcceptLanguage = 'Accept-Language';
  static const String headerConnection = 'Connection';
  static const String headerOrigin = 'Origin';
  static const String headerReferer = 'Referer';
  static const String xRequestId = 'X-Request-Id';

  // Header values
  static const String contentTypeJson = 'application/json';
  static const String acceptJson = 'application/json, text/plain, */*';
  static const String acceptLanguageVi = 'vi';
  static const String connectionKeepAlive = 'keep-alive';
  static const String authBearer = 'Bearer ';

  // Dio options extras keys
  static const String extraRetriesCount = 'retriesCount';
  static const String extraSkipRetry = 'skipRetry';
  static const String extraIsRetryAttempt = 'isRetryAttempt';

  // Cache metadata keys
  static const String metadataEtag = '_etag';
  static const String metadataData = 'data';
  static const String metadataExpiry = 'expiry';
  static const String metadataEndpoint = 'endpoint';
  static const String metadataEtagValue = 'etag';

  // Error messages
  static const String errorRequestCancelled = 'Request cancelled';
}
