# المحاضرة 3: طلبات GET و POST مع تحليل JSON وحالة GetX التفاعلية

# Lecture 3: GET & POST Requests with JSON Parsing & Reactive GetX State

**المدة: ساعتين | Duration: 2 hours**

---

## 🎯 أهداف المحاضرة | Lecture Objectives

بنهاية هذه المحاضرة، سيستطيع الطالب:

1. إرسال طلبات GET مختلفة (كل البيانات، بالـ ID، بفلترة، بترقيم الصفحات)
2. إرسال طلبات POST مع التحقق من المدخلات
3. فهم كيفية تحويل JSON إلى Dart objects والعكس
4. إدارة حالة الشاشة تفاعلياً باستخدام GetX (.obs + Obx)

---

## 📋 الجزء الأول: طلبات GET (45 دقيقة)

### 1.1 أنواع طلبات GET (10 دقائق)

**ابدأ بتشبيه:**

> "GET مثل ما تدخل مكتبة وتطلب كتب:
>
> - 'أعطني كل الكتب' → GET /books
> - 'أعطني كتاب رقم 5' → GET /books/5
> - 'أعطني كتب المؤلف أحمد' → GET /books?author=أحمد
> - 'أعطني أول 10 كتب' → GET /books?\_page=1&\_limit=10"

### 1.2 جلب كل البيانات (10 دقائق)

**افتح `get_request_controller.dart` وأشرح:**

```dart
// في المتحكم - جلب كل المنشورات
Future<void> fetchAllPosts() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    // Dio يرسل GET request
    final response = await dioClient.get(ApiConfig.posts);

    // تحويل كل عنصر من JSON إلى PostModel
    final List<PostModel> fetchedPosts = (response.data as List)
        .map((json) => PostModel.fromJson(json))
        .toList();

    // تحديث القائمة - Obx يحدث الواجهة تلقائياً!
    posts.value = fetchedPosts;
  } on DioException catch (e) {
    errorMessage.value = e.message ?? 'خطأ غير معروف';
  } finally {
    isLoading.value = false;
  }
}
```

**شرح التدفق خطوة بخطوة:**

1. `isLoading.value = true` → الشاشة تعرض مؤشر التحميل فوراً
2. `dioClient.get()` → يرسل الطلب (async - ينتظر)
3. `response.data` → البيانات كـ List<dynamic>
4. `.map((json) => PostModel.fromJson(json))` → تحويل كل JSON map إلى object
5. `posts.value = fetchedPosts` → الشاشة تُحدث تلقائياً وتعرض القائمة

### 1.3 جلب بيانات بالـ ID (5 دقائق)

```dart
Future<void> fetchPostById(int id) async {
  try {
    isLoading.value = true;

    // GET /posts/1
    final response = await dioClient.get('${ApiConfig.posts}/$id');
    selectedPost.value = PostModel.fromJson(response.data);
  } on DioException catch (e) {
    errorMessage.value = e.message ?? 'خطأ غير معروف';
  } finally {
    isLoading.value = false;
  }
}
```

**سؤال متوقع:**

> **Q: ليش ما نجيب المنشور من القائمة الموجودة بدل ما نرسل طلب جديد؟**
> **A:** ممكن! لكن أحياناً بتحتاج بيانات أكثر تفصيلاً من الـ detail endpoint. مثلاً: القائمة تعطيك العنوان، لكن التفاصيل تعطيك التعليقات كمان.

### 1.4 الفلترة بـ Query Parameters (10 دقائق)

```dart
// GET /posts?userId=1
Future<void> fetchPostsByUser(int userId) async {
  try {
    isLoading.value = true;

    final response = await dioClient.get(
      ApiConfig.posts,
      queryParameters: {'userId': userId},  // ← Query Params
    );

    posts.value = (response.data as List)
        .map((json) => PostModel.fromJson(json))
        .toList();
  } on DioException catch (e) {
    errorMessage.value = e.message ?? 'خطأ';
  } finally {
    isLoading.value = false;
  }
}
```

**اشرح Query Parameters:**

```
الرابط بدون query: https://api.com/posts
الرابط مع query:   https://api.com/posts?userId=1
متعدد:              https://api.com/posts?userId=1&_limit=5
```

**في الشاشة - فلترة تفاعلية:**

```dart
// Filter Chips
Obx(() => Wrap(
  children: [
    ChoiceChip(
      label: Text('الكل'),
      selected: controller.filterByUserId.value == null,
      onSelected: (_) {
        controller.filterByUserId.value = null;
        controller.fetchAllPosts();
      },
    ),
    for (int i = 1; i <= 5; i++)
      ChoiceChip(
        label: Text('مستخدم $i'),
        selected: controller.filterByUserId.value == i,
        onSelected: (_) {
          controller.filterByUserId.value = i;
          controller.fetchPostsByUser(i);
        },
      ),
  ],
))
```

### 1.5 ترقيم الصفحات - Pagination (10 دقائق)

