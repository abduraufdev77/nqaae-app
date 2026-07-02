# NQAAE Preview Backend Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local preview backend/database from the inspected NQAAE higher-education pages and update the Flutter app to fetch/render that backend data.

**Architecture:** FastAPI exposes a JSON API over a SQLite database populated by an HTML importer. Flutter uses an HTTP repository and Riverpod providers to render the university list and detail data.

**Tech Stack:** Python 3.9, FastAPI, SQLAlchemy, BeautifulSoup, SQLite, pytest, Flutter 3.44, Riverpod, `http`.

---

## File Structure

- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/app/database.py`: database engine/session helpers.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/app/models.py`: SQLAlchemy tables.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/app/schemas.py`: Pydantic response models.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/app/importer.py`: source fetch and HTML parsing.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/app/routers/universities.py`: API routes.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/app/main.py`: FastAPI app setup.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/scripts/import_nqaae.py`: CLI importer.
- `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend/tests`: parser and API tests.
- `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/core/config/api_config.dart`: Flutter API base URL.
- `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/universities`: Flutter models, repository, providers, screens.
- `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/core/router/app_router.dart`: detail route.
- `/Users/abduraufqarshiboyev/nqaae/nqaae_app/lib/features/dashboard/screens/dashboard_screen.dart`: backend-backed list.

## Tasks

### Task 1: Backend Parser Tests

- [ ] Write fixture-backed tests for listing row parsing and detail extraction.
- [ ] Run `pytest` and verify parser tests fail because implementation does not exist.

### Task 2: Backend Schema and Parser

- [ ] Implement database models and parsing helpers.
- [ ] Run parser tests and verify they pass.

### Task 3: Backend API Tests and Routes

- [ ] Write API tests for health, filters, list, and detail endpoints.
- [ ] Run tests and verify they fail before route implementation.
- [ ] Implement routes and schemas.
- [ ] Run tests and verify they pass.

### Task 4: Importer CLI

- [ ] Implement the NQAAE import script.
- [ ] Run a live import into SQLite.
- [ ] Verify the database has all 218 universities and detail snapshots.

### Task 5: Flutter Integration

- [ ] Add `http` dependency and API config.
- [ ] Add university model/repository/provider files.
- [ ] Add university list and detail UI.
- [ ] Wire dashboard and router to the backend-backed university feature.

### Task 6: Verification

- [ ] Run backend tests.
- [ ] Run `flutter pub get`, `flutter analyze`, and `flutter test`.
- [ ] Start the backend and verify `GET /api/universities` and `GET /api/universities/89`.
- [ ] Leave the backend running for local preview if practical.
