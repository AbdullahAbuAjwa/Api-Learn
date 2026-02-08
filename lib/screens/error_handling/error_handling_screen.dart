import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';

/// ============================================================================
/// شاشة معالجة الأخطاء: توضح سيناريوهات الأخطاء المختلفة باستخدام GetX
/// Error Handling Screen: Demonstrates Various Error Scenarios using GetX
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. أنواع مختلفة من الأخطاء (شبكة، خادم، عميل)
///    Different types of errors (network, server, client)
/// 2. استراتيجيات معالجة الأخطاء
///    Error handling strategies
/// 3. آليات إعادة المحاولة
///    Retry mechanisms
/// 4. رسائل خطأ سهلة للمستخدم
///    User-friendly error messages
/// 5. التدهور الرشيق
///    Graceful degradation
///
/// أهداف التعلم | Learning Objectives:
/// - فهم أنواع الأخطاء المختلفة في استدعاءات API
///   Understand different error types in API calls
/// - تعلم معالجة الأخطاء بشكل رشيق
///   Learn to handle errors gracefully
/// - رؤية أنماط إعادة المحاولة عملياً
///   See retry patterns in action
/// - فهم تجربة المستخدم أثناء الأخطاء
///   Understand user experience during errors
/// ============================================================================

/// فئة مساعدة لسيناريوهات الأخطاء
/// Helper class for error scenarios
class ErrorScenario {
  /// عنوان السيناريو | Scenario title
  final String title;

  /// وصف السيناريو | Scenario description
  final String description;

  /// نقطة النهاية | Endpoint
  final String endpoint;

  /// النتيجة المتوقعة | Expected outcome
  final String expectedOutcome;

  /// أيقونة السيناريو | Scenario icon
  final IconData icon;

  /// لون السيناريو | Scenario color
  final Color color;

  ErrorScenario({
    required this.title,
    required this.description,
    required this.endpoint,
    required this.expectedOutcome,
    required this.icon,
    required this.color,
  });
}

/// شاشة معالجة الأخطاء باستخدام GetView
/// Error handling screen using GetView
class ErrorHandlingScreen extends GetView<ErrorHandlingController> {
  const ErrorHandlingScreen({super.key});

