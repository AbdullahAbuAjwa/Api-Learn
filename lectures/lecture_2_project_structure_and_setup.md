# المحاضرة 2: هيكل المشروع وإعداد Dio و GetX

# Lecture 2: Project Structure, Dio Setup & GetX

**المدة: ساعتين | Duration: 2 hours**

---

## 🎯 أهداف المحاضرة | Lecture Objectives

بنهاية هذه المحاضرة، سيستطيع الطالب:

1. فهم هيكل مشروع Flutter احترافي متعدد الطبقات
2. إعداد Dio كـ HTTP Client مع إعدادات مركزية
3. فهم Interceptors وكيفية عملها
4. فهم لماذا نستخدم GetX وما الذي يوفره
5. فهم GetxController و Bindings و Named Routes
6. فهم مفهوم Dependency Injection مع GetX

---

## 📋 الجزء الأول: هيكل المشروع (30 دقيقة)

### 1.1 لماذا التنظيم مهم؟ (5 دقائق)

**ابدأ بسؤال:**

> "لو عندك مشروع فيه 50 شاشة و 30 model، هل ممكن تحطهم كلهم في ملف واحد؟"

**النقاط:**

- مشروع صغير = الفوضى مقبولة
- مشروع كبير = الفوضى = كارثة
- التنظيم الجيد يسهل: الصيانة، العمل الجماعي، الاختبار

### 1.2 هيكل المشروع (15 دقائق)

**ارسم الهيكل على السبورة:**

```
lib/
├── main.dart                    ← نقطة الدخول (GetMaterialApp)
│
├── controllers/                 ← 🧠 منطق العمل (GetX Controllers)
│   ├── controllers.dart         ← ملف التصدير
│   ├── get_request_controller.dart
│   ├── post_request_controller.dart
│   ├── update_request_controller.dart
│   ├── delete_request_controller.dart
│   ├── file_upload_controller.dart
│   └── error_handling_controller.dart
│
├── bindings/                    ← 💉 حقن التبعيات (Dependency Injection)
│   ├── bindings.dart            ← ملف التصدير
│   └── app_bindings.dart        ← ربط كل شاشة بمتحكمها
│
├── routes/                      ← 🗺️ إدارة المسارات (Navigation)
│   ├── app_routes.dart          ← أسماء المسارات
│   └── app_pages.dart           ← ربط المسارات بالشاشات والربط
│
├── core/                        ← ⚙️ الطبقة الأساسية (لا تعتمد على UI)
│   ├── core.dart                ← ملف التصدير
│   ├── config/
│   │   └── api_config.dart      ← إعدادات API المركزية
│   ├── network/
│   │   ├── dio_client.dart      ← عميل Dio المشترك
│   │   └── dio_interceptors.dart← معترضات الطلبات
│   ├── exceptions/
│   │   └── api_exceptions.dart  ← استثناءات مخصصة
│   └── services/
│       ├── services.dart        ← ملف التصدير
│       ├── post_api_service.dart ← خدمة المنشورات
│       ├── user_api_service.dart ← خدمة المستخدمين
│       └── file_upload_service.dart ← خدمة رفع الملفات
│
├── models/                      ← 📦 نماذج البيانات
│   ├── models.dart              ← ملف التصدير
│   ├── post_model.dart
│   ├── user_model.dart
│   ├── api_response.dart
│   └── file_upload_response.dart
│
└── screens/                     ← 🖥️ واجهة المستخدم (Views)
    ├── screens.dart             ← ملف التصدير
    ├── home/
    ├── get_request/
    ├── post_request/
    ├── update_request/
    ├── delete_request/
    ├── file_upload/
    ├── error_handling/
    └── best_practices/
```

### 1.3 مبدأ فصل الاهتمامات (10 دقائق)

**Separation of Concerns:**

| الطبقة              | المسؤولية                | مثال                     |
| ------------------- | ------------------------ | ------------------------ |
| **Screens (Views)** | عرض البيانات             | `GetRequestScreen`       |
| **Controllers**     | منطق العمل وإدارة الحالة | `GetRequestController`   |
| **Services**        | التواصل مع API           | `PostApiService`         |
| **Models**          | تمثيل البيانات           | `PostModel`              |
| **Core**            | إعدادات وأدوات مشتركة    | `DioClient`, `ApiConfig` |
| **Bindings**        | حقن التبعيات             | `GetRequestBinding`      |
| **Routes**          | إدارة التنقل             | `AppRoutes`, `AppPages`  |

