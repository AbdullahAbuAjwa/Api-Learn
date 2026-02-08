# المحاضرة 5: معالجة الأخطاء وأفضل الممارسات

# Lecture 5: Error Handling & Best Practices

**المدة: ساعتين | Duration: 2 hours**

---

## 🎯 أهداف المحاضرة | Lecture Objectives

بنهاية هذه المحاضرة، سيستطيع الطالب:

1. فهم أنواع الأخطاء في تطبيقات API وكيفية التعامل معها
2. إنشاء استثناءات مخصصة (Custom Exceptions)
3. تطبيق إعادة المحاولة (Retry) وآليات التعافي
4. فهم وتطبيق أفضل الممارسات في أمان الـ API وأدائه وتنظيم الكود

---

## 📋 الجزء الأول: أنواع الأخطاء (30 دقيقة)

### 1.1 لماذا معالجة الأخطاء مهمة؟ (5 دقائق)

**ابدأ بتشبيه:**

> "تخيل تطبيق بنكي. المستخدم حوّل فلوس والنت انقطع نص العملية.
> بدون معالجة أخطاء: 'خطأ غير معروف' 😱
> مع معالجة أخطاء: 'انقطع الاتصال. العملية لم تكتمل. أعد المحاولة.' 😌"

### 1.2 تصنيف الأخطاء (15 دقائق)

**ارسم هذا المخطط على السبورة:**

```
أخطاء API
├── أخطاء الشبكة (Network)
│   ├── لا يوجد إنترنت
│   ├── انتهاء المهلة (Timeout)
│   └── DNS فشل
│
├── أخطاء السيرفر (Server - 5xx)
│   ├── 500 Internal Server Error
│   ├── 502 Bad Gateway
│   └── 503 Service Unavailable
│
├── أخطاء العميل (Client - 4xx)
│   ├── 400 Bad Request
│   ├── 401 Unauthorized
│   ├── 403 Forbidden
│   ├── 404 Not Found
│   └── 422 Validation Error
│
├── أخطاء التحويل (Parsing)
│   ├── JSON غير صالح
│   └── نوع بيانات خاطئ
│
└── أخطاء غير متوقعة (Unknown)
```

### 1.3 DioException أنواعها (10 دقائق)

```dart
// Dio يرمي DioException وفيها type:
try {
  await dioClient.get('/posts');
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      // انتهت مهلة الاتصال
      break;
    case DioExceptionType.sendTimeout:
      // انتهت مهلة الإرسال
      break;
    case DioExceptionType.receiveTimeout:
      // انتهت مهلة الاستقبال
      break;
    case DioExceptionType.badResponse:
      // السيرفر رد، لكن بخطأ (4xx, 5xx)
      final statusCode = e.response?.statusCode;
      break;
    case DioExceptionType.cancel:
      // الطلب أُلغي (CancelToken)
      break;
    case DioExceptionType.connectionError:
      // لا يوجد اتصال بالإنترنت
      break;
    case DioExceptionType.unknown:
      // خطأ غير معروف
      break;
    default:
      break;
  }
}
```

**سؤال متوقع:**

> **Q: شو الفرق بين connectionTimeout و receiveTimeout؟**
> **A:**
>
> - connectionTimeout: ما قدر يتصل بالسيرفر أصلاً (مثل رقم هاتف لا يرد)
> - receiveTimeout: اتصل بالسيرفر بس ما استلم الرد بالوقت المحدد (الشخص رد بس سكت!)

---

## 📋 الجزء الثاني: استثناءات مخصصة (30 دقيقة)

### 2.1 لماذا استثناءات مخصصة؟ (5 دقائق)

```dart
// ❌ بدون استثناءات مخصصة
catch (e) {
  errorMessage.value = e.toString();
  // "DioException [bad response]: The request returned an
  //  invalid status code of 404."
  // هذا للمبرمج! المستخدم ما يفهم هالكلام!
}

// ✅ مع استثناءات مخصصة
catch (e) {
  errorMessage.value = e.userFriendlyMessage;
  // "المورد غير موجود. تأكد من الرابط."
}
```

### 2.2 إنشاء ApiException (15 دقائق)

**افتح `lib/core/exceptions/api_exceptions.dart` وأشرح:**

