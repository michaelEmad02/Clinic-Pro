# 📏 rules.md — Project Rules & AI Behavior

---

## 1. AI Behavior Rules

### 1.1 Plan Before Execute
- **Never implement directly.** Always present a plan first and wait for approval.
- Plan format:
  ```
  📋 Plan for [task name]:
  1. Create file: path/to/file.dart — reason
  2. Modify file: path/to/other.dart — what changes
  3. ...
  Proceed? (yes / modify plan)
  ```

### 1.2 Explain Everything
- After every implementation, write a summary of what was done.
- Every code file must have a **header comment** explaining its purpose.
- Every non-obvious code block must have an **inline comment**.
- Comments language: **Arabic with English technical terms when needed.**

```dart
// ─────────────────────────────────────────
// هذا الملف مسؤول عن جلب بيانات المواعيد من Supabase
// يقوم بتحويل البيانات الخام (raw data) إلى AppointmentModel
// ─────────────────────────────────────────

// جلب مواعيد اليوم الخاصة بالعيادة المحددة
final appointments = await _service.fetchRaw(
  table: SupabaseTables.appointments,
  filters: {'clinic_id': clinicId, 'date': today},
);
```

### 1.3 Phase Control
- At the end of each **Phase**, show a summary of what was completed.
- Then **stop and ask for approval** before moving to the next phase.
- Format:
  ```
  ✅ Phase [N] Complete
  Done:
    ✓ Task 1
    ✓ Task 2
  Ready to proceed to Phase [N+1]? (yes / adjustments needed)
  ```

### 1.4 File Discipline
- Never put all code in one file — always split into logical files.
- Do not create a file unless it is referenced in `project_structure.md` or explicitly requested.
- If a new file is needed, mention it in the plan first.

---

## 2. Coding Standards

### 2.1 General
- Language: **Dart** (Flutter)
- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Max file length: **300 lines** (split if exceeded)
- Max widget length: **100–200 lines** (split into subwidgets if exceeded)

### 2.2 Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `appointment_list_item.dart` |
| Classes | PascalCase | `AppointmentListItem` |
| Variables | camelCase | `appointmentList` |
| Constants | camelCase | `maxRetryCount` |
| Private members | _camelCase | `_appointmentsRepository` |
| Abstract/Interface | prefix `I` | `IAppointmentRepository` |
| Cubit | suffix `Cubit` | `AppointmentsCubit` |
| Bloc | suffix `Bloc` | `PrescriptionBloc` |
| State | suffix `State` | `AppointmentsState` |
| Event (Bloc) | suffix `Event` | `LoadAppointmentsEvent` |
| UseCase | suffix `UseCase` | `GetAppointmentsUseCase` |
| Entity | suffix `Entity` | `AppointmentEntity` |
| Model | suffix `Model` | `AppointmentModel` |
| DataSource | suffix `DataSource` | `AppointmentRemoteDataSource` |

### 2.3 Import Order
```dart
// 1. Dart core
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Project imports (absolute paths)
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
```

---

## 3. Architecture Rules

### 3.1 Layer Boundaries — STRICTLY ENFORCED

| Rule | Description |
|------|-------------|
| ✅ Presentation → Domain | Cubit/Bloc calls UseCases only |
| ✅ Data → Domain | RepositoryImpl implements domain interface |
| ✅ Domain → nothing | Entities and interfaces have zero external dependencies |
| ❌ Presentation → Data | Never call Repository or DataSource directly from UI |
| ❌ Domain → Data | Domain never imports from data layer |
| ❌ Domain → Flutter | No Flutter imports in domain layer |

### 3.2 Service Layer Rules

```
ICloudService / SupabaseService:
  ✅ Communicates with Supabase SDK
  ✅ Returns raw Map<String,dynamic> or List<Map<String,dynamic>>
  ❌ Never parses or transforms data
  ❌ Never returns Models or Entities

DataSource:
  ✅ Calls ICloudService
  ✅ Converts raw data → Model (fromJson)
  ✅ Throws typed Exceptions on error
  ❌ Never contains business logic
```

### 3.3 Either Pattern
All repository methods return `Either<Failure, T>` from `dartz`:

```dart
// Domain repository interface
abstract class IAppointmentRepository {
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(String clinicId);
}

// Cubit handles result
final result = await _getAppointmentsUseCase(clinicId);
result.fold(
  (failure) => emit(AppointmentsError(failure.message)),
  (appointments) => emit(AppointmentsLoaded(appointments)),
);
```

