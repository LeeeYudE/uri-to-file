import 'dart:io';

import 'package:flutter/services.dart';
import 'model/custom_exception/uri_io_exception.dart';

/// Method Channel Helper
const MethodChannel _methodChannel =
    const MethodChannel('in.lazymanstudios.uritofile/helper');

/// Error code for PlatformException
const String _URI_NOT_SUPPORTED = 'URI_NOT_SUPPORTED';

/// Error code for PlatformException
const String _IO_EXCEPTION = 'IO_EXCEPTION';

/// Check uri is supported or not
///
/// Don't pass uri parameter using [Uri] object via uri.toString().
/// Because uri.toString() changes the string to lowercase which causes this package to misbehave
///
/// If you are using uni_links package for deep linking purpose.
/// Pass the uri string using getInitialLink() or linkStream
///
/// Supported uri scheme same as supported by File.fromUri(uri) with content uri (Android Only)
///
/// returns
/// - true  if uri supported
/// - false if uri not supported
bool isUriSupported(String uriString) {
  Uri uri = Uri.parse(uriString);
  if (Platform.isAndroid && uri.isScheme('content')) {
    return true;
  }

  try {
    File.fromUri(uri);
    return true;
  } catch (e) {
    return false;
  }
}

/// Create a [File] object from a uri.
///
/// Don't pass uri parameter using [Uri] object via uri.toString().
/// Because uri.toString() changes the string to lowercase which causes this package to misbehave
///
/// If you are using uni_links package for deep linking purpose.
/// Pass the uri string using getInitialLink() or linkStream
///
/// Supported uri scheme same as supported by File.fromUri(uri) with content uri (Android Only)
///
/// If uri cannot reference a file this throws [UnsupportedError] or [IOException]
Future<File> toFile(String uriString) async {
  Uri uri = Uri.parse(uriString);
  if (Platform.isAndroid && uri.isScheme('content')) {
    try {
      String filepath = await _methodChannel
          .invokeMethod("fromUri", {"uriString": uriString});
      return File(filepath);
    } on PlatformException catch (e) {
      switch (e.code) {
        case _URI_NOT_SUPPORTED:
          {
            throw UnsupportedError(
                'Cannot extract a file path from a ${uri.scheme} URI');
          }
        case _IO_EXCEPTION:
          {
            throw UriIOException(e.message);
          }
        default:
          {
            rethrow;
          }
      }
    } catch (e) {
      rethrow;
    }
  }

  return File.fromUri(uri);
}

Future<bool> copyFileToSdcard(String filePath,String uriString) async {
  Uri uri = Uri.parse(uriString);
  if (Platform.isAndroid && uri.isScheme('content')) {
    try {
      bool? _result = await _methodChannel
          .invokeMethod("copyFileToSdcard", {"uriString": uriString,"filePath":filePath});
      return _result??false;
    } on PlatformException catch (e) {
      switch (e.code) {
        case _URI_NOT_SUPPORTED:
          {
            throw UnsupportedError(
                'Cannot extract a file path from a ${uri.scheme} URI');
          }
        case _IO_EXCEPTION:
          {
            throw UriIOException(e.message);
          }
        default:
          {
            rethrow;
          }
      }
    } catch (e) {
      rethrow;
    }
  }

  return false;
}
