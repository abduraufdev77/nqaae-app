# Profile editing design

## Scope

Add in-session editing to the existing profile screen. No persistence, API calls,
or profile repository is introduced in this change.

## Interaction model

- The screen owns a draft profile containing name, phone number, email, username,
  and an optional selected avatar image.
- Each displayed value is tappable. Tapping it replaces only that value with an
  inline text field, prefilled with the draft value and focused for editing.
- Pressing the keyboard's Done action, submitting the field, or moving focus away
  exits edit mode while retaining the new draft value. Username remains displayed
  with its `@` prefix.
- Save Changes commits the current draft for the rest of the running app session
  and confirms success without persistence.

## Avatar selection

- The camera affordance is an accessible tap target and opens a platform-native
  source selector.
- iOS uses a `CupertinoActionSheet` with Take Photo, Choose from Library, and
  Cancel. Android uses a Material bottom sheet with matching choices.
- The image picker result updates the avatar immediately. Cancellation and a
  missing result leave the previous image untouched.

## Theming

- Cupertino popups are wrapped in a `CupertinoTheme` derived from the active
  Material `ThemeData` and `ColorScheme`.
- The language picker and avatar picker therefore use theme-appropriate surface,
  text, separator, and action colors in both light and dark mode.

## Boundaries and future API integration

- Presentation widgets receive values and callbacks instead of owning persistence.
- The draft model and save handler remain local to the screen for now, making it
  straightforward to replace the save handler with a provider/repository call.

## Tests

- Widget tests cover starting and completing inline value editing, saving the
  edited draft, opening the avatar source selector, and app-theme colors reaching
  the Cupertino sheet.
- Avatar-picker platform plugins are injected behind a small callback boundary so
  the profile UI tests do not require native device services.