  /// قائمة سيناريوهات الاختبار | Test scenarios list
  static final List<ErrorScenario> _scenarios = [
    // سيناريو طلب ناجح | Successful request scenario
    ErrorScenario(
      title: 'طلب ناجح - Successful Request',
      description: 'استدعاء API ناجح عادي - Normal successful API call',
      endpoint: '/posts/1',
      expectedOutcome:
          'يرجع بيانات المنشور (حالة 200) - Returns post data (status 200)',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    // سيناريو غير موجود | Not found scenario
    ErrorScenario(
      title: 'غير موجود (404) - Not Found (404)',
      description: 'المورد غير موجود - Resource does not exist',
      endpoint: '/posts/999999',
      expectedOutcome: 'يرجع خطأ 404 - Returns 404 error',
      icon: Icons.search_off,
      color: Colors.orange,
    ),
    // سيناريو نقطة نهاية غير صالحة | Invalid endpoint scenario
    ErrorScenario(
      title: 'نقطة نهاية غير صالحة - Invalid Endpoint',
      description: 'نقطة النهاية غير موجودة - Endpoint does not exist',
      endpoint: '/invalid-endpoint',
      expectedOutcome: 'يرجع خطأ 404 - Returns 404 error',
      icon: Icons.link_off,
      color: Colors.orange,
    ),
    // سيناريو محاكاة الشبكة | Network simulation scenario
    ErrorScenario(
      title: 'محاكاة الشبكة - Network Simulation',
      description: 'يحاكي طلب شبكة - Simulates a network request',
      endpoint: '/posts',
      expectedOutcome: 'يوضح حالات التحميل - Demonstrates loading states',
      icon: Icons.wifi,
      color: Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق | App bar
      appBar: AppBar(title: const Text('معالجة الأخطاء - Error Handling')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // بطاقة المعلومات | Information Card
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
                          'أفضل ممارسات معالجة الأخطاء - Error Handling Best Practices',
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
                    // قائمة أفضل الممارسات | Best practices list
                    _buildPractice(
                      context,
                      '1.',
                      'استخدم أنواع استثناءات محددة لأخطاء مختلفة\nUse specific exception types for different errors',
                    ),
                    _buildPractice(
                      context,
                      '2.',
                      'اعرض رسائل خطأ سهلة للمستخدم\nShow user-friendly error messages',
                    ),
                    _buildPractice(
                      context,
                      '3.',
                      'طبّق آليات إعادة المحاولة للأخطاء المؤقتة\nImplement retry mechanisms for transient failures',
                    ),
                    _buildPractice(
                      context,
                      '4.',
                      'سجّل الأخطاء للتصحيح (ليس في واجهة الإنتاج)\nLog errors for debugging (not in production UI)',
                    ),
                    _buildPractice(
                      context,
                      '5.',
                      'وفّر خيارات بديلة عند الإمكان\nProvide fallback options when possible',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // عرض الحالة التفاعلي | Reactive Status Display
            // ========================================
            Obx(
              () => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // أيقونة الحالة | Status icon
                      Icon(
                        controller.statusIcon.value,
                        size: 48,
                        color: controller.statusColor.value,
                      ),
                      const SizedBox(height: 12),
                      // مؤشر التحميل | Loading indicator
                      if (controller.isLoading.value)
                        const LinearProgressIndicator()
                      else
                        const SizedBox(height: 4),
                      const SizedBox(height: 12),
                      // رسالة الحالة | Status message
                      Text(
                        controller.statusMessage.value ??
                            'اختر سيناريو للاختبار - Select a scenario to test',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // سيناريوهات الاختبار | Test Scenarios
            // ========================================
            Text(
              'سيناريوهات الاختبار - Test Scenarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // أزرار السيناريوهات | Scenario buttons
            _buildScenarioButton(
              _scenarios[0],
              controller.testSuccessfulRequest,
            ),
            _buildScenarioButton(_scenarios[1], controller.testNotFound),
            _buildScenarioButton(_scenarios[2], controller.testInvalidEndpoint),
            _buildScenarioButton(_scenarios[3], controller.testNetworkRequest),

            const SizedBox(height: 32),

            // ========================================
            // مرجع أنواع الأخطاء | Error Types Reference
            // ========================================
            Text(
              'مرجع أنواع الأخطاء - Error Types Reference',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // بطاقات أنواع الأخطاء | Error type cards
            _buildErrorTypeCard(
              context,
              'NetworkException',
              'لا يوجد اتصال بالإنترنت، انتهاء المهلة، أخطاء DNS\nNo internet connection, timeouts, DNS errors',
              Icons.wifi_off,
              Colors.red,
            ),
            _buildErrorTypeCard(
              context,
              'ServerException (5xx)',
              'خطأ داخلي في الخادم، الخدمة غير متاحة\nInternal server error, service unavailable',
              Icons.dns,
              Colors.red,
            ),
            _buildErrorTypeCard(
              context,
              'ClientException (4xx)',
              'طلب غير صالح، غير مصرح، محظور، غير موجود\nBad request, unauthorized, forbidden, not found',
              Icons.person_off,
              Colors.orange,
            ),
            _buildErrorTypeCard(
              context,
              'ValidationException',
              'بيانات إدخال غير صالحة، حقول مطلوبة مفقودة\nInvalid input data, missing required fields',
              Icons.warning,
              Colors.amber,
            ),
            _buildErrorTypeCard(
              context,
              'UnauthorizedException',
              'المصادقة مطلوبة أو انتهت صلاحية الرمز\nAuthentication required or token expired',
              Icons.lock,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر أفضل ممارسة | Build practice item
  Widget _buildPractice(BuildContext context, String number, String text) {
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

  /// بناء زر سيناريو | Build scenario button
  Widget _buildScenarioButton(ErrorScenario scenario, VoidCallback onTap) {
    return Obx(
      () => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(scenario.icon, color: scenario.color),
          title: Text(scenario.title),
          subtitle: Text(scenario.description),
          trailing: const Icon(Icons.play_arrow),
          // تعطيل أثناء التحميل | Disable during loading
          onTap: controller.isLoading.value ? null : onTap,
        ),
      ),
    );
  }

  /// بناء بطاقة نوع خطأ | Build error type card
  Widget _buildErrorTypeCard(
    BuildContext context,
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
            // أيقونة نوع الخطأ | Error type icon
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
                  // اسم نوع الخطأ | Error type name
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // وصف نوع الخطأ | Error type description
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
