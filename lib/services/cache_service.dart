
import 'dart:core';

class CacheService {
  final Map<String, CacheEntry> _cache = {};
  final Duration defaultTimeout = const Duration(minutes: 5);

  dynamic get(String key) {
    if (_cache.containsKey(key)) {
      final entry = _cache[key]!;
      if (DateTime.now().isBefore(entry.expiry)) {
        return entry.data;
      }
    }
    return null;
  }

  void set(String key, dynamic data, {Duration? timeout}) {
    final expiry = DateTime.now().add(timeout ?? defaultTimeout);
    _cache[key] = CacheEntry(data, expiry);
  }

  void invalidate(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry(this.data, this.expiry);
}
