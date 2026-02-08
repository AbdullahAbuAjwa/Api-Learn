# المحاضرة 4: PUT/PATCH و DELETE و رفع الملفات

# Lecture 4: PUT/PATCH, DELETE & File Upload

**المدة: ساعتين | Duration: 2 hours**

---

## 🎯 أهداف المحاضرة | Lecture Objectives

بنهاية هذه المحاضرة، سيستطيع الطالب:

1. فهم الفرق بين PUT و PATCH لتحديث البيانات
2. تنفيذ حذف البيانات بأساليب مختلفة (pessimistic, optimistic)
3. رفع الملفات باستخدام FormData مع متابعة التقدم
4. استخدام Get.dialog و Get.snackbar وتأكيد العمليات

---

## 📋 الجزء الأول: تحديث البيانات - PUT و PATCH (45 دقيقة)

### 1.1 الفرق بين PUT و PATCH (15 دقيقة)

**تشبيه:**

> "تخيل عندك سيرة ذاتية:
>
> - **PUT** = تمزق الورقة وتكتب سيرة ذاتية جديدة كاملة
> - **PATCH** = تستخدم ممحاة وتعدل السطر المطلوب فقط"

**جدول المقارنة:**
| | PUT | PATCH |
|---|-----|-------|
| المعنى | استبدال كامل | تعديل جزئي |
| Body | كل الحقول مطلوبة | الحقول المتغيرة فقط |
| Idempotent | ✅ نعم | ✅ عادة نعم |
| Safe | ❌ لا | ❌ لا |
| الاستخدام | تحديث كامل للمورد | تحديث حقل أو حقلين |

**مثال عملي:**

```dart
// البيانات الحالية
{
  "id": 1,
  "userId": 1,
  "title": "العنوان القديم",
  "body": "المحتوى القديم"
}
```

```dart
// PUT - يجب إرسال كل الحقول
// إذا نسيت حقل = يرجع null أو يحذف!
PUT /posts/1
{
  "userId": 1,
  "title": "العنوان الجديد",
  "body": "المحتوى الجديد"    // ← لازم ترسل كل الحقول
}
```

```dart
// PATCH - أرسل فقط ما تريد تغييره
PATCH /posts/1
{
  "title": "العنوان الجديد"   // ← فقط الحقل المتغير
}
// body و userId يبقوا كما هم!
```

### 1.2 التنفيذ في المتحكم (15 دقيقة)

**افتح `update_request_controller.dart` وأشرح:**

```dart
class UpdateRequestController extends GetxController {
  final posts = <PostModel>[].obs;
  final selectedPost = Rxn<PostModel>();
  final usePatch = false.obs;           // ← للتبديل بين PUT و PATCH
  final isUpdating = false.obs;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  // اختيار منشور للتعديل
  void selectPost(PostModel post) {
    selectedPost.value = post;
    titleController.text = post.title ?? '';
    bodyController.text = post.body ?? '';
  }

  // تبديل بين PUT و PATCH
  void toggleMethod() {
    usePatch.value = !usePatch.value;
  }

  Future<void> updatePost() async {
    if (selectedPost.value == null) return;
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating.value = true;

      final postId = selectedPost.value!.id;
      final endpoint = '${ApiConfig.posts}/$postId';

      Response response;

      if (usePatch.value) {
        // PATCH - فقط الحقول المتغيرة
        response = await dioClient.patch(
          endpoint,
          data: {'title': titleController.text.trim()},
        );
      } else {
        // PUT - كل الحقول
        response = await dioClient.put(
          endpoint,
          data: {
            'userId': selectedPost.value!.userId,
            'title': titleController.text.trim(),
            'body': bodyController.text.trim(),
          },
        );
      }

      final updatedPost = PostModel.fromJson(response.data);

      // تحديث القائمة المحلية
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        posts[index] = updatedPost;
      }

      Get.snackbar('نجاح ✅', 'تم التحديث');
    } on DioException catch (e) {
      Get.snackbar('خطأ ❌', e.message ?? 'فشل التحديث');
    } finally {
      isUpdating.value = false;
    }
  }
}
```

### 1.3 واجهة شاشة التحديث (10 دقائق)

