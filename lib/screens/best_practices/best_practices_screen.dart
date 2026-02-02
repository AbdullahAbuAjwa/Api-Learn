import 'package:flutter/material.dart';

/// ============================================================================
/// API Best Practices Screen: Reference Guide for Students
/// ============================================================================
///
/// This screen serves as a comprehensive reference guide covering:
/// 1. RESTful API design principles
/// 2. HTTP methods and their proper usage
/// 3. Error handling strategies
/// 4. Security best practices
/// 5. Performance optimization
/// 6. Code organization patterns
///
/// This is a documentation screen - no API calls are made here.
/// ============================================================================

class BestPracticesScreen extends StatelessWidget {
  const BestPracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Best Practices')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========================================
          // RESTful API Concepts
          // ========================================
          _buildSection(
            context,
            title: '🌐 RESTful API Concepts',
            icon: Icons.api,
            color: Colors.blue,
            items: [
              _BestPracticeItem(
                title: 'REST = Representational State Transfer',
                description:
                    'An architectural style for designing networked applications. '
                    'It uses standard HTTP methods and is stateless.',
              ),
              _BestPracticeItem(
                title: 'Resources',
                description:
                    'Everything is a resource identified by a URL.\n'
                    '• /users - Collection of users\n'
                    '• /users/1 - Single user\n'
                    '• /users/1/posts - User\'s posts',
              ),
              _BestPracticeItem(
                title: 'Statelessness',
                description:
                    'Each request contains all information needed. '
                    'The server doesn\'t store client state between requests.',
              ),
              _BestPracticeItem(
                title: 'Uniform Interface',
                description:
                    'Use standard HTTP methods consistently:\n'
                    '• GET - Read\n'
                    '• POST - Create\n'
                    '• PUT - Full Update\n'
                    '• PATCH - Partial Update\n'
                    '• DELETE - Remove',
              ),
            ],
          ),

          // ========================================
          // HTTP Methods
          // ========================================
          _buildSection(
            context,
            title: '📡 HTTP Methods',
            icon: Icons.http,
            color: Colors.green,
            items: [
              _BestPracticeItem(
                title: 'GET - Read/Retrieve',
                description:
                    '• Should NOT modify data\n'
                    '• Safe and idempotent\n'
                    '• Can be cached\n'
                    '• Parameters in URL query string',
              ),
              _BestPracticeItem(
                title: 'POST - Create',
                description:
                    '• Creates new resources\n'
                    '• NOT idempotent (calling twice creates two resources)\n'
                    '• Data in request body\n'
                    '• Returns 201 Created on success',
              ),
              _BestPracticeItem(
                title: 'PUT - Full Update',
                description:
                    '• Replaces entire resource\n'
                    '• Idempotent (same result if called multiple times)\n'
                    '• Send complete resource in body\n'
                    '• Creates if doesn\'t exist (upsert)',
              ),
              _BestPracticeItem(
                title: 'PATCH - Partial Update',
                description:
                    '• Updates specific fields only\n'
                    '• Smaller payload than PUT\n'
                    '• May not be idempotent\n'
                    '• Preferred for form submissions',
              ),
              _BestPracticeItem(
                title: 'DELETE - Remove',
                description:
                    '• Removes a resource\n'
                    '• Idempotent\n'
                    '• Usually returns 200 OK or 204 No Content\n'
                    '• Consider soft delete for reversibility',
              ),
            ],
          ),

          // ========================================
          // Error Handling
          // ========================================
          _buildSection(
            context,
            title: '⚠️ Error Handling',
            icon: Icons.error_outline,
            color: Colors.orange,
            items: [
              _BestPracticeItem(
                title: 'Use Specific Exception Types',
                description:
                    'Create custom exceptions for different errors:\n'
                    '• NetworkException - Connection issues\n'
                    '• ServerException - 5xx errors\n'
                    '• ClientException - 4xx errors\n'
                    '• ValidationException - Input errors',
              ),
              _BestPracticeItem(
                title: 'User-Friendly Messages',
                description:
                    '• Don\'t show technical errors to users\n'
                    '• Provide actionable feedback\n'
                    '• Suggest solutions (retry, check internet)\n'
                    '• Log technical details for debugging',
              ),
              _BestPracticeItem(
                title: 'Implement Retry Logic',
                description:
                    '• Retry on transient failures (timeouts, 5xx)\n'
                    '• Use exponential backoff\n'
                    '• Limit retry attempts\n'
                    '• Don\'t retry on 4xx errors',
              ),
              _BestPracticeItem(
                title: 'Graceful Degradation',
                description:
                    '• Show cached data when offline\n'
                    '• Provide offline-first experience\n'
                    '• Queue operations for later sync\n'
                    '• Show partial content when possible',
              ),
            ],
          ),

