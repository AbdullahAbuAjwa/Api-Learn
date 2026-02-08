# المحاضرة 1: مفاهيم RESTful API والنماذج (Models)

# Lecture 1: RESTful API Concepts & Models

**المدة: ساعتين | Duration: 2 hours**

---

## 🎯 أهداف المحاضرة | Lecture Objectives

بنهاية هذه المحاضرة، سيستطيع الطالب:

1. فهم ما هو API وكيف يعمل
2. فهم بنية REST وقواعدها
3. التعرف على أساليب HTTP الخمسة (GET, POST, PUT, PATCH, DELETE)
4. فهم Status Codes وأهميتها
5. إنشاء نماذج Dart من بيانات JSON
6. استخدام json_serializable لتوليد الكود

---

## 📋 الجزء الأول: ما هو API؟ (30 دقيقة)

### 1.1 التعريف (10 دقائق)

**ابدأ بسؤال الطلاب:**

> "كيف يتواصل تطبيق الموبايل مع السيرفر؟ لما تفتح تطبيق Twitter مثلاً، كيف البيانات توصلك؟"

**الشرح:**

- API = Application Programming Interface (واجهة برمجة التطبيقات)
- هي "عقد" بين الـ Client (التطبيق) والـ Server
- مثل قائمة المطعم: أنت تطلب، والمطبخ يجهز، والجرسون يوصلك
- الـ Client يرسل **Request** (طلب)
- الـ Server يرسل **Response** (استجابة)

**مثال عملي على السبورة:**

```
[📱 تطبيق Flutter] ──── Request ────> [🖥️ Server]
[📱 تطبيق Flutter] <──── Response ──── [🖥️ Server]
```

**رسم توضيحي:**

```
طلب GET /posts/1
├── URL: https://jsonplaceholder.typicode.com/posts/1
├── Method: GET
├── Headers: { Content-Type: application/json }
└── Body: (فارغ في GET)

استجابة:
├── Status Code: 200 OK
├── Headers: { Content-Type: application/json }
└── Body: { "id": 1, "title": "...", "body": "...", "userId": 1 }
```

### 1.2 أنواع APIs (10 دقائق)

- **REST API** (الأكثر شيوعاً - نركز عليه)
- **GraphQL** (Facebook) - الطلب يحدد شكل الاستجابة
- **gRPC** (Google) - سريع جداً، binary protocol
- **WebSocket** - تواصل ثنائي الاتجاه (real-time)
- **SOAP** - قديم، XML-based

> 💡 نصيحة: 90% من التطبيقات تستخدم REST API

### 1.3 JSON - لغة البيانات (10 دقائق)

**اشرح JSON بمثال بسيط:**

```json
{
  "name": "أحمد",
  "age": 22,
  "isStudent": true,
  "courses": ["Flutter", "Dart"],
  "address": {
    "city": "عمان",
    "country": "الأردن"
  }
}
```

**أنواع البيانات في JSON:**
| النوع | المثال | ملاحظة |
|-------|--------|--------|
| String | `"hello"` | دائماً بين علامتي تنصيص مزدوجة |
| Number | `42`, `3.14` | أعداد صحيحة وعشرية |
| Boolean | `true`, `false` | |
| Array | `[1, 2, 3]` | قائمة مرتبة |
| Object | `{"key": "value"}` | أزواج مفتاح-قيمة |
| null | `null` | غياب القيمة |

**سؤال للطلاب:**

> "شو الفرق بين JSON Object و JSON Array؟ امتى نستخدم كل واحد؟"

---

## 📋 الجزء الثاني: REST بالتفصيل (30 دقيقة)

### 2.1 مبادئ REST (10 دقائق)

REST = **RE**presentational **S**tate **T**ransfer

**القواعد الأساسية:**

1. **كل شيء مورد (Resource)**
   - `/users` → مجموعة المستخدمين
   - `/users/1` → مستخدم واحد
   - `/users/1/posts` → منشورات مستخدم

2. **Stateless (بدون حالة)**
   - كل طلب مستقل عن الآخر
   - السيرفر ما بحفظ معلومات عن الـ Client
   - كل طلب لازم يحمل كل المعلومات المطلوبة

3. **واجهة موحدة (Uniform Interface)**
   - نفس القواعد لكل المصادر
   - GET, POST, PUT, DELETE

4. **Client-Server**
   - فصل الواجهة عن البيانات
   - كل واحد ممكن يتطور بشكل مستقل

### 2.2 أساليب HTTP الخمسة (15 دقائق)

**ارسم جدول على السبورة:**

| الأسلوب    | الوظيفة    | آمن؟ | Idempotent؟ | مثال                  |
| ---------- | ---------- | ---- | ----------- | --------------------- |
| **GET**    | قراءة      | ✅   | ✅          | جلب قائمة المنشورات   |
| **POST**   | إنشاء      | ❌   | ❌          | إنشاء منشور جديد      |
| **PUT**    | تحديث كامل | ❌   | ✅          | تحديث كل حقول المنشور |
| **PATCH**  | تحديث جزئي | ❌   | ❌          | تحديث العنوان فقط     |
| **DELETE** | حذف        | ❌   | ✅          | حذف منشور             |