```dart
class UpdateRequestScreen extends GetView<UpdateRequestController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // القائمة اليسرى - اختر منشور
          Expanded(
            flex: 1,
            child: Obx(() => ListView.builder(
              itemCount: controller.posts.length,
              itemBuilder: (_, i) {
                final post = controller.posts[i];
                return Obx(() => ListTile(
                  title: Text(post.title ?? ''),
                  selected: controller.selectedPost.value?.id == post.id,
                  onTap: () => controller.selectPost(post),
                ));
              },
            )),
          ),

          // النموذج على اليمين - تعديل
          Expanded(
            flex: 2,
            child: Obx(() {
              if (controller.selectedPost.value == null) {
                return Center(child: Text('اختر منشوراً'));
              }
              return Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // تبديل PUT/PATCH
                    Obx(() => ChoiceChip(
                      label: Text(controller.usePatch.value ? 'PATCH' : 'PUT'),
                      selected: true,
                      onSelected: (_) => controller.toggleMethod(),
                    )),
                    // حقول التعديل
                    TextFormField(controller: controller.titleController),
                    TextFormField(controller: controller.bodyController),
                    ElevatedButton(
                      onPressed: controller.updatePost,
                      child: Text('حفظ'),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
```

**سؤال متوقع:**

> **Q: ليش Obx جوات Obx؟**
> **A:** كل Obx يراقب متغيرات معينة. Obx الخارجي يراقب `posts` (القائمة). Obx الداخلي يراقب `selectedPost` (التحديد). إذا تغير التحديد، فقط ListTile يتحدث، لا القائمة كلها!

### 1.4 Edge Cases المهمة (5 دقائق)

> **Edge Case 1: ماذا لو المنشور المحدد حُذف من السيرفر؟**
> تتحقق من الاستجابة: إذا 404 → `selectedPost.value = null` ورسالة خطأ

> **Edge Case 2: ماذا لو المستخدم عدّل وراح بدون ما يحفظ؟**
> فعّل `WillPopScope` أو `Get.dialog()` لتأكيد الخروج

> **Edge Case 3: PUT بدون حقل مطلوب؟**
> الـ API يرجع 400 Bad Request. لهذا نتحقق بالـ form validation أولاً

---

## 📋 الجزء الثاني: حذف البيانات - DELETE (35 دقيقة)

### 2.1 أنواع الحذف (10 دقائق)

**الحذف المتشائم (Pessimistic Delete):**

```
1. أرسل طلب الحذف للسيرفر
2. انتظر الرد
3. إذا نجح → احذف من القائمة المحلية
4. إذا فشل → أظهر رسالة خطأ
```

**المستخدم ينتظر 1-2 ثانية**

**الحذف المتفائل (Optimistic Delete):**

```
1. احذف من القائمة فوراً (الواجهة تتحدث)
2. أرسل طلب الحذف للسيرفر بالخلفية
3. إذا نجح → تم!
4. إذا فشل → أرجع العنصر للقائمة + رسالة خطأ
```

**المستخدم يرى التغيير فوراً!**

### 2.2 الحذف المتشائم (5 دقائق)

```dart
Future<void> deletePost(int postId) async {
  try {
    // 1. أضف ID لقائمة "قيد الحذف"
    deletingIds.add(postId);

    // 2. أرسل طلب الحذف
    await dioClient.delete('${ApiConfig.posts}/$postId');

    // 3. نجح → احذف من القائمة
    posts.removeWhere((p) => p.id == postId);
    Get.snackbar('نجاح', 'تم حذف المنشور');
  } on DioException catch (e) {
    Get.snackbar('خطأ', 'فشل الحذف: ${e.message}');
  } finally {
    deletingIds.remove(postId);
  }
}
```

### 2.3 الحذف المتفائل مع Undo (15 دقائق)

```dart
Future<void> deletePostOptimistic(int postId) async {
  // 1. احفظ نسخة احتياطية
  final index = posts.indexWhere((p) => p.id == postId);
  if (index == -1) return;
  final backup = posts[index];

  // 2. احذف فوراً من الواجهة
  posts.removeAt(index);
  recentlyDeleted.value = backup;

  // 3. أظهر Snackbar مع زر Undo
  Get.snackbar(
    'تم الحذف',
    'المنشور ${backup.title}',
    duration: Duration(seconds: 5),
    mainButton: TextButton(
      onPressed: () => undoDelete(index, backup),
      child: Text('تراجع', style: TextStyle(color: Colors.white)),
    ),
  );

  // 4. أرسل الطلب بالخلفية
  try {
    await dioClient.delete('${ApiConfig.posts}/$postId');
  } catch (e) {
    // 5. فشل! أرجع العنصر
    posts.insert(index, backup);
    Get.snackbar('خطأ', 'فشل الحذف، تم إرجاع المنشور');
  }
}

void undoDelete(int index, PostModel post) {
  if (index <= posts.length) {
    posts.insert(index, post);
  } else {
    posts.add(post);
  }
  recentlyDeleted.value = null;
  Get.closeCurrentSnackbar();
}
```