          // ========================================
          // Security
          // ========================================
          _buildSection(
            context,
            title: '🔒 Security Best Practices',
            icon: Icons.security,
            color: Colors.red,
            items: [
              _BestPracticeItem(
                title: 'Always Use HTTPS',
                description:
                    '• Encrypts data in transit\n'
                    '• Validates server identity\n'
                    '• Required for production apps\n'
                    '• Never send sensitive data over HTTP',
              ),
              _BestPracticeItem(
                title: 'Authentication',
                description:
                    '• Use industry standards (OAuth 2.0, JWT)\n'
                    '• Store tokens securely (flutter_secure_storage)\n'
                    '• Implement token refresh\n'
                    '• Clear tokens on logout',
              ),
              _BestPracticeItem(
                title: 'Don\'t Hardcode Secrets',
                description:
                    '• Use environment variables\n'
                    '• Store API keys securely\n'
                    '• Don\'t commit secrets to git\n'
                    '• Use .env files for configuration',
              ),
              _BestPracticeItem(
                title: 'Input Validation',
                description:
                    '• Validate on client AND server\n'
                    '• Sanitize user input\n'
                    '• Don\'t trust client data\n'
                    '• Implement rate limiting',
              ),
            ],
          ),

          // ========================================
          // Performance
          // ========================================
          _buildSection(
            context,
            title: '⚡ Performance Optimization',
            icon: Icons.speed,
            color: Colors.purple,
            items: [
              _BestPracticeItem(
                title: 'Caching',
                description:
                    '• Cache GET responses\n'
                    '• Use ETags for validation\n'
                    '• Implement offline support\n'
                    '• Respect Cache-Control headers',
              ),
              _BestPracticeItem(
                title: 'Pagination',
                description:
                    '• Don\'t fetch all data at once\n'
                    '• Implement infinite scroll\n'
                    '• Use cursor-based pagination for large datasets\n'
                    '• Show loading states between pages',
              ),
              _BestPracticeItem(
                title: 'Request Optimization',
                description:
                    '• Batch requests when possible\n'
                    '• Use parallel requests for independent data\n'
                    '• Debounce search inputs\n'
                    '• Cancel outdated requests',
              ),
              _BestPracticeItem(
                title: 'Connection Pooling',
                description:
                    '• Reuse HTTP connections\n'
                    '• Use a single Dio instance\n'
                    '• Configure appropriate timeouts\n'
                    '• Implement connection keep-alive',
              ),
            ],
          ),

          // ========================================
          // Code Organization
          // ========================================
          _buildSection(
            context,
            title: '📁 Code Organization',
            icon: Icons.folder_outlined,
            color: Colors.teal,
            items: [
              _BestPracticeItem(
                title: 'Layered Architecture',
                description:
                    '• UI Layer - Screens and widgets\n'
                    '• Service Layer - API calls\n'
                    '• Repository Layer - Data abstraction\n'
                    '• Model Layer - Data classes',
              ),
              _BestPracticeItem(
                title: 'Single Responsibility',
                description:
                    '• One service per API resource\n'
                    '• Separate concerns (UI, logic, data)\n'
                    '• Keep classes focused\n'
                    '• Use dependency injection',
              ),
              _BestPracticeItem(
                title: 'Configuration Management',
                description:
                    '• Centralize API configuration\n'
                    '• Use constants for endpoints\n'
                    '• Support multiple environments\n'
                    '• Make timeouts configurable',
              ),
              _BestPracticeItem(
                title: 'Type Safety',
                description:
                    '• Use typed models, not dynamic\n'
                    '• Leverage Dart null safety\n'
                    '• Generate JSON serialization code\n'
                    '• Avoid type casting',
              ),
            ],
          ),

          // ========================================
          // Common Patterns
          // ========================================
          _buildSection(
            context,
            title: '🎯 Common Patterns',
            icon: Icons.pattern,
            color: Colors.indigo,
            items: [
              _BestPracticeItem(
                title: 'Repository Pattern',
                description:
                    'Abstract data sources behind a common interface.\n'
                    'Allows switching between API, cache, and mock data easily.',
              ),
              _BestPracticeItem(
                title: 'Singleton HTTP Client',
                description:
                    'Use one shared HTTP client instance.\n'
                    'Ensures consistent configuration and connection reuse.',
              ),
              _BestPracticeItem(
                title: 'Interceptors for Cross-Cutting Concerns',
                description:
                    'Use interceptors for:\n'
                    '• Adding auth headers\n'
                    '• Logging requests/responses\n'
                    '• Handling token refresh\n'
                    '• Implementing retry logic',
              ),
              _BestPracticeItem(
                title: 'Generic Response Wrapper',
                description:
                    'Wrap API responses in a generic class.\n'
                    'Provides consistent success/error handling across the app.',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Reference Card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Quick Reference',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickRef('GET', '200 OK', 'Fetch data'),
                  _buildQuickRef('POST', '201 Created', 'Create resource'),
                  _buildQuickRef('PUT', '200 OK', 'Full update'),
                  _buildQuickRef('PATCH', '200 OK', 'Partial update'),
                  _buildQuickRef('DELETE', '200/204', 'Remove resource'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_BestPracticeItem> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: false,
        children: items.map((item) => _buildItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _BestPracticeItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRef(String method, String status, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getMethodColor(method),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              status,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _BestPracticeItem {
  final String title;
  final String description;

  _BestPracticeItem({required this.title, required this.description});
}
