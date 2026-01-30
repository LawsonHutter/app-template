import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// API endpoint - Django backend
// Default to production URL, can be overridden with --dart-define=API_BASE_URL=...
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://your-app-name.net/api/counter/',
);

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime? _parseUpdatedAt(dynamic value) {
    if (value == null || value is! String) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadCount() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(apiBaseUrl);
      final url = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          '_t': '${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        try {
          final responseBody = response.body;
          print('Refresh response body: $responseBody'); // Debug
          final data = json.decode(responseBody) as Map<String, dynamic>?;
          print('Parsed data: $data'); // Debug
          
          if (data == null) {
            setState(() {
              _errorMessage = 'Invalid response: null data';
              _isRefreshing = false;
            });
            return;
          }
          
          final count = _parseCount(data['count']);
          final updated = _parseUpdatedAt(data['updated_at']);
          final oldCount = _count; // Store old value before setState
          print('Parsed count: $count, previous count: $oldCount'); // Debug
          
          if (count != _count || updated != _lastUpdated) {
            print('Updating state: count=$count, updated=$updated'); // Debug
            setState(() {
              _count = count;
              _lastUpdated = updated;
              _isRefreshing = false;
              _errorMessage = null;
            });
            print('State updated: _count is now $_count'); // Debug
          } else {
            print('No change detected, count already $count'); // Debug
            setState(() {
              _isRefreshing = false;
            });
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Count refreshed: $count${oldCount != count ? ' (was: $oldCount)' : ''}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print('Error parsing response: $e'); // Debug
          setState(() {
            _errorMessage = 'Error parsing response: $e';
            _isRefreshing = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load count. Status: ${response.statusCode}';
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error connecting to backend: $e';
        _isRefreshing = false;
      });
    }
  }

  Future<void> _incrementCount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(apiBaseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        final count = data != null ? _parseCount(data['count']) : 0;
        final updated = data != null ? _parseUpdatedAt(data['updated_at']) : null;
        setState(() {
          _count = count;
          _lastUpdated = updated;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to increment count. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error connecting to backend: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resetCount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Build reset URL by appending 'reset/' to the base URL
      final baseUri = Uri.parse(apiBaseUrl);
      final resetUrl = baseUri.replace(path: baseUri.path.endsWith('/') 
          ? '${baseUri.path}reset/' 
          : '${baseUri.path}/reset/');
      final response = await http.post(
        resetUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>?;
        final count = data != null ? _parseCount(data['count']) : 0;
        final updated = data != null ? _parseUpdatedAt(data['updated_at']) : null;
        setState(() {
          _count = count;
          _lastUpdated = updated;
          _isLoading = false;
          _errorMessage = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Counter reset to zero'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to reset count. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error connecting to backend: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Count Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text(
                        'Current Count',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_count',
                        key: ValueKey('count_$_count'),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_lastUpdated != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Last updated: ${_formatDateTime(_lastUpdated!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Error Message
              if (_errorMessage != null) ...[
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Increment Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _incrementCount,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(_isLoading ? 'Loading...' : 'Increment Counter'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 16),
              
              // Refresh Button
              OutlinedButton.icon(
                onPressed: (_isLoading || _isRefreshing) ? null : _loadCount,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isRefreshing ? 'Refreshing...' : 'Refresh Count'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 16),
              
              // Reset Button
              OutlinedButton.icon(
                onPressed: (_isLoading || _isRefreshing) ? null : _resetCount,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset to Zero'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange, width: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
