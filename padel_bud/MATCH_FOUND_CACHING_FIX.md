# Match Found Page - Caching Optimization

## Problem
The `FoundMatchPage` was refetching match data every time the widget rebuilt, even when nothing had changed. This was caused by using `FutureBuilder` with a `future` parameter that was called on every rebuild.

## Solution
Implemented a Riverpod-based caching system that:

1. **Caches match data** using `FutureProvider.family` keyed by matchId
2. **Monitors changes** via a Firestore stream provider that listens to the match document
3. **Updates only when needed** - the cache invalidates and refetches only when:
   - The matchId changes
   - The match document in Firestore is modified (buddy status changes, etc.)

## Changes Made

### 1. `lib/repositories/matches_repository.dart`
- Added `matchStream()` method that returns a Stream of match documents
- This enables real-time updates when match or buddy status changes

### 2. `lib/providers/providers.dart`
- Added `foundMatchInfoProvider` - A FutureProvider.family that:
  - Watches the match stream to trigger invalidation on changes
  - Fetches and caches match info (timeSlot, users, club)
  - Invalidates cache when the stream detects changes

- Added `foundMatchStreamProvider` - A StreamProvider.family that:
  - Listens to Firestore match document changes
  - Triggers cache invalidation in the FutureProvider

### 3. `lib/presentation/pages/buddies_page/found_games.dart`
- Removed the `_getMatchInfo()` method which was refetching on every rebuild
- Updated `build()` method to watch userProvider and extract matchId
- Created new `_buildMatchBody()` method that uses the `foundMatchInfoProvider`
- Uses `.when()` pattern for proper async handling (loading, data, error states)

## How It Works

```
User navigates to FoundMatchPage
    ↓
Page watches userProvider for matchId
    ↓
When matchId is available:
  - foundMatchInfoProvider is triggered
  - Starts watching foundMatchStreamProvider
  - foundMatchStreamProvider listens to Firestore match document
  - When data arrives, match info is cached and displayed
    ↓
If buddy status or match changes in Firestore:
  - Stream emits new data
  - foundMatchInfoProvider detects change and invalidates
  - Cache is recomputed with new data
    ↓
If matchId stays the same:
  - No refetch happens (cached data is reused)
```

## Benefits
- **Reduced database calls** - Only fetches when data actually changes
- **Better UX** - No unnecessary loading states while viewing the same match
- **Real-time updates** - Still responds immediately to actual changes via Firestore stream
- **Cleaner code** - Separation of concerns between data fetching (provider) and UI (widget)
