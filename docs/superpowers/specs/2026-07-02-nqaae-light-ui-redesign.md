# NQAAE Light UI Redesign

## Goal

Redesign the Flutter app to use a light NQAAE-style interface that displays only backend-imported data from the NQAAE higher-education listing and detail pages.

## Source References

- Listing: `https://nqaae.uz/uz/higher`
- Detail example: `https://nqaae.uz/uz/higher/89`

## Requirements

- Use light theme throughout the app.
- Use the NQAAE site visual language: pale page background, white content sections, thin light borders, teal/blue gradient accents, 12px-radius controls, and source-like section spacing.
- Higher Education Institutions list should stay simple: logo and university name are the primary visible data.
- Add a search input to the list.
- Use infinite scroll pagination, not numbered pagination.
- Do not display invented dashboard data.
- Do not display `Tez kunda`, blurred, or `soon` placeholder values from the source site.
- University detail page should follow the source detail page structure:
  - logo and university title header,
  - ownership, region, founded year info blocks,
  - summary stats from parsed source metrics,
  - specialization,
  - education directions donut chart,
  - student contingent bars,
  - grouped metrics for staff, science, international activity, infrastructure, rating,
  - accreditation and program sections,
  - contact cards.

## Implementation Notes

The backend API already supports `GET /api/universities?page=&page_size=&search=` and `GET /api/universities/{source_id}`. Flutter should add a paged notifier for the list and reusable display helpers that exclude source placeholders.

The existing dark dashboard composition should be replaced for this feature. Existing auth can remain for now, but post-login surfaces should be light and source-style.

## Verification

- Unit tests should prove placeholder/soon values are filtered out.
- Repository tests should prove search and page query parameters are sent.
- Widget or smoke tests should still pass.
- `flutter analyze` should pass.
- Browser verification should confirm the list and detail pages render in the in-app browser against the local backend.