```dart
/// Pagination
final currentPage = 1.obs;
final hasMore = true.obs;
final itemsPerPage = 10;

Future<void> fetchPostsPaginated() async {
  if (!hasMore.value || isLoading.value) return;

  try {
    isLoading.value = true;

    final response = await dioClient.get(
      ApiConfig.posts,
      queryParameters: {
        '_page': currentPage.value,
        '_limit': itemsPerPage,
      },
    );

    final newPosts = (response.data as List)
        .map((json) => PostModel.fromJson(json))
        .toList();

    if (newPosts.length < itemsPerPage) {
      hasMore.value = false; // ما في صفحات زيادة
    }

    posts.addAll(newPosts); // أضف on القائمة الحالية (لا تستبدل)
    currentPage.value++;
  } on DioException catch (e) {
    errorMessage.value = e.message ?? 'خطأ';
  } finally {
    isLoading.value = false;
  }
}
```

**مهم جداً:**

> `posts.addAll()` بدل `posts.value = ...` لأننا نضيف للقائمة الموجودة

**سؤال متوقع:**

> **Q: كيف أعرف متى المستخدم وصل لآخر القائمة؟**
> **A:** باستخدام `ScrollController`:
>
> ```dart
> scrollController.addListener(() {
>   if (scrollController.position.pixels >=
>       scrollController.position.maxScrollExtent - 200) {
>     controller.fetchPostsPaginated();
>   }
> });
> ```

---

## 📋 الجزء الثاني: تحويل JSON (20 دقيقة)

### 2.1 من JSON إلى Object يدوياً (10 دقائق)

```dart
class PostModel {
  final int? id;
  final int? userId;
  final String? title;
  final String? body;

  PostModel({this.id, this.userId, this.title, this.body});

  // من JSON إلى Object
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      title: json['title'] as String?,
      body: json['body'] as String?,
    );
  }

  // من Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}
```

**مع json_serializable (المستخدم في المشروع):**

```dart
@JsonSerializable()
class PostModel {
  final int? id;
  final int? userId;
  final String? title;
  final String? body;

  PostModel({this.id, this.userId, this.title, this.body});

  factory PostModel.fromJson(Map<String, dynamic> json)
      => _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
```

**الفرق:**

```
يدوي: أنت تكتب fromJson و toJson حرفياً
json_serializable: الأداة تكتبهم عنك في ملف .g.dart
```

### 2.2 المغلف العام - ApiResponse<T> (10 دقائق)

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
}
```

**لماذا مغلف عام؟**

> "بدل ما كل خدمة ترجع بيانات مختلفة الشكل، نوحّد الشكل:
>
> - success: true/false
> - data: البيانات (أي نوع!)
> - message: رسالة للمستخدم
> - statusCode: رقم الحالة"

**Edge Case:**

> **Q: شو لو الـ JSON رجع بأسماء مختلفة عن المتوقع؟**
> **A:** نستخدم `@JsonKey`:
>
> ```dart
> @JsonKey(name: 'user_name')
> final String? userName;
> ```

---

## 📋 الجزء الثالث: طلبات POST (35 دقيقة)

### 3.1 ما هو POST؟ (5 دقائق)

**تشبيه:**

> "GET = أخذ كتاب من المكتبة
> POST = إضافة كتاب جديد للمكتبة"

**الفرق عن GET:**
| | GET | POST |
|---|-----|------|
| الغرض | جلب بيانات | إرسال/إنشاء بيانات |
| Body | ❌ عادة فارغ | ✅ يحتوي البيانات |
| Idempotent | ✅ نفس النتيجة | ❌ ينشئ بيانات جديدة كل مرة |
| Cache | ✅ قابل للتخزين | ❌ عادة لا يُخزّن |

### 3.2 إنشاء بيانات جديدة (15 دقائق)

**المتحكم:**

```dart
class PostRequestController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final userIdController = TextEditingController();

  final isLoading = false.obs;
  final successMessage = ''.obs;
  final errorMessage = ''.obs;
  final createdPosts = <PostModel>[].obs;

  Future<void> createPost() async {
    // 1. التحقق من صحة النموذج
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      successMessage.value = '';
      errorMessage.value = '';

      // 2. إنشاء الـ Model من المدخلات
      final newPost = PostModel(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        userId: int.tryParse(userIdController.text.trim()) ?? 1,
      );

      // 3. إرسال POST request
      final response = await dioClient.post(
        ApiConfig.posts,
        data: newPost.toJson(), // ← تحويل Object إلى JSON
      );

      // 4. تحويل الاستجابة إلى Object
      final createdPost = PostModel.fromJson(response.data);

      // 5. إضافة للقائمة المحلية
      createdPosts.insert(0, createdPost);

      // 6. رسالة نجاح
      successMessage.value = 'تم الإنشاء! ID: ${createdPost.id}';
      Get.snackbar('نجاح ✅', successMessage.value);

      // 7. تنظيف النموذج
      clearForm();
    } on DioException catch (e) {
      errorMessage.value = e.message ?? 'خطأ غير معروف';
      Get.snackbar('خطأ ❌', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    bodyController.clear();
    userIdController.clear();
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    userIdController.dispose();
    super.onClose();
  }
}
```

### 3.3 التحقق من المدخلات - Form Validation (10 دقائق)

**في الشاشة:**

```dart
Form(
  key: controller.formKey,
  child: Column(
    children: [
      TextFormField(
        controller: controller.titleController,
        decoration: InputDecoration(labelText: 'العنوان'),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'العنوان مطلوب';         // اسم الحقل مطلوب
          }
          if (value.trim().length < 3) {
            return 'العنوان يجب أن يكون 3 أحرف على الأقل';
          }
          return null; // ✅ صالح
        },
      ),
      // ... المزيد من الحقول
    ],
  ),
)
```

> **Q: ليش formKey عند المتحكم وليس عند الشاشة؟**
> **A:** لأن المتحكم يحتاجه في `createPost()` للتحقق: `formKey.currentState!.validate()`

> **Q: هل formKey يحتاج .obs؟**
> **A:** لا! GlobalKey لا يتغير، فما بحاجة لأن يكون تفاعلي.

### 3.4 Get.snackbar - إشعارات GetX (5 دقائق)

```dart
// رسالة نجاح
Get.snackbar(
  'نجاح ✅',
  'تم إنشاء المنشور بنجاح',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.green.withValues(alpha: 0.9),
  colorText: Colors.white,
  duration: Duration(seconds: 3),
);

