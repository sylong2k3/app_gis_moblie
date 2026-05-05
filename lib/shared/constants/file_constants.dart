class FileConstants {
  // Folder names
  static const String documentsFolder = 'documents';
  static const String downloadsFolder = 'downloads';
  static const String cacheFolder = 'cache';
  static const String tempFolder = 'temp';

  // File extensions
  static const String pdfExtension = '.pdf';
  static const String docExtension = '.doc';
  static const String docxExtension = '.docx';
  static const String tempExtension = '.tmp';

  // MIME types
  static const String pdfMimeType = 'application/pdf';
  static const String docMimeType = 'application/msword';
  static const String docxMimeType =
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  // Error messages
  static const String errorPermissionDenied =
      'Permission denied to access files';
  static const String errorFileNotFound = 'File not found';
  static const String errorFileAlreadyExists = 'File already exists';
  static const String errorCreatingFile = 'Error creating file';
  static const String errorDownloadingFile = 'Error downloading file';
  static const String errorReadingFile = 'Error reading file';
  static const String errorWritingFile = 'Error writing file';
  static const String errorDeletingFile = 'Error deleting file';

  // Cache settings
  static const int maxCacheSizeInMB = 100; // 100 MB
}