**سؤال متوقع:**

> **Q: ليش احتجنا backup؟**
> **A:** لأنك حذفت العنصر من القائمة مباشرة. إذا فشل الطلب، كيف ترجعه بدون backup؟

> **Q: شو يصير لو المستخدم ضغط Undo بعد ما الطلب نجح؟**
> **A:** العنصر يرجع في الواجهة بس يكون محذوف من السيرفر. هذا سلوك شائع. لما يرجع يحمل البيانات من جديد سيختفي.

### 2.4 تأكيد الحذف بـ Dialog (5 دقائق)

```dart
Future<bool> confirmDelete(String title) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text('تأكيد الحذف'),
      content: Text('هل تريد حذف "$title"؟'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('حذف', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

**لاحظ:** `Get.dialog<bool>` و `Get.back(result: true)` ← يرجع قيمة من الـ dialog!

### 2.5 سحب للحذف - Dismissible (5 دقائق)

```dart
Dismissible(
  key: Key('post_${post.id}'),  // ← مفتاح فريد مهم جداً!
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 16),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  confirmDismiss: (_) => controller.confirmDelete(post.title ?? ''),
  onDismissed: (_) => controller.deletePostOptimistic(post.id!),
  child: ListTile(title: Text(post.title ?? '')),
)
```

> **Edge Case: ليش Key مهم؟**
> بدون Key فريد، Flutter ممكن يخلط بين العناصر لما تحذف. مثلاً تحذف العنصر الثاني بس الثالث يختفي!

---

## 📋 الجزء الثالث: رفع الملفات (35 دقيقة)

### 3.1 مفهوم رفع الملفات (10 دقائق)

**الفرق عن POST العادي:**
| | POST عادي | POST مع ملف |
|---|-----------|-------------|
| Content-Type | application/json | multipart/form-data |
| Body | JSON text | Binary data + metadata |
| Dio | `data: jsonMap` | `data: FormData` |

**تشبيه:**

> "POST عادي = ترسل رسالة نصية
> POST مع ملف = ترسل طرد بريدي (فيه ورقة + صور + ملفات)"

### 3.2 FormData في Dio (10 دقائق)

```dart
// إنشاء FormData
final formData = FormData.fromMap({
  // حقول نصية
  'title': 'صورة جديدة',
  'description': 'وصف الصورة',

  // ملف
  'file': await MultipartFile.fromFile(
    '/path/to/image.jpg',
    filename: 'image.jpg',
    contentType: DioMediaType('image', 'jpeg'),
  ),
});

// إرسال
final response = await dioClient.post(
  '/upload',
  data: formData,
  onSendProgress: (sent, total) {
    final progress = sent / total;
    print('Progress: ${(progress * 100).toStringAsFixed(0)}%');
  },
);
```

### 3.3 متحكم رفع الملفات (10 دقائق)

```dart
class FileUploadController extends GetxController {
  final selectedFileName = ''.obs;
  final isUploading = false.obs;
  final uploadProgress = 0.0.obs;
  final progressText = ''.obs;

  Future<void> selectFile() async {
    // في الواقع: استخدم file_picker أو image_picker
    // في مشروعنا: نحاكي الاختيار
    final result = await Get.dialog<String>(
      SimpleDialog(
        title: Text('اختر ملف'),
        children: [
          SimpleDialogOption(
            child: Text('📷 image.jpg (2.5 MB)'),
            onPressed: () => Get.back(result: 'image.jpg'),
          ),
          SimpleDialogOption(
            child: Text('📄 document.pdf (1.2 MB)'),
            onPressed: () => Get.back(result: 'document.pdf'),
          ),
        ],
      ),
    );
    if (result != null) selectedFileName.value = result;
  }

  Future<void> uploadFile() async {
    if (selectedFileName.value.isEmpty) {
      Get.snackbar('خطأ', 'اختر ملف أولاً');
      return;
    }

    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      // محاكاة التقدم (في الواقع: onSendProgress)
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(Duration(milliseconds: 200));
        uploadProgress.value = i / 10;
        progressText.value = '${(uploadProgress.value * 100).toInt()}%';
      }