**شرح المصطلحات:**

- **آمن (Safe):** لا يعدل البيانات على السيرفر
- **Idempotent:** نفس النتيجة مهما كررت الطلب
  > "إذا حذفت منشور مرة وحذفته مرة ثانية، النتيجة نفسها - المنشور محذوف"

**أسئلة متوقعة من الطلاب:**

> **Q: شو الفرق بين PUT و PATCH؟**
> **A:** PUT يستبدل المورد بالكامل (لازم ترسل كل الحقول). PATCH يحدث الحقول المحددة فقط.
> مثال: إذا عندك user فيه name, email, phone
>
> - PUT: لازم ترسل الثلاثة حتى لو بدك تغير واحد
> - PATCH: ممكن ترسل email فقط

> **Q: ليش POST مش Idempotent؟**
> **A:** لأنك كل ما تنفذ POST بنفس البيانات، يتنشأ مورد جديد بـ ID مختلف

> **Q: شو معنى RESTful؟**
> **A:** RESTful يعني تطبيق يتبع قواعد REST بالكامل (أسماء موارد واضحة، استخدام صحيح لـ HTTP methods)

### 2.3 Status Codes (5 دقائق)

| الكود   | الاسم        | المعنى          | متى يحصل                  |
| ------- | ------------ | --------------- | ------------------------- |
| **200** | OK           | نجاح            | GET, PUT, PATCH, DELETE   |
| **201** | Created      | تم الإنشاء      | POST ناجح                 |
| **204** | No Content   | نجاح بدون محتوى | DELETE ناجح               |
| **400** | Bad Request  | طلب خاطئ        | بيانات ناقصة أو خاطئة     |
| **401** | Unauthorized | غير مصرح        | ما في token أو token خاطئ |
| **403** | Forbidden    | ممنوع           | ما عندك صلاحية            |
| **404** | Not Found    | غير موجود       | المورد غير موجود          |
| **500** | Server Error | خطأ في السيرفر  | مشكلة من السيرفر          |

**نصيحة تعليمية:**

> "فكروا في Status Codes كإشارات المرور:
>
> - 2xx = أخضر ✅ (كل شي تمام)
> - 3xx = أصفر 🟡 (تحويل)
> - 4xx = أحمر 🔴 (أنت غلطان)
> - 5xx = أحمر 🔴 (السيرفر غلطان)"

---

## 📋 الجزء الثالث: النماذج في Dart (40 دقيقة)

### 3.1 لماذا نحتاج نماذج؟ (10 دقائق)

**المشكلة بدون نماذج:**

```dart
// ❌ الطريقة السيئة - بدون type safety
final data = response.data; // dynamic
print(data['title']); // ممكن يكون null أو نوع خاطئ
print(data['tite']); // خطأ إملائي بدون تحذير!
```

**الحل مع نماذج:**

```dart
// ✅ الطريقة الصحيحة - Type safe
final post = PostModel.fromJson(response.data);
print(post.title); // String - مضمون النوع
// print(post.tite); // ❌ خطأ في الكومبايل! IDE يحذرك
```

**الفوائد:**

1. **Type Safety** - الكومبايلر يمسك الأخطاء
2. **Autocomplete** - IDE يقترح الحقول
3. **Documentation** - الكود يشرح نفسه
4. **Validation** - التحقق من البيانات عند التحويل

### 3.2 إنشاء Model يدوياً (15 دقائق)

**اشرح خطوة بخطوة مع الطلاب:**

```dart
/// نموذج المنشور | Post Model
class PostModel {
  // الحقول - كلها final لأن النموذج immutable
  final int id;
  final int userId;
  final String title;
  final String body;

  // الـ Constructor
  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  // تحويل من JSON إلى Model (Deserialization)
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  // تحويل من Model إلى JSON (Serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  // copyWith لإنشاء نسخة معدلة
  PostModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  String toString() => 'PostModel(id: $id, title: $title)';
}
```

**Edge Cases يجب مناقشتها:**

> **سؤال: شو نعمل إذا حقل nullable في JSON؟**

```dart
class UserModel {
  final int id;
  final String? email; // nullable!

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String?, // ممكن يكون null
    );
  }
}
```

> **سؤال: شو لو الـ JSON فيه nested objects؟**

```dart
class PostWithUser {
  final int id;
  final String title;
  final UserModel user; // Nested model

  factory PostWithUser.fromJson(Map<String, dynamic> json) {
    return PostWithUser(
      id: json['id'] as int,
      title: json['title'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
```

> **سؤال: شو لو في قائمة من Objects؟**

```dart
final jsonList = response.data as List;
final posts = jsonList.map((json) => PostModel.fromJson(json)).toList();
```