**القاعدة الذهبية:**

> "الشاشة لا تعرف عن Dio. المتحكم لا يعرف عن الودجات. الخدمة لا تعرف عن GetX."

**Barrel Files (ملفات التصدير):**

```dart
// lib/models/models.dart
export 'post_model.dart';
export 'user_model.dart';
export 'api_response.dart';
```

> بدل أن تستورد 4 ملفات، تستورد ملف واحد:
> `import 'package:api_learn/models/models.dart';`

---

## 📋 الجزء الثاني: إعداد Dio (30 دقيقة)

### 2.1 لماذا Dio بدل http؟ (5 دقائق)

| الميزة         | http package | Dio |
| -------------- | ------------ | --- |
| Interceptors   | ❌           | ✅  |
| تتبع التقدم    | ❌           | ✅  |
| FormData       | ❌           | ✅  |
| إلغاء الطلب    | ❌           | ✅  |
| إعادة المحاولة | ❌           | ✅  |
| Global Config  | ❌           | ✅  |

### 2.2 ApiConfig - الإعدادات المركزية (10 دقائق)

**افتح `lib/core/config/api_config.dart` وأشرح:**

```dart
abstract class ApiConfig {
  // Base URL - يتغير حسب البيئة (development, staging, production)
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Timeouts - مدد الانتظار
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Endpoints - نقاط النهاية
  static const String posts = '/posts';
  static const String users = '/users';
}
```

**لماذا abstract class؟**

> "حتى ما حدا يقدر ينشئ object منها. هي فقط حامل للثوابت."

**سؤال متوقع:**

> **Q: ليش ما نحط الـ URL مباشرة في الكود؟**
> **A:** لأنك ممكن تبدل بين development server و production server. إذا الـ URL في مكان واحد، تبدله مرة وحدة.

### 2.3 DioClient - العميل المشترك (10 دقائق)

```dart
// Singleton Pattern - نسخة واحدة مشتركة
final Dio dioClient = Dio(
  BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    sendTimeout: ApiConfig.sendTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
)..interceptors.addAll([
    LoggingInterceptor(), // تسجيل الطلبات
    RetryInterceptor(),   // إعادة المحاولة
  ]);
```

**لماذا Singleton؟**

> "مثل ما بالمطعم في جرسون واحد بكفي. ما بدنا ننشئ Dio جديد لكل طلب."

**فوائد:**

1. Connection pooling (إعادة استخدام الاتصالات)
2. إعدادات موحدة
3. Interceptors مشتركة

### 2.4 Interceptors - المعترضات (5 دقائق)

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('📤 ${options.method} ${options.path}');
    handler.next(options); // تابع للطلب التالي
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('📥 ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ Error: ${err.message}');
    handler.next(err);
  }
}
```

**تشبيه:**

> "Interceptor مثل نقطة التفتيش الأمنية بالمطار:
>
> - onRequest: فحص قبل ما يسافر (أضف token, log)
> - onResponse: فحص لما يوصل (log, cache)
> - onError: مشكلة (retry, refresh token)"

**استخدامات عملية:**

1. إضافة Authorization header تلقائياً
2. تسجيل كل الطلبات والاستجابات
3. تجديد Token تلقائياً عند الانتهاء
4. إعادة محاولة الطلبات الفاشلة

---

## 📋 الجزء الثالث: GetX - إدارة الحالة (40 دقيقة)

### 3.1 لماذا GetX؟ (10 دقائق)

**المشكلة مع setState:**

```dart
// ❌ مع setState
class MyScreen extends StatefulWidget { ... }

class _MyScreenState extends State<MyScreen> {
  bool isLoading = false;
  List<Post> posts = [];
  String? error;

  void fetchPosts() {
    setState(() => isLoading = true);
    // ... API call ...
    setState(() {
      isLoading = false;
      posts = result;
    });
  }
}
```

**المشاكل:**

1. المنطق والواجهة مختلطين في ملف واحد
2. الكود طويل ومكرر
3. صعب الاختبار
4. لا يمكن مشاركة الحالة بين شاشات

**الحل مع GetX:**

```dart
// ✅ المتحكم - المنطق فقط
class MyController extends GetxController {
  final isLoading = false.obs;
  final posts = <Post>[].obs;
  final error = Rxn<String>();

