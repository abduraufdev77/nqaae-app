# University Data and Logo Cache Design

## Goal

Prevent the universities list, university details, and university logos from reloading whenever the user changes screens. Cached content must survive app restarts, remain fresh for three hours, and remain usable after expiry when a network refresh fails.

## Scope

This change covers:

- paginated and searched university list responses;
- university detail responses keyed by university source ID;
- university logo images used in list cards and the dashboard header;
- automatic and explicit refresh behavior;
- concurrent request deduplication.

It does not add an offline editing model, background OS jobs, cache settings UI, or a general-purpose cache for unrelated API resources.

## Architecture

### API response cache

Add a small cache-store abstraction under the universities feature. Its production implementation uses `SharedPreferences`, which is already a project dependency, to persist raw response JSON together with its save timestamp. Keeping raw JSON avoids adding serialization methods to the university domain models and preserves the exact server payload.

Cache keys are versioned and deterministic:

- list entries include normalized search text, page, and page size;
- detail entries include the university source ID.

The repository remains the boundary for HTTP and cache access. It exposes cache reads separately from network refreshes so providers can display stale content immediately while a refresh runs. The repository also keeps an in-memory map of in-flight network requests keyed by resource, ensuring simultaneous consumers share one request.

### Provider behavior

The university list notifier initializes from its cached first page. A fresh entry becomes visible immediately and causes no request. A stale entry also becomes visible immediately, then triggers a background refresh. A missing entry retains the existing loading and error behavior while the initial network request runs.

Every fetched list page is cached independently. Search input uses a normalized query-specific cache entry, so results for one query cannot appear as results for another. Explicit refresh bypasses freshness but keeps the current same-query items visible while the request is active.

University details use a family notifier keyed by source ID while preserving the existing `AsyncValue<University>` interface consumed by the dashboard. Fresh details return immediately. Stale details remain visible during a background refresh. If refresh succeeds, the notifier replaces the visible value; if it fails, the stale value remains.

The dashboard stops forcing an empty-query list refresh merely because the user leaves the Universities tab.

### Logo cache

Replace raw `http.get` calls created inside logo widget builds with `CachedNetworkImage` backed by one shared `CacheManager`. The manager uses a three-hour stale period and a bounded object count. Both list logos and the selected-university header logo use the same manager and fallback UI.

The image cache returns stored logo files across widget rebuilds, route changes, and app restarts. When a stored file is stale, the cache manager may display it while revalidating. Failed refreshes retain the available cached file.

## Data Flow

For each list or detail request:

1. Build the versioned cache key.
2. Read and decode the persisted entry.
3. If the entry is less than three hours old, publish it and stop.
4. If the entry is expired, publish it and start one deduplicated background network refresh.
5. If no entry exists, show loading and perform the network request.
6. On success, persist the raw JSON and timestamp, then publish the decoded data.
7. On failure with cached data, keep cached data visible.
8. On failure without cached data, publish the existing error state.

Malformed cached JSON is treated as a cache miss and removed. Cache write failures do not turn a successful network response into a user-visible failure.

## Freshness and Refresh Rules

- Freshness duration: three hours from a successful network response.
- Fresh cache hit: no network request.
- Expired cache hit: stale content immediately plus background refresh.
- Background failure: retain stale content and retry on a later access or explicit refresh.
- Explicit refresh: request the network regardless of age and preserve same-query content during refresh.
- Search change: use only the target query's cached or fetched data.
- Pagination: cache and deduplicate each page independently.

The cache is not eagerly purged at the three-hour mark; three hours determines freshness, not usability. Versioned keys allow future payload changes to bypass incompatible entries.

## Error Handling

- HTTP status handling remains unchanged.
- Invalid persisted payloads are deleted and fetched again.
- Persistence errors are non-fatal and fall back to memory/network behavior.
- A failed refresh does not replace already-rendered stale data with an error screen.
- A failed request with no cached value shows the current error state and retry affordance.
- Logo failures use the existing initial-letter or asset fallback when no cached image is available.

## Testing

Repository and cache-store tests will use an in-memory cache and an injected clock. They will verify:

- fresh list and detail entries avoid HTTP calls;
- entries expire after three hours;
- expired entries are returned as stale;
- successful refreshes replace persisted data and timestamps;
- refresh failure leaves stale data available;
- list keys separate query, page, and page-size combinations;
- concurrent requests for the same resource are deduplicated;
- malformed entries become cache misses;
- cache write failures do not fail successful requests.

Provider and widget tests will verify:

- cached list data renders without an empty loading state;
- stale list and detail data remain visible during refresh;
- a successful background refresh updates visible data;
- a failed background refresh preserves stale data;
- leaving the Universities tab does not issue a list refresh;
- repeated logo widget builds use the shared persistent image-cache path.

The complete Flutter test suite and static analysis must pass before completion.

