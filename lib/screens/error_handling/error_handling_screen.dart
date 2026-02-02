import 'package:flutter/material.dart';
import '../../core/core.dart';

/// ============================================================================
/// Error Handling Screen: Demonstrates Various Error Scenarios
/// ============================================================================
///
/// This screen demonstrates:
/// 1. Different types of errors (network, server, client)
/// 2. Error handling strategies
/// 3. Retry mechanisms
/// 4. User-friendly error messages
/// 5. Graceful degradation
///
/// Learning Objectives:
/// - Understand different error types in API calls
/// - Learn to handle errors gracefully
/// - See retry patterns in action
/// - Understand user experience during errors
/// ============================================================================

class ErrorHandlingScreen extends StatefulWidget {
  const ErrorHandlingScreen({super.key});

  @override
  State<ErrorHandlingScreen> createState() => _ErrorHandlingScreenState();
}

class _ErrorHandlingScreenState extends State<ErrorHandlingScreen> {
  final PostApiService _postService = PostApiService(dioClient);

  String? _statusMessage;
  bool _isLoading = false;
  Color _statusColor = Colors.grey;
  IconData _statusIcon = Icons.info;

  /// Simulated error scenarios
  final List<_ErrorScenario> _scenarios = [
    _ErrorScenario(
      title: 'Successful Request',
      description: 'Normal successful API call',
      endpoint: '/posts/1',
      expectedOutcome: 'Returns post data (status 200)',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    _ErrorScenario(
      title: 'Not Found (404)',
      description: 'Resource does not exist',
      endpoint: '/posts/999999',
      expectedOutcome: 'Returns 404 error',
      icon: Icons.search_off,
      color: Colors.orange,
    ),
    _ErrorScenario(
      title: 'Invalid Endpoint',
      description: 'Endpoint does not exist',
      endpoint: '/invalid-endpoint',
      expectedOutcome: 'Returns 404 error',
      icon: Icons.link_off,
      color: Colors.orange,
    ),
    _ErrorScenario(
      title: 'Network Simulation',
      description: 'Simulates a network request',
      endpoint: '/posts',
      expectedOutcome: 'Demonstrates loading states',
      icon: Icons.wifi,
      color: Colors.blue,
    ),
  ];

  /// ========================================
  /// Test Successful Request
  /// ========================================
  Future<void> _testSuccessfulRequest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Making request...';
      _statusColor = Colors.blue;
      _statusIcon = Icons.hourglass_empty;
    });

    final response = await _postService.getPostById(1);

    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _statusMessage =
            '✅ Success!\n\n'
            'Status Code: 200\n'
            'Post Title: ${response.data?.title}\n'
            'User ID: ${response.data?.userId}';
        _statusColor = Colors.green;
        _statusIcon = Icons.check_circle;
      } else {
        _statusMessage = '❌ Failed: ${response.error?.message}';
        _statusColor = Colors.red;
        _statusIcon = Icons.error;
      }
    });
  }

  /// ========================================
  /// Test 404 Not Found
  /// ========================================
  Future<void> _testNotFound() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting non-existent post...';
      _statusColor = Colors.blue;
      _statusIcon = Icons.hourglass_empty;
    });

    // Request a post that doesn't exist
    final response = await _postService.getPostById(999999);

    setState(() {
      _isLoading = false;
      if (!response.isSuccess) {
        _statusMessage =
            '⚠️ Not Found!\n\n'
            'Status Code: ${response.statusCode}\n'
            'Error Type: ${response.error?.type}\n'
            'Message: ${response.error?.message}\n\n'
            'This is expected when requesting a resource that doesn\'t exist.';
        _statusColor = Colors.orange;
        _statusIcon = Icons.search_off;
      } else {
        _statusMessage = 'Unexpectedly succeeded!';
        _statusColor = Colors.green;
        _statusIcon = Icons.check_circle;
      }
    });
  }

  /// ========================================
  /// Test Invalid Endpoint
  /// ========================================
  Future<void> _testInvalidEndpoint() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting invalid endpoint...';
      _statusColor = Colors.blue;
      _statusIcon = Icons.hourglass_empty;
    });

    try {
      // This will likely return a 404 or other error
      await dioClient.get('/this-endpoint-does-not-exist');

      setState(() {
        _isLoading = false;
        _statusMessage = 'Request completed (may have returned empty data)';
        _statusColor = Colors.orange;
        _statusIcon = Icons.warning;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            '❌ Error!\n\n'
            'Exception Type: ${e.runtimeType}\n'
            'Message: ${e.toString()}\n\n'
            'This demonstrates how invalid endpoints are handled.';
        _statusColor = Colors.red;
        _statusIcon = Icons.error;
      });
    }
  }

  /// ========================================
  /// Test Network Request with Loading
  /// ========================================
  Future<void> _testNetworkRequest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Step 1: Initiating request...';
      _statusColor = Colors.blue;
      _statusIcon = Icons.wifi;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _statusMessage = 'Step 2: Connecting to server...');

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _statusMessage = 'Step 3: Waiting for response...');

    final response = await _postService.getAllPosts();

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _statusMessage = 'Step 4: Parsing response...');

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _statusMessage =
            '✅ Complete!\n\n'
            'Fetched ${response.data?.length} posts\n'
            'Status: ${response.statusCode}\n\n'
            'All steps completed successfully.';
        _statusColor = Colors.green;
        _statusIcon = Icons.check_circle;
      } else {
        _statusMessage = '❌ Failed: ${response.error?.message}';
        _statusColor = Colors.red;
        _statusIcon = Icons.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handling')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // Information Card
            // ========================================
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Error Handling Best Practices',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPractice(
                      '1.',
                      'Use specific exception types for different errors',
                    ),
                    _buildPractice('2.', 'Show user-friendly error messages'),
                    _buildPractice(
                      '3.',
                      'Implement retry mechanisms for transient failures',
                    ),
                    _buildPractice(
                      '4.',
                      'Log errors for debugging (not in production UI)',
                    ),
                    _buildPractice(
                      '5.',
                      'Provide fallback options when possible',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // Status Display
            // ========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(_statusIcon, size: 48, color: _statusColor),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const LinearProgressIndicator()
                    else
                      const SizedBox(height: 4),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage ?? 'Select a scenario to test',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // Test Scenarios
            // ========================================
            Text(
              'Test Scenarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Scenario buttons
            _buildScenarioButton(_scenarios[0], _testSuccessfulRequest),
            _buildScenarioButton(_scenarios[1], _testNotFound),
            _buildScenarioButton(_scenarios[2], _testInvalidEndpoint),
            _buildScenarioButton(_scenarios[3], _testNetworkRequest),

            const SizedBox(height: 32),

            // ========================================
            // Error Types Reference
            // ========================================
            Text(
              'Error Types Reference',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildErrorTypeCard(
              'NetworkException',
              'No internet connection, timeouts, DNS errors',
              Icons.wifi_off,
              Colors.red,
            ),
            _buildErrorTypeCard(
              'ServerException (5xx)',
              'Internal server error, service unavailable',
              Icons.dns,
              Colors.red,
            ),
            _buildErrorTypeCard(
              'ClientException (4xx)',
              'Bad request, unauthorized, forbidden, not found',
              Icons.person_off,
              Colors.orange,
            ),
            _buildErrorTypeCard(
              'ValidationException',
              'Invalid input data, missing required fields',
              Icons.warning,
              Colors.amber,
            ),
            _buildErrorTypeCard(
              'UnauthorizedException',
              'Authentication required or token expired',
              Icons.lock,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPractice(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioButton(_ErrorScenario scenario, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(scenario.icon, color: scenario.color),
        title: Text(scenario.title),
        subtitle: Text(scenario.description),
        trailing: const Icon(Icons.play_arrow),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }

  Widget _buildErrorTypeCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for error scenarios
class _ErrorScenario {
  final String title;
  final String description;
  final String endpoint;
  final String expectedOutcome;
  final IconData icon;
  final Color color;

  _ErrorScenario({
    required this.title,
    required this.description,
    required this.endpoint,
    required this.expectedOutcome,
    required this.icon,
    required this.color,
  });
}