  void fetchPosts() async {
    isLoading.value = true;
    // ... API call ...
    isLoading.value = false;
    posts.value = result;
  }
}

// ✅ الشاشة - الواجهة فقط
class MyScreen extends GetView<MyController> {
  Widget build(context) {
    return Obx(() {
      if (controller.isLoading.value) return CircularProgressIndicator();
      return ListView(...);
    });
  }
}
```

### 3.2 المتغيرات التفاعلية (.obs) (10 دقائق)

```dart
// الطريقة 1: .obs
final count = 0.obs;
final name = ''.obs;
final posts = <PostModel>[].obs;
final isLoading = false.obs;
final selectedPost = Rxn<PostModel>(); // nullable

// تحديث القيمة
count.value = 5;
name.value = 'أحمد';
posts.add(newPost);
isLoading.value = true;
selectedPost.value = post; // أو null

// في الواجهة - Obx يُعيد البناء تلقائياً عند التغيير
Obx(() => Text('Count: ${count.value}'));
Obx(() => controller.isLoading.value
  ? CircularProgressIndicator()
  : MyContent());
```

**أسئلة متوقعة:**

> **Q: شو الفرق بين Rx<String> و RxString؟**
> **A:** نفس الشيء. RxString هو اختصار لـ `Rx<String>`. كلاهما يعمل مع `.obs`

> **Q: شو الفرق بين Rxn<T> و Rx<T>؟**
> **A:** `Rxn<T>` يعني nullable (القيمة الأولية null). `Rx<T>` يجب أن يكون له قيمة أولية.

> **Q: متى أستخدم Obx ومتى GetBuilder؟**
> **A:**
>
> - `Obx`: مع المتغيرات التفاعلية (.obs) - يتحدث تلقائياً
> - `GetBuilder`: مع update() اليدوي - أخف في الأداء

### 3.3 GetxController وحياته (10 دقائق)

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // يُستدعى عند إنشاء المتحكم
    // مثل initState
    fetchData();
  }

  @override
  void onReady() {
    super.onReady();
    // يُستدعى بعد أول frame يُرسم
    // مفيد لعرض dialogs أو animations
  }

  @override
  void onClose() {
    // يُستدعى عند حذف المتحكم
    // مثل dispose - نظف الموارد
    myTextController.dispose();
    super.onClose();
  }
}
```

**تشبيه:**

> "onInit = لما تدخل الغرفة (جهز كل شي)
> onReady = لما تقعد (ابدأ الشغل)
> onClose = لما تطلع (نظف وراك)"

### 3.4 GetView وربطه بالمتحكم (10 دقائق)

```dart
// GetView يعطيك access مباشر للمتحكم
class GetRequestScreen extends GetView<GetRequestController> {
  // controller متاح تلقائياً!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: controller.posts.length,
          itemBuilder: (_, i) => Text(controller.posts[i].title),
        );
      }),
    );
  }
}
```

**سؤال متوقع:**

> **Q: كيف GetView يعرف أي Controller يستخدم؟**
> **A:** من خلال الـ Binding! لما تفتح الشاشة، GetX يشوف الـ Binding ويحط المتحكم المطلوب.

---

## 📋 الجزء الرابع: Bindings والتنقل (20 دقائق)

### 4.1 Bindings - حقن التبعيات (10 دقائق)

```dart
class GetRequestBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut ينشئ المتحكم عند أول استخدام
    Get.lazyPut<GetRequestController>(() => GetRequestController());
  }
}
```

**أنواع الحقن:**
| الطريقة | متى يُنشأ | متى يُحذف | الاستخدام |
|---------|-----------|-----------|-----------|
| `Get.put()` | فوراً | عند إغلاق الشاشة | متحكم مطلوب فوراً |
| `Get.lazyPut()` | عند أول استخدام | عند إغلاق الشاشة | الأكثر شيوعاً |
| `Get.putAsync()` | بعد عملية async | عند إغلاق الشاشة | تحميل بيانات أولية |

### 4.2 Named Routes - المسارات المسماة (10 دقائق)