```dart
// الاستثناء الأساسي
class ApiException implements Exception {
  final String message;           // رسالة تقنية (للمبرمج)
  final String userMessage;       // رسالة واضحة (للمستخدم)
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    required this.userMessage,
    this.statusCode,
    this.originalError,
  });
}

// أنواع محددة ترث من ApiException:

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection',
          userMessage: 'لا يوجد اتصال بالإنترنت. تحقق من شبكتك.',
        );
}

class ServerException extends ApiException {
  ServerException({int? statusCode, String? message})
      : super(
          message: message ?? 'Server error',
          userMessage: 'خطأ في السيرفر. حاول لاحقاً.',
          statusCode: statusCode,
        );
}

class NotFoundException extends ApiException {
  NotFoundException({String? resource})
      : super(
          message: '${resource ?? 'Resource'} not found',
          userMessage: '${resource ?? 'المورد'} غير موجود.',
          statusCode: 404,
        );
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
      : super(
          message: 'Unauthorized access',
          userMessage: 'غير مصرح. سجل دخول مرة أخرى.',
          statusCode: 401,
        );
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({this.fieldErrors, String? message})
      : super(
          message: message ?? 'Validation failed',
          userMessage: 'البيانات غير صحيحة. تحقق من المدخلات.',
          statusCode: 422,
        );
}
```

### 2.3 تحويل DioException إلى ApiException (10 دقائق)

```dart
// في Service layer أو Interceptor:
ApiException handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException(
        message: 'Connection timeout: ${e.message}',
      );

    case DioExceptionType.connectionError:
      return NetworkException();

    case DioExceptionType.badResponse:
      return _handleBadResponse(e.response!);

    case DioExceptionType.cancel:
      return ApiException(
        message: 'Request cancelled',
        userMessage: 'تم إلغاء الطلب.',
      );

    default:
      return ApiException(
        message: e.message ?? 'Unknown error',
        userMessage: 'خطأ غير متوقع. حاول مرة أخرى.',
      );
  }
}

ApiException _handleBadResponse(Response response) {
  switch (response.statusCode) {
    case 400:
      return ValidationException(
        message: 'Bad request: ${response.data}',
      );
    case 401:
      return UnauthorizedException();
    case 403:
      return ApiException(
        message: 'Forbidden',
        userMessage: 'لا تملك صلاحية للوصول.',
        statusCode: 403,
      );
    case 404:
      return NotFoundException();
    case 500:
    case 502:
    case 503:
      return ServerException(statusCode: response.statusCode);
    default:
      return ApiException(
        message: 'HTTP ${response.statusCode}',
        userMessage: 'خطأ: ${response.statusCode}',
        statusCode: response.statusCode,
      );
  }
}
```

---

## 📋 الجزء الثالث: متحكم معالجة الأخطاء (20 دقيقة)

### 3.1 شاشة تجربة الأخطاء (10 دقائق)

**افتح `error_handling_controller.dart` وأشرح:**