      Get.snackbar('نجاح ✅', 'تم رفع ${selectedFileName.value}');
    } catch (e) {
      Get.snackbar('خطأ ❌', 'فشل الرفع');
    } finally {
      isUploading.value = false;
    }
  }
}
```

### 3.4 شريط التقدم التفاعلي (5 دقائق)

```dart
// شريط التقدم مع Obx
Obx(() => Column(
  children: [
    LinearProgressIndicator(
      value: controller.uploadProgress.value,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
    SizedBox(height: 8),
    Text(controller.progressText.value),
  ],
))
```

**سؤال متوقع:**

> **Q: كيف أعرض التقدم الحقيقي مع Dio؟**
> **A:** باستخدام `onSendProgress` callback:
>
> ```dart
> await dioClient.post(
>   '/upload',
>   data: formData,
>   onSendProgress: (sent, total) {
>     uploadProgress.value = sent / total;
>   },
> );
> ```

> **Q: شو لو المستخدم أغلق الشاشة أثناء الرفع؟**
> **A:** استخدم CancelToken:
>
> ```dart
> final cancelToken = CancelToken();
>
> @override
> void onClose() {
>   cancelToken.cancel('User left screen');
>   super.onClose();
> }
>
> await dioClient.post('/upload', cancelToken: cancelToken);
> ```

---

## 📋 الجزء الرابع: تطبيق عملي مباشر (5 دقائق)

**شغّل التطبيق وأظهر:**

1. شاشة Update: PUT vs PATCH toggle، اختيار منشور، تعديل، حفظ
2. شاشة Delete: اسحب للحذف، تأكيد dialog، Undo snackbar
3. شاشة Upload: اختيار ملف، شريط تقدم، سجل الرفع

---

## ✅ تمارين للطلاب

### تمرين 1: تعديل متعدد

> أضف زر "تحديث الكل" يستخدم PATCH لتغيير عنوان كل المنشورات.
> **تلميح:** `for (final post in posts) { await dioClient.patch(...) }`

### تمرين 2: حذف متعدد

> أضف CheckBox لاختيار عدة منشورات وزر "حذف المحدد" يحذفهم دفعة واحدة.
> **تلميح:** استخدم `selectedIds = <int>{}.obs` مع `Set`

### تمرين 3: أسئلة نظرية

1. متى نستخدم PUT ومتى PATCH؟ أعطِ مثال واقعي.
2. ما الفرق بين الحذف المتفائل والمتشائم؟ أيهما أفضل للمستخدم؟
3. لماذا نستخدم FormData بدل JSON لرفع الملفات؟
4. ما هي فائدة CancelToken؟
5. لماذا Key مهم في Dismissible؟

**إجابات:**

1. PUT: تحديث ملف شخصي كامل (اسم، بريد، صورة). PATCH: تغيير كلمة السر فقط.
2. متفائل أفضل للمستخدم (فوري)، لكن أعقد في التنفيذ. متشائم أبسط وأكثر أماناً.
3. لأن JSON لا يدعم البيانات الثنائية (binary). الملفات بحاجة multipart/form-data.
4. إلغاء طلبات HTTP قيد التنفيذ (مثلاً عند مغادرة الشاشة أو ضغط زر إلغاء).
5. بدون Key فريد، Flutter لا يستطيع التمييز بين العناصر ويحذف العنصر الخطأ.

---

## 🔑 النقاط الرئيسية للمراجعة

1. PUT = استبدال كامل، PATCH = تعديل جزئي
2. الحذف المتفائل أسرع للمستخدم لكن يحتاج backup
3. Get.dialog يرجع قيمة ← مفيد لتأكيد العمليات
4. FormData لرفع الملفات، onSendProgress لمتابعة التقدم
5. CancelToken يلغي طلبات قيد التنفيذ
6. Dismissible يحتاج Key فريد لكل عنصر
7. deletingIds (Set) يتتبع العناصر قيد الحذف لعرض loading فردي

---

## 📚 واجب للمحاضرة القادمة

1. جرب الفرق بين PUT و PATCH عملياً
2. اقرأ كود `error_handling_controller.dart` و `api_exceptions.dart`
3. فكّر: ما أنواع الأخطاء التي ممكن تحصل في تطبيق API؟
