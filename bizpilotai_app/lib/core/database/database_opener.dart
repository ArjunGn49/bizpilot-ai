export 'database_opener_stub.dart'
    if (dart.library.ffi) 'database_opener_native.dart'
    if (dart.library.js_interop) 'database_opener_web.dart';