```dart
class ErrorHandlingController extends GetxController {
  final statusMessage = ''.obs;
  final isLoading = false.obs;
  final statusColor = Colors.grey.obs;
  final statusIcon = Icons.info.obs;

  // 1. طلب ناجح
  Future<void> testSuccessfulRequest() async {
    try {
      isLoading.value = true;
      final response = await dioClient.get(ApiConfig.posts);
      statusMessage.value = '✅ نجح! جلبنا ${(response.data as List).length} منشور';
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // 2. خطأ 404
  Future<void> testNotFound() async {
    try {
      isLoading.value = true;
      await dioClient.get('/posts/99999'); // غير موجود
    } on DioException catch (e) {
      statusMessage.value = '❌ خطأ 404: المورد غير موجود\n'
          'Status: ${e.response?.statusCode}\n'
          'النوع: ${e.type}';
      statusColor.value = Colors.orange;
      statusIcon.value = Icons.warning;
    } finally {
      isLoading.value = false;
    }
  }

  // 3. رابط خاطئ
  Future<void> testInvalidEndpoint() async {
    try {
      isLoading.value = true;
      await dioClient.get('/invalid-endpoint-xyz');
    } on DioException catch (e) {
      statusMessage.value = '❌ Endpoint غير صالح\n'
          'Status: ${e.response?.statusCode}\n'
          'Message: ${e.message}';
      statusColor.value = Colors.red;
      statusIcon.value = Icons.error;
    } finally {
      isLoading.value = false;
    }
  }

  // 4. محاكاة خطأ شبكة مع خطوات
  Future<void> testNetworkRequest() async {
    isLoading.value = true;
    statusMessage.value = '🔄 الخطوة 1: التحقق من الاتصال...';
    await Future.delayed(Duration(seconds: 1));

    statusMessage.value = '🔄 الخطوة 2: إرسال الطلب...';
    await Future.delayed(Duration(seconds: 1));

    statusMessage.value = '🔄 الخطوة 3: انتظار الاستجابة...';
    await Future.delayed(Duration(seconds: 1));

    try {
      final response = await dioClient.get(ApiConfig.posts);
      statusMessage.value = '✅ الخطوات اكتملت!\nجلبنا ${(response.data as List).length} منشور';
      statusColor.value = Colors.green;
    } catch (e) {
      statusMessage.value = '❌ فشل في الخطوة 3';
      statusColor.value = Colors.red;
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 3.2 واجهة الأخطاء (10 دقائق)

```dart
class ErrorHandlingScreen extends GetView<ErrorHandlingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // عرض الحالة
          Obx(() => Card(
            color: controller.statusColor.value.withValues(alpha: 0.1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(controller.statusIcon.value,
                       color: controller.statusColor.value),
                  SizedBox(width: 12),
                  Expanded(
                    child: controller.isLoading.value
                      ? CircularProgressIndicator()
                      : Text(controller.statusMessage.value),
                  ),
                ],
              ),
            ),
          )),

          // أزرار الاختبار
          _buildButton('طلب ناجح', controller.testSuccessfulRequest),
          _buildButton('خطأ 404', controller.testNotFound),
          _buildButton('رابط خاطئ', controller.testInvalidEndpoint),
          _buildButton('محاكاة شبكة', controller.testNetworkRequest),

          // جدول أنواع الأخطاء (مرجع)
          _buildErrorTypesReference(),
        ],
      ),
    );
  }
}
```

---

## 📋 الجزء الرابع: Retry و آليات التعافي (15 دقيقة)

### 4.1 إعادة المحاولة التلقائية (10 دقائق)

```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // أعد المحاولة فقط لأخطاء الشبكة والسيرفر
    if (_shouldRetry(err)) {
      int retryCount = 0;

      while (retryCount < maxRetries) {
        retryCount++;
        print('🔄 إعادة محاولة $retryCount/$maxRetries...');

        // انتظر قبل إعادة المحاولة (Exponential Backoff)
        await Future.delayed(retryDelay * retryCount);

        try {
          // أعد إرسال نفس الطلب
          final response = await dioClient.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          return handler.resolve(response);
        } catch (e) {
          if (retryCount == maxRetries) {
            return handler.next(err); // استسلم
          }
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode ?? 0) >= 500;
  }
}
```

**مفاهيم مهمة:**

**Exponential Backoff:**

> "بدل ما تعيد المحاولة فوراً:
> المحاولة 1: انتظر 1 ثانية
> المحاولة 2: انتظر 2 ثوانٍ
> المحاولة 3: انتظر 4 ثوانٍ
> هذا يقلل الضغط على السيرفر."

### 4.2 متى نعيد المحاولة ومتى لا؟ (5 دقائق)

| الخطأ                   | إعادة محاولة؟ | السبب                            |
| ----------------------- | ------------- | -------------------------------- |
| 500 Server Error        | ✅ نعم        | مشكلة مؤقتة                      |
| 503 Service Unavailable | ✅ نعم        | السيرفر مشغول                    |
| Timeout                 | ✅ نعم        | شبكة بطيئة                       |
| Connection Error        | ✅ نعم        | ممكن الاتصال يرجع                |
| 400 Bad Request         | ❌ لا         | نفس البيانات الخطأ = نفس النتيجة |
| 401 Unauthorized        | ❌ لا         | تحتاج تسجيل دخول                 |
| 404 Not Found           | ❌ لا         | المورد غير موجود                 |
| 403 Forbidden           | ❌ لا         | ممنوع                            |

> **Q: ليش ما نعيد المحاولة لـ 401؟**
> **A:** لأنه يعني الـ Token غير صالح. إعادة المحاولة بنفس الـ Token = نفس النتيجة. الحل هو تجديد الـ Token أو إعادة تسجيل الدخول.

---

## 📋 الجزء الخامس: أفضل الممارسات (25 دقائق)

### 5.1 أمان الـ API (10 دقائق)

**1. استخدم HTTPS دائماً:**

```
❌ http://api.example.com    ← البيانات مكشوفة
✅ https://api.example.com   ← البيانات مشفرة
```

**2. لا تضع المفاتيح في الكود:**

```dart
// ❌ خطير جداً!
const apiKey = 'sk-1234567890abcdef';

// ✅ استخدم متغيرات البيئة
// في .env file (لا ترفعه لـ Git!):
// API_KEY=sk-1234567890abcdef

