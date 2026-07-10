# Profile Editing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users edit profile values and choose a replacement avatar for the current session, with native pickers that respect the active app theme.

**Architecture:** `ProfileScreen` owns a small draft model and the active inline-edit field. `ProfileAvatar` becomes a presentation widget for an asset or selected file. A shared Cupertino-theme wrapper maps Material `ColorScheme` values into the platform sheet so both the existing language picker and profile picker have consistent colors.

**Tech Stack:** Flutter, `flutter_test`, `image_picker`, Material 3, Cupertino.

## Global Constraints

- Keep profile changes in memory only; add no profile repository, provider, API call, or persistence.
- Use a native `CupertinoActionSheet` on iOS and a Material modal sheet on Android.
- iOS and Material sheet actions must be Take Photo, Choose from Library, and Cancel.
- Preserve the current NQAAE glass-card profile layout and inline value alignment.
- Make Cupertino sheet colors derive from the active Material `ThemeData` and `ColorScheme`.

---

## File structure

- Create `lib/shared/widgets/app_cupertino_theme.dart`: converts Material theme into a `CupertinoTheme` for popup content.
- Modify `lib/features/profile/widgets/profile_avatar.dart`: receives a selected file image and a camera callback, retaining the bundled avatar fallback.
- Modify `lib/features/profile/screens/profile_screen.dart`: owns the in-session draft, inline editor, source picker, and save confirmation.
- Modify `lib/features/settings/screens/settings_screen.dart`: wraps its existing iOS language action sheet in the shared Cupertino theme.
- Modify `pubspec.yaml` and `ios/Runner/Info.plist`: adds `image_picker` and iOS permission copy.
- Modify `test/widget_test.dart`: profile editing, picker, save, and Cupertino-theme widget coverage.

### Task 1: Add a testable Cupertino theme bridge

**Files:**
- Create: `lib/shared/widgets/app_cupertino_theme.dart`
- Modify: `test/widget_test.dart`

**Interfaces:** Produces `AppCupertinoTheme({required Widget child})`, which exposes the Material `ColorScheme.primary` as `CupertinoTheme.of(context).primaryColor`.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('AppCupertinoTheme maps Material colors to Cupertino actions', (tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.darkTheme,
    home: AppCupertinoTheme(child: Builder(
      builder: (context) => Text('theme probe',
        style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
    )),
  ));
  expect(tester.widget<Text>(find.text('theme probe')).style?.color,
      AppTheme.darkTheme.colorScheme.primary);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget_test.dart --plain-name "AppCupertinoTheme maps Material colors to Cupertino actions"`

Expected: FAIL because `AppCupertinoTheme` is undefined.

- [ ] **Step 3: Add minimal implementation**

```dart
class AppCupertinoTheme extends StatelessWidget {
  const AppCupertinoTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final material = Theme.of(context);
    final scheme = material.colorScheme;
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: material.brightness,
        primaryColor: scheme.primary,
        scaffoldBackgroundColor: scheme.surface,
        barBackgroundColor: scheme.surface,
        textTheme: CupertinoTextThemeData(
          actionTextStyle: material.textTheme.labelLarge?.copyWith(color: scheme.primary),
          textStyle: material.textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        ),
      ), child: child,
    );
  }
}
```

- [ ] **Step 4: Verify and commit**

Run: `flutter test test/widget_test.dart --plain-name "AppCupertinoTheme maps Material colors to Cupertino actions"`

Expected: PASS.

```bash
git add lib/shared/widgets/app_cupertino_theme.dart test/widget_test.dart
git commit -m "feat: theme Cupertino popup content"
```

### Task 2: Make the profile card draft-editable

**Files:**
- Modify: `lib/features/profile/screens/profile_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:** Produces stable keys `profile-value-full-name`, `profile-editor-full-name`, and `profile-save-button`; submitting an inline editor updates the in-session draft.

- [ ] **Step 1: Write the failing interaction test**