### 3.3 json_serializable - توليد الكود (15 دقائق)

**المشكلة:** كتابة fromJson/toJson يدوياً ممل ومعرض للأخطاء

**الحل:** json_serializable يولد الكود تلقائياً

**الخطوات:**

1. **إضافة الحزم في pubspec.yaml:**

```yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

2. **إنشاء النموذج:**

```dart
import 'package:json_annotation/json_annotation.dart';

// هذا السطر يربط الملف المولد
part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final int id;
  final int userId;
  final String title;
  final String body;

  const PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  // هذي الدوال تستدعي الكود المولد
  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
```

3. **تشغيل توليد الكود:**

```bash
dart run build_runner build
```

**أسئلة متوقعة:**

> **Q: ليش نستخدم json_serializable بدل نكتب يدوي؟**
> **A:**
>
> 1. أسرع خصوصاً مع models كثيرة
> 2. أقل أخطاء (ما بتنسى حقل)
> 3. التحديث سهل (غير الحقل وأعد التوليد)
> 4. يدعم nested objects وقوائم تلقائياً

> **Q: شو ملف .g.dart؟**
> **A:** ملف مُولَّد تلقائياً يحتوي على كود fromJson/toJson. لا تعدل عليه يدوياً.

> **Q: لازم أنفذ build_runner كل ما أعدل model؟**
> **A:** نعم، أو استخدم `dart run build_runner watch` لمراقبة التغييرات تلقائياً.

---

## 📋 الجزء الرابع: ApiResponse - غلاف الاستجابة (15 دقائق)

### 4.1 لماذا نحتاج ApiResponse؟

**المشكلة:**

```dart
// ❌ بدون غلاف - كل شاشة تتعامل مع الأخطاء بطريقة مختلفة
try {
  final response = await dio.get('/posts');
  // معالجة النجاح
} catch (e) {
  // معالجة الخطأ
}
```

**الحل:**

```dart
// ✅ مع غلاف - طريقة موحدة
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;
  final int? statusCode;
  final ApiError? error;
  final PaginationInfo? pagination;

  bool get hasData => data != null;
}
```

**اشرح كيف يعمل:**

```dart
// في الخدمة
Future<ApiResponse<PostModel>> getPost(int id) async {
  final response = await dio.get('/posts/$id');
  return ApiResponse(
    isSuccess: true,
    data: PostModel.fromJson(response.data),
    statusCode: response.statusCode,
  );
}

// في الشاشة - موحد وبسيط
final result = await service.getPost(1);
if (result.isSuccess && result.hasData) {
  // استخدم result.data!
} else {
  // أظهر result.error?.message
}
```

---

## 📋 الجزء الخامس: تطبيق عملي (15 دقائق)

### 5.1 افتح المشروع وأظهر:

1. **lib/models/post_model.dart** - النموذج مع json_serializable
2. **lib/models/user_model.dart** - نموذج المستخدم مع nested geo/company
3. **lib/models/api_response.dart** - غلاف الاستجابة العام
4. **lib/models/file_upload_response.dart** - نموذج استجابة الرفع

### 5.2 شغّل المشروع وأظهر:

- البيانات تظهر من الـ API
- كيف الـ Models تحول JSON لـ Objects
- الفرق بين البيانات الخام (JSON) والنماذج (Models)

---

## ✅ تمارين للطلاب

### تمرين 1: إنشاء Model (5 دقائق)

```json
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "phone": "1-770-736-8031"
}
```

> أنشئ UserModel من هذا الـ JSON مع fromJson و toJson

### تمرين 2: Nested Model

```json
{
  "id": 1,
  "title": "My Post",
  "author": {
    "name": "Ahmed",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

> أنشئ PostModel و AuthorModel

### تمرين 3: أسئلة نظرية

1. ما الفرق بين PUT و PATCH؟
2. ما معنى Status Code 404؟
3. لماذا GET آمن (safe) و POST ليس كذلك؟
4. ما هو Idempotent؟ أعطِ مثالاً.

---

## 🔑 النقاط الرئيسية للمراجعة

1. API = واجهة تواصل بين Client و Server
2. REST يعتمد على الموارد (Resources) وأساليب HTTP
3. 5 أساليب HTTP: GET (قراءة), POST (إنشاء), PUT (تحديث كامل), PATCH (تحديث جزئي), DELETE (حذف)
4. Status Codes: 2xx نجاح, 4xx خطأ Client, 5xx خطأ Server
5. Models تعطينا Type Safety و Autocomplete
6. json_serializable يولد كود fromJson/toJson تلقائياً
7. ApiResponse يوحد طريقة التعامل مع الاستجابات

---

## 📚 واجب للمحاضرة القادمة

1. رَاجع الملفات في مجلد `lib/models/`
2. حاول إنشاء Model جديد لبيانات من API مختلف
3. اقرأ عن Dio package في pub.dev
