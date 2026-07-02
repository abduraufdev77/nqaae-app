# NQAAE Preview Backend Design

## Goal

Build a preview backend and database for the Flutter app so the app requests higher-education institution data from a local API instead of hardcoded dashboard data.

## Source Pages

- Listing page: `https://nqaae.uz/uz/higher`
- Listing AJAX endpoint: `https://nqaae.uz/ajax/higher/filter?language=uz`
- Detail page example: `https://nqaae.uz/uz/higher/89`

The listing endpoint returns HTML table fragments, not JSON. It is paginated by offset values from `0` through `200` and currently exposes 218 university detail links. Detail pages are server-rendered HTML, with some visible values stored in text, `data-count` attributes, and embedded JavaScript arrays.

## Architecture

Create a sibling backend folder named `/Users/abduraufqarshiboyev/nqaae/nqaae-app-backend`.

Use FastAPI with SQLAlchemy and SQLite for the preview database. The SQLAlchemy database URL will be configurable through `DATABASE_URL` so MySQL can be used later without changing the Flutter API contract.

The importer will fetch listing pages, parse all listing rows, fetch each detail page, parse structured sections, and store the raw HTML snapshot for traceability. Raw snapshots are part of the data model because the inspected detail pages include malformed placeholder values and section-specific markup that should not be lost during preview parsing.

## Database

Primary tables:

- `universities`: source id, name, detail URL, logo URL, region, ownership, category, founded year, phone, website, email, address.
- `university_metrics`: flexible section/key/value/unit/date rows for page stats such as student totals, staff counts, science indicators, international activity, building capacity, and rating values.
- `education_directions`: education direction composition labels and percentages.
- `student_breakdowns`: named student count rows such as bachelor, master, doctoral, admissions, graduates, employment, and quality index.
- `survey_results`: survey group, year, question text, positive percent, negative percent.
- `accreditations`: accreditation type, status, certificate number, issued date, expiry date, certificate URL.
- `accreditation_programs`: program type, code, name, country, certificate text or URL.
- `source_snapshots`: listing/detail HTML, source URL, fetched timestamp.

## API

- `GET /api/health`: returns service health and database status.
- `GET /api/filters`: returns distinct regions, ownership values, and categories.
- `GET /api/universities`: supports `search`, `region`, `ownership`, `category`, `page`, and `page_size`.
- `GET /api/universities/{source_id}`: returns one university with metrics, directions, student breakdowns, surveys, accreditations, programs, and contact fields.

## Flutter Integration

Add an API client, university models, repository, Riverpod providers, list widgets, and a detail screen. The dashboard will request real university data from the backend and display loading, error, empty, list, and detail states.

For local development, the default API base URL is `http://127.0.0.1:8000`. It can be overridden at compile time with `--dart-define=NQAAE_API_BASE_URL=...`.

## Testing

Backend tests cover:

- listing HTML parsing,
- detail HTML parsing from the inspected university page shape,
- API list/filter/detail responses against a seeded test database.

Flutter tests cover:

- model JSON parsing,
- repository/provider behavior through mocked HTTP responses where practical,
- existing widget smoke tests after dashboard integration.

## Constraints

The Flutter app is not currently inside a Git repository, so the design document cannot be committed from this workspace.