```dart
// 1. تعريف أسماء المسارات
abstract class AppRoutes {
  static const home = '/';
  static const getRequest = '/get-request';
  static const postRequest = '/post-request';
}

// 2. ربط المسارات بالشاشات والـ Bindings
class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.getRequest,
      page: () => const GetRequestScreen(),
      binding: GetRequestBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}

// 3. في main.dart - GetMaterialApp
GetMaterialApp(
  initialRoute: AppRoutes.home,
  getPages: AppPages.pages,
);

// 4. التنقل
Get.toNamed(AppRoutes.getRequest);  // اذهب للشاشة
Get.back();                          // ارجع
Get.offNamed(AppRoutes.home);       // اذهب واحذف السابق
Get.offAllNamed(AppRoutes.home);    // احذف كل الشاشات واذهب
```

**الفرق عن Navigator التقليدي:**

```dart
// ❌ القديم
Navigator.push(context, MaterialPageRoute(builder: (_) => MyScreen()));

// ✅ GetX
Get.toNamed('/my-screen');
```

**فوائد:**

1. لا حاجة لـ context
2. الـ Binding ينشئ المتحكم تلقائياً
3. لما ترجع من الشاشة، المتحكم يتحذف تلقائياً (تنظيف الذاكرة)
4. تمرير بيانات: `Get.toNamed('/detail', arguments: postId)`

---

## 📋 الجزء الخامس: تطبيق عملي (10 دقائق)

### 5.1 افتح المشروع وأظهر التدفق الكامل:

1. `main.dart` → GetMaterialApp مع المسارات
2. `routes/app_pages.dart` → ربط المسارات
3. `bindings/app_bindings.dart` → حقن التبعيات
4. `controllers/get_request_controller.dart` → المنطق
5. `screens/get_request/get_request_screen.dart` → الواجهة
6. `core/network/dio_client.dart` → إعداد Dio
7. `core/config/api_config.dart` → الإعدادات

### 5.2 تتبع طلب GET من البداية للنهاية:

```
1. المستخدم يفتح شاشة GET
2. GetX ينشئ GetRequestController (عبر Binding)
3. onInit() يُستدعى → يستدعي fetchAllPosts()
4. fetchAllPosts() يستخدم PostApiService
5. PostApiService يستخدم dioClient
6. dioClient يرسل GET request مع الإعدادات المركزية
7. Interceptor يسجل الطلب
8. الاستجابة ترجع → PostModel.fromJson()
9. controller.posts.value = نتيجة → Obx يحدث الواجهة تلقائياً
10. المستخدم يرجع ← GetX يحذف المتحكم تلقائياً (تنظيف الذاكرة)
```

---

## ✅ تمارين للطلاب

### تمرين 1: أنشئ Controller بسيط

> أنشئ `CounterController` يحتوي على:
>
> - count (متغير تفاعلي يبدأ من 0)
> - increment() يزيد 1
> - decrement() ينقص 1
> - reset() يرجع لـ 0

### تمرين 2: أنشئ Binding

> أنشئ `CounterBinding` يربط `CounterController`

### تمرين 3: أسئلة نظرية

1. ما الفرق بين Get.put و Get.lazyPut؟
2. لماذا نستخدم abstract class لـ ApiConfig؟
3. ما هو Interceptor؟ أعطِ 3 استخدامات عملية.
4. ما الفرق بين GetView و StatelessWidget؟
5. شو بصير لما المستخدم يرجع من شاشة تستخدم GetView مع Binding؟

---

## 🔑 النقاط الرئيسية للمراجعة

1. التنظيم الجيد = كود قابل للصيانة والاختبار
2. Dio أقوى من http: interceptors, progress, FormData
3. Singleton Pattern = نسخة واحدة مشتركة من DioClient
4. Interceptors = نقاط تفتيش للطلبات والاستجابات والأخطاء
5. GetX يفصل المنطق (Controller) عن الواجهة (View)
6. .obs يجعل المتغيرات تفاعلية → Obx يتحدث تلقائياً
7. Bindings تحقن المتحكمات تلقائياً عند فتح الشاشة
8. Named Routes تسهل التنقل وتنظف الذاكرة تلقائياً

---

## 📚 واجب للمحاضرة القادمة

1. راجع كل ملفات الـ controllers/ و bindings/ و routes/
2. اقرأ كود DioClient و Interceptors
3. حاول تنشئ Controller جديد وتربطه بشاشة