// رسالة خطأ
Get.snackbar(
  'خطأ ❌',
  'فشل في الإنشاء',
  backgroundColor: Colors.red.withValues(alpha: 0.9),
  colorText: Colors.white,
);

// بدل SnackBar(ScaffoldMessenger) التقليدي!
```

---

## 📋 الجزء الرابع: تطبيق عملي مباشر (15 دقائق)

### 4.1 شغّل التطبيق وأظهر:

1. **شاشة GET:**
   - لاحظ التحميل التلقائي (onInit)
   - فلتر حسب المستخدم (ChoiceChip + Obx)
   - الضغط على منشور → Dialog بالتفاصيل (Get.dialog)
   - اسحب للتحديث (refreshPosts)

2. **شاشة POST:**
   - جرب إرسال فورم فارغ (validation)
   - أدخل بيانات صحيحة وأرسل
   - لاحظ Get.snackbar
   - لاحظ القائمة تتحدث تلقائياً

### 4.2 أظهر الـ Console (Logging Interceptor):

```
📤 GET /posts
📥 200 /posts
📤 GET /posts?userId=1
📥 200 /posts?userId=1
📤 POST /posts
📥 201 /posts
```

---

## ✅ تمارين للطلاب

### تمرين 1: تصفية متقدمة

> أضف ChoiceChip يعرض "المنشورات الطويلة فقط" (body.length > 100)
> **تلميح:** استخدم `.where()` على القائمة

### تمرين 2: تعديل بسيط

> أضف TextFormField جديد لإدخال رقم User ID مخصص في شاشة POST
> **تلميح:** استخدم `int.tryParse()` مع validator

### تمرين 3: أسئلة نظرية

1. ما الفرق بين `posts.value = newList` و `posts.addAll(newList)`؟
2. لماذا نستخدم `factory` في `PostModel.fromJson`؟
3. ما الذي يحدث إذا الـ API أرجع JSON بمفتاح غير موجود في الـ Model؟
4. لماذا نستخدم `trim()` قبل إرسال البيانات؟
5. ما الفرق بين `isLoading.value = true` و `isLoading(true)`؟

**إجابات:**

1. `posts.value = newList` يستبدل القائمة بالكامل. `posts.addAll(newList)` يضيف عناصر جديدة للقائمة الحالية (مفيد في Pagination).
2. `factory` يسمح لنا بإرجاع object من constructor مختلف أو إجراء عمليات قبل إنشاء الـ object. مثلاً تحقق من null.
3. يكون null (لأن الحقل `final int? id` nullable). لهذا نستخدم `?` في Model fields.
4. لإزالة المسافات الزائدة من بداية ونهاية النص. المستخدم ممكن يضغط مسافة بالغلط.
5. لا فرق! كلاهما يعمل. `.value = ` هو الأسلوب الرسمي، و`()` هو اختصار من GetX.

---

## 🔑 النقاط الرئيسية للمراجعة

1. GET يجلب بيانات، POST ينشئ بيانات جديدة
2. Query Parameters تسمح بالفلترة والترقيم
3. `PostModel.fromJson()` يحوّل JSON إلى Dart object
4. `postModel.toJson()` يحوّل Dart object إلى JSON
5. Form Validation يتحقق من صحة المدخلات قبل الإرسال
6. `isLoading.obs` + `Obx()` = تحديث واجهة تلقائي
7. `Get.snackbar()` بديل أبسط لـ ScaffoldMessenger
8. Pagination = تحميل البيانات على دفعات

---

## 📚 واجب للمحاضرة القادمة

1. شغّل شاشات GET و POST وجرب كل الميزات
2. اقرأ كود `update_request_controller.dart` و `delete_request_controller.dart`
3. ابحث عن الفرق بين PUT و PATCH