### 3.4 Dependency Injection Rules

```dart
// ✅ Use @injectable / @lazySingleton / @singleton annotations
@LazySingleton(as: IAppointmentRepository)
class AppointmentRepositoryImpl implements IAppointmentRepository {}

// ✅ Inject via constructor only
class GetAppointmentsUseCase {
  final IAppointmentRepository _repository;
  GetAppointmentsUseCase(this._repository);
}

// ❌ Never use getIt<>() inside widgets or business logic
// ✅ Only use getIt<>() at DI registration level or router level
```

---

## 4. Flutter / UI Rules

### 4.1 State Management
```dart
// ✅ Use Cubit for simple state
// ✅ Use Bloc for complex event-driven state
// ❌ Never use setState except for:
//    - AnimationController
//    - TextEditingController listeners that don't affect business logic
//    - Forced Flutter lifecycle edge cases
```

### 4.2 Widget Splitting Rules
- A screen file (`_screen.dart`) must only contain:
  - `build()` method that assembles subwidgets
  - BlocBuilder / BlocListener wrappers
  - **No business logic**
  - **No inline widget trees longer than 20 lines**

```dart
// ✅ Correct — screen delegates to subwidgets
class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppointmentsAppBar(),
      body: const AppointmentsList(),
      floatingActionButton: const AddAppointmentFab(),
    );
  }
}

// ❌ Wrong — everything inline in one file
class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المواعيد'),
        actions: [ IconButton(...), PopupMenuButton(...) ],
      ),
      body: Column(
        children: [
          // 200 lines of widgets...
        ],
      ),
    );
  }
}
```

### 4.3 SubWidget File Location
```
features/appointments/presentation/ui/
├── appointments_screen.dart          ← main screen only
└── widgets/
    ├── appointments_app_bar.dart
    ├── appointments_list.dart
    ├── appointment_list_item.dart
    ├── appointment_filter_chips.dart
    └── add_appointment_sheet.dart
```

### 4.4 Mock Data Rules
```dart
// ❌ Never hardcode data inside a widget or screen
Text('أحمد محمد')   // WRONG

// ✅ Use mock service that implements the same interface
@LazySingleton(as: ICloudService)
class MockCloudService implements ICloudService {
  @override
  Future<List<Map<String, dynamic>>> fetchRaw({
    required String table,
    Map<String, dynamic>? filters,
  }) async {
    // إرجاع بيانات ثابتة للاختبار
    return MockData.appointments;
  }
}

// Mock data file
// core/mocks/mock_data.dart
class MockData {
  static const appointments = [ {...}, {...} ];
  static const patients     = [ {...}, {...} ];
}
```

### 4.5 Responsive Rules
```dart
// ✅ Always use ResponsiveHelper for layout decisions
// ✅ Use LayoutBuilder for widget-level responsiveness
// ✅ Use MediaQuery only for screen dimensions
// ❌ Never hardcode pixel sizes for layout (padding/margin ok with constants)
```

### 4.6 Colors & Styles
```dart
// ✅ Always use AppColors and AppTextStyles
Text('عنوان', style: AppTextStyles.h3)
Container(color: AppColors.primary)

// ❌ Never use raw colors or sizes
Text('عنوان', style: TextStyle(fontSize: 16, color: Color(0xFF1A6B8A)))
```

---

## 5. Performance Rules

- Use `const` constructors wherever possible
- Use `ListView.builder` / `GridView.builder` — never `ListView` with children for long lists
- Avoid rebuilding parent widgets — use targeted `BlocBuilder` with `buildWhen`
- Use `AutomaticKeepAliveClientMixin` for expensive tabs that should not rebuild
- Images: use `cached_network_image` package for all network images
- Avoid `Opacity` widget — use `Color.withOpacity()` instead

---

## 6. Forbidden Practices

```
❌ setState (except documented exceptions)
❌ Direct Supabase calls from UI or Cubit
❌ Business logic inside widgets
❌ Hardcoded strings in widgets (use localization keys)
❌ Hardcoded colors or text styles (use AppColors / AppTextStyles)
❌ Raw data (Map) passed to UI — always use Entities
❌ More than 200 lines in a single widget file
❌ Importing data layer from domain layer
❌ Importing presentation layer from domain or data layers
❌ Creating files not listed in the project structure without prior plan approval
```