```dart
testWidgets('ProfileScreen edits a value inline and saves the draft', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
  await tester.tap(find.byKey(const ValueKey('profile-value-full-name')));
  await tester.enterText(find.byKey(const ValueKey('profile-editor-full-name')), 'Jaloliddin Ozodov');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  expect(find.text('Jaloliddin Ozodov'), findsOneWidget);
  await tester.tap(find.byKey(const ValueKey('profile-save-button')));
  await tester.pump();
  expect(find.text('Changes saved'), findsOneWidget);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget_test.dart --plain-name "ProfileScreen edits a value inline and saves the draft"`

Expected: FAIL because the display and editor keys do not exist.

- [ ] **Step 3: Implement the local draft and editor**

Create private `_ProfileDraft` fields for the four existing values. Replace `_ProfileInfoCard` with a callback-driven card: an inactive value is an `InkWell` containing the current right-aligned text, while the active value is a focused `TextField`. Submit and focus-loss trim the value into the draft; normalize username by removing a leading `@` before editing and adding it when displaying. Give every field stable keys. Set the save button key to `profile-save-button`; it unfocuses, commits any active text, and calls `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved')))`.

- [ ] **Step 4: Verify and commit**

Run: `flutter test test/widget_test.dart --plain-name "ProfileScreen edits a value inline and saves the draft"`

Expected: PASS.

```bash
git add lib/features/profile/screens/profile_screen.dart test/widget_test.dart
git commit -m "feat: edit profile fields inline"
```

### Task 3: Add avatar-source selection and theme both Cupertino sheets

**Files:**
- Modify: `pubspec.yaml`
- Modify: `ios/Runner/Info.plist`
- Modify: `lib/features/profile/widgets/profile_avatar.dart`
- Modify: `lib/features/profile/screens/profile_screen.dart`
- Modify: `lib/features/settings/screens/settings_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:** Consumes `ImagePicker.pickImage(source: ImageSource.camera|gallery)` behind an injectable callback. `ProfileAvatar` consumes `ImageProvider? image` and `VoidCallback? onCameraPressed`.

- [ ] **Step 1: Write failing source-picker and Cupertino-theme tests**

```dart
testWidgets('Profile camera opens the iOS source action sheet', (tester) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.darkTheme,
    home: Theme(data: AppTheme.darkTheme.copyWith(platform: TargetPlatform.iOS),
      child: const ProfileScreen()),
  ));
  await tester.tap(find.byKey(const ValueKey('profile-camera-button')));
  await tester.pumpAndSettle();
  expect(find.text('Take Photo'), findsOneWidget);
  expect(find.text('Choose from Library'), findsOneWidget);
  expect(CupertinoTheme.of(tester.element(find.text('Take Photo'))).primaryColor,
      AppTheme.darkTheme.colorScheme.primary);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget_test.dart --plain-name "Profile camera opens the iOS source action sheet"`

Expected: FAIL because the camera control has no handler or source sheet.

- [ ] **Step 3: Implement platform pickers and rendering**

Add `image_picker: ^1.1.2` and run `flutter pub get`. Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist`, both explaining that the resource replaces the profile photo. In `ProfileAvatar`, use `image ?? const AssetImage('assets/images/profile-avatar.png')` and wrap the camera icon in `InkResponse(onTap: onCameraPressed)`. In `ProfileScreen`, present `showCupertinoModalPopup<ImageSource?>` on iOS with `AppCupertinoTheme(child: CupertinoActionSheet(...))`, and a Material `showModalBottomSheet<ImageSource?>` otherwise. Both expose Take Photo, Choose from Library, and Cancel. After selection, invoke the injected picker callback and, if a non-null path returns while mounted, assign `FileImage(File(path))` to the draft image. Wrap SettingsScreen’s existing Cupertino language `CupertinoActionSheet` in `AppCupertinoTheme`.

- [ ] **Step 4: Verify focused tests**

Run: `flutter test test/widget_test.dart --plain-name "Profile camera opens the iOS source action sheet"`

Expected: PASS.

- [ ] **Step 5: Verify integration and commit**

Run: `flutter analyze && flutter test`

Expected: both commands exit 0.

```bash
git add pubspec.yaml pubspec.lock ios/Runner/Info.plist lib/shared/widgets/app_cupertino_theme.dart lib/features/profile/widgets/profile_avatar.dart lib/features/profile/screens/profile_screen.dart lib/features/settings/screens/settings_screen.dart test/widget_test.dart
git commit -m "feat: choose a profile photo"
```