// في الكود:
import 'package:flutter_dotenv/flutter_dotenv.dart';
final apiKey = dotenv.env['API_KEY'];
```

**3. أضف Authentication headers:**

```dart
// في Interceptor:
@override
void onRequest(RequestOptions options, handler) {
  // أضف Token لكل طلب تلقائياً
  final token = AuthService.getToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}
```

**4. تجديد Token تلقائياً:**

```dart
@override
void onError(DioException err, handler) async {
  if (err.response?.statusCode == 401) {
    // Token انتهى → جدده
    final newToken = await AuthService.refreshToken();
    if (newToken != null) {
      // أعد الطلب بالـ Token الجديد
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await dioClient.fetch(err.requestOptions);
      return handler.resolve(response);
    }
    // فشل التجديد → سجل خروج
    AuthService.logout();
    Get.offAllNamed('/login');
  }
  handler.next(err);
}
```

### 5.2 أداء الـ API (10 دقائق)

**1. التخزين المؤقت (Caching):**

```dart
class CacheInterceptor extends Interceptor {
  final Map<String, Response> _cache = {};
  final Duration cacheDuration = Duration(minutes: 5);

  @override
  void onRequest(RequestOptions options, handler) {
    // فقط GET requests تُخزَّن
    if (options.method == 'GET') {
      final cached = _cache[options.uri.toString()];
      if (cached != null) {
        print('📦 من الكاش: ${options.path}');
        return handler.resolve(cached);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, handler) {
    if (response.requestOptions.method == 'GET') {
      _cache[response.requestOptions.uri.toString()] = response;
    }
    handler.next(response);
  }
}
```

**2. ترقيم الصفحات (Pagination):**

```dart
// ❌ لا تجلب كل البيانات دفعة واحدة!
await dioClient.get('/posts'); // 10,000 منشور!!

// ✅ اجلب على دفعات
await dioClient.get('/posts', queryParameters: {
  '_page': 1,
  '_limit': 20,
});
```

**3. إلغاء الطلبات غير الضرورية:**

```dart
CancelToken? _searchCancelToken;

void search(String query) async {
  // ألغِ الطلب السابق
  _searchCancelToken?.cancel();
  _searchCancelToken = CancelToken();

  try {
    final results = await dioClient.get(
      '/search',
      queryParameters: {'q': query},
      cancelToken: _searchCancelToken,
    );
  } on DioException catch (e) {
    if (e.type == DioExceptionType.cancel) return; // متوقع
  }
}
```

**تشبيه:**

> "مثل ما تكتب في Google: كل حرف يرسل طلب.
> بدون cancel: 'c' + 'ca' + 'cat' = 3 طلبات (ضغط على السيرفر)
> مع cancel: يلغي القديم ويرسل 'cat' فقط = طلب واحد"

### 5.3 تنظيم الكود (5 دقائق)

**القواعد الذهبية:**

1. **Single Responsibility**: كل class مسؤول عن شيء واحد
2. **DRY**: لا تكرر الكود (Don't Repeat Yourself)
3. **Barrel Exports**: سهّل الاستيراد بملفات تصدير
4. **GetX Pattern**: Controller ← Service ← DioClient ← API
5. **Error Handling**: كل طبقة تعالج أخطاءها

```
الشاشة (View) → تعرض فقط
    ↓
المتحكم (Controller) → يدير الحالة والمنطق
    ↓
الخدمة (Service) → تتعامل مع API
    ↓
DioClient → يرسل HTTP requests
    ↓
Interceptors → تعالج مشاكل مشتركة
```

---

## 📋 الجزء السادس: ملخص المشروع الكامل (10 دقائق)

### مراجعة سريعة لكل ما تعلمناه:

| المحاضرة | الموضوع                         | المفاهيم الرئيسية                            |
| -------- | ------------------------------- | -------------------------------------------- |
| 1        | RESTful API و Models            | HTTP methods, Status codes, JSON, Models     |
| 2        | هيكل المشروع                    | Dio setup, Interceptors, GetX, Bindings      |
| 3        | GET و POST                      | Fetch, Create, Query params, Pagination, Obx |
| 4        | PUT/PATCH و DELETE ورفع الملفات | Update, Delete, Optimistic, FormData         |
| 5        | الأخطاء والممارسات              | Exceptions, Retry, Security, Performance     |

### التدفق الكامل لعملية API:

```
1. المستخدم يضغط زر
2. GetView يستقبل الحدث
3. Controller يبدأ العملية (isLoading = true)
4. Controller يستدعي Service
5. Service يستخدم DioClient
6. DioClient يمر عبر Interceptors
7. الطلب يُرسل للسيرفر
8. الاستجابة ترجع عبر Interceptors
9. Service يحوّل JSON إلى Model
10. Controller يحدث الحالة (.obs)
11. Obx يحدث الواجهة تلقائياً
12. المستخدم يرى النتيجة
```

---

## ✅ تمارين للطلاب

### تمرين 1: إنشاء استثناء مخصص

> أنشئ `RateLimitException` يعالج خطأ 429 (Too Many Requests)
> مع رسالة مناسبة وزمن الانتظار المطلوب

### تمرين 2: Cache Interceptor

> عدّل CacheInterceptor بحيث:
>
> - يمسح الكاش بعد 5 دقائق
> - يتجاهل الكاش لـ POST/PUT/DELETE
> - يمسح كاش endpoint معين عند POST عليه

### تمرين 3: مشروع تطبيقي

> أنشئ شاشة "إعدادات الـ API" تعرض:
>
> - الـ Base URL الحالي
> - Timeout الحالي
> - عدد الـ Interceptors
> - زر لاختبار الاتصال

### تمرين 4: أسئلة نظرية

1. ما الفرق بين NetworkException و ServerException؟
2. متى نعيد المحاولة ومتى لا؟ أعطِ 3 أمثلة لكل حالة.
3. لماذا لا نضع API Key في الكود مباشرة؟
4. ما هو Exponential Backoff؟ لماذا هو أفضل من Retry فوري؟
5. ما فائدة التخزين المؤقت (Caching)؟ ما مشاكله؟
6. لماذا نلغي الطلبات في Search (CancelToken)؟

**إجابات:**

1. Network: مشكلة بالشبكة (لا إنترنت، timeout). Server: السيرفر استقبل الطلب بس فيه مشكلة عنده (500, 502).
2. نعيد: timeout, 500, 503, connection error. لا نعيد: 400, 401, 403, 404, 422.
3. لأنه لو رفعت الكود لـ GitHub، أي شخص يقدر يشوف المفتاح ويستخدمه. استخدم .env مع .gitignore.
4. زيادة وقت الانتظار بين كل محاولة (1s, 2s, 4s...). أفضل لأنه يقلل الضغط على السيرفر ويعطيه وقت يتعافى.
5. الفائدة: سرعة أكبر، ضغط أقل على السيرفر. المشاكل: بيانات قديمة، استهلاك ذاكرة. الحل: cache duration.
6. لأن كل حرف يُرسل طلب جديد. بدون إلغاء = طلبات كثيرة بلا فائدة + ممكن نتيجة قديمة تصل بعد الجديدة.

---

## 🔑 النقاط الرئيسية للمراجعة

1. أنواع الأخطاء: شبكة، سيرفر (5xx)، عميل (4xx)، تحويل، غير متوقع
2. استثناءات مخصصة تعطي رسائل واضحة للمستخدم
3. Retry فقط للأخطاء المؤقتة (شبكة، سيرفر)
4. Exponential Backoff يقلل الضغط على السيرفر
5. لا تضع أسرار (API keys, tokens) في الكود
6. Cache يسرّع التطبيق بس انتبه للبيانات القديمة
7. CancelToken يمنع الطلبات غير الضرورية
8. كل طبقة مسؤولة عن شيء واحد فقط

---

## 📚 مشروع نهائي مقترح

**أنشئ تطبيق "مدونتي" يشمل:**

1. عرض قائمة المنشورات (GET + Pagination)
2. إنشاء منشور جديد (POST + Form Validation)
3. تعديل منشور (PUT/PATCH)
4. حذف منشور (DELETE + Optimistic + Undo)
5. معالجة أخطاء شاملة (Custom Exceptions)
6. إدارة حالة بـ GetX (Controllers + Bindings + Routes)
7. Interceptors للـ Logging والـ Retry

---

## 🎉 خاتمة الدورة

**ما تعلمناه:**

- RESTful API كاملة (GET, POST, PUT, PATCH, DELETE)
- إدارة حالة احترافية بـ GetX
- معالجة أخطاء شاملة
- أفضل ممارسات الأمان والأداء
- هيكل مشروع قابل للتوسع

**الخطوة القادمة:**

- جرب APIs حقيقية (OpenWeather, News API, Firebase)
- تعلم Authentication (JWT, OAuth)
- تعلم WebSockets للبيانات الحية
- تعلم GraphQL كبديل لـ REST

بالتوفيق للجميع! 🚀
