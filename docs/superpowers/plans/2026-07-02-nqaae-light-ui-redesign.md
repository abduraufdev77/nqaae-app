# NQAAE Light UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the Flutter app into a light NQAAE-style university listing and detail experience backed only by imported backend data.

**Architecture:** Keep the existing backend API. Add Flutter model display helpers, a paged Riverpod notifier for list/search/infinite scroll, and replace dashboard/detail widgets with source-style sections.

**Tech Stack:** Flutter 3.44, Riverpod, GoRouter, `http`, local FastAPI backend.

---

### Task 1: Data Behavior Tests

**Files:**
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/test/university_model_test.dart`
- Create: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/test/university_repository_test.dart`

- [ ] Add tests that verify metrics with `soon`, `Tez kunda`, blurred-placeholder-like values, or empty values are hidden.
- [ ] Add tests that verify repository requests include `search`, `page`, and `page_size`.
- [ ] Run `flutter test` and confirm the new tests fail before implementation.

### Task 2: Data Helpers and Repository

**Files:**
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/universities/models/university.dart`
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/universities/repositories/university_repository.dart`

- [ ] Implement `visibleMetrics`, `metricValue`, and placeholder filtering.
- [ ] Keep repository pagination/search parameters explicit.
- [ ] Run targeted tests and confirm they pass.

### Task 3: List State and UI

**Files:**
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/universities/providers/university_providers.dart`
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/dashboard/screens/dashboard_screen.dart`
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/main.dart`
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/core/theme/app_theme.dart`

- [ ] Add list state/notifier with search, paging, refresh, and load-more.
- [ ] Replace dashboard content with a source-style list screen: breadcrumbs/title, search card, logo/name list, infinite scroll loading indicator.
- [ ] Switch app theme mode to light.

### Task 4: Detail UI

**Files:**
- Modify: `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/universities/screens/university_detail_screen.dart`

- [ ] Replace generic detail page with source-style header, cards, stats, donut chart, bars, metric groups, accreditations, programs, and contacts.
- [ ] Ensure no `soon`/`Tez kunda` placeholders render.

### Task 5: Verification

**Files:**
- All touched files.

- [ ] Run `dart format`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Verify backend endpoints still respond.
- [ ] Reload the in-app browser on the local Flutter app and visually inspect dashboard and detail pages.
