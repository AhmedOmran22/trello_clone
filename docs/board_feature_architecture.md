# Board Feature Architecture

This document explains how the **Board** feature — the core screen of the
Trello clone, where columns and tasks live — is built. It covers the
architectural decisions, the data flow for every user action, and the
reasoning behind each choice, written at the depth I'd want to defend in a
system-design interview.

The feature lives at `lib/features/boards/` and is split into the three
Clean Architecture layers: `domain/`, `data/`, `presentation/`.

---

## 1. Feature Overview

### What it does

The board screen shows a horizontally-scrolling set of **columns** (e.g. "To
Do", "In Progress", "Done"), each containing a vertically-stacked list of
**tasks**. A user can:

- Create, rename, reorder, and delete columns
- Create, move, reorder, and delete tasks
- Drag a task within a column to reorder it, or across columns to move it
- See other collaborators' changes appear live, without refreshing

### The Board → Column → Task relationship

```
BoardEntity
 └── id, workspaceId, name, createdAt
 └── columns: List<BoardColumnEntity>
      └── id, boardId, name, position, createdAt
      └── tasks: List<TaskEntity>
           └── id, columnId, title, description, priority, position,
               dueDate, assigneeId, assigneeName, assigneeAvatarUrl, createdAt
```

It's a strict three-level tree, one-directional (a board owns columns, a
column owns tasks — a task never reaches back up). `position` is what
turns each unordered list into an ordered one: it's a plain integer, reset
to `0..n-1` on every reorder, and comparison-sorted everywhere the tree is
rendered.

### Why Bloc, not Cubit, for this feature

The rest of the app (`WorkspaceCubit`, `BoardCubit` for the board *list*,
`AuthCubit`) uses `Cubit` — a single class with methods that call
`emit()` directly. That works well when there's one clear caller (the UI)
driving one clear state machine.

The board **detail** screen breaks that assumption in two ways:

1. **Multiple independent event sources.** State changes arrive from user
   gestures (tap "add task", drag a card) *and* from two independent
   Supabase realtime streams (`watchColumns`, `watchTasks`) running
   concurrently, on their own schedule, for the lifetime of the screen. A
   Cubit has no vocabulary for "here's an event that happened, decide what
   to do" — you'd end up hand-rolling the equivalent of `add()`/`on<T>()`
   anyway.
2. **Traceability.** With `Bloc`, every state transition has a named,
   typed, `Equatable` event attached to it (`TaskMoved`, `ColumnDeleted`,
   `RealtimeTasksUpdated`, ...). When something goes wrong — a card ends up
   in the wrong column, a realtime update stomps on an optimistic one — the
   Bloc's event log tells you *exactly* what sequence of triggers produced
   the bad state. A Cubit's method-call stack gives you the same
   information, but not as structured, replayable data.

The board *list* (shown on the workspace screen) stays a `Cubit` — it's a
flat CRUD surface with a single caller and no streams, so the extra
ceremony of events isn't earning its keep there. Bloc vs. Cubit is a
per-feature call, not a project-wide rule.

---

## 2. Architecture Diagram

Clean Architecture, three layers, dependencies pointing **inward only** —
the domain layer knows nothing about Bloc, Supabase, or Flutter.

```
+-----------------------------------------------------------------+
|                       PRESENTATION LAYER                        |
|                                                                   |
|   board_screen.dart  --add(event)-->  BoardBloc  --state-->  UI  |
|   (widgets)          <---BlocBuilder rebuild---  (Bloc<Event,State>)|
|                                          |                        |
+------------------------------------------|------------------------+
                                            | calls
                                            v
+-----------------------------------------------------------------+
|                          DOMAIN LAYER                            |
|                                                                   |
|   Use Cases (10)              -------->   BoardRepo              |
|   GetBoardUseCase                          (abstract interface)  |
|   CreateColumnUseCase, MoveTaskUseCase,   getBoard / createColumn|
|   ReorderTasksUseCase, ...                / moveTask / watchTasks|
|                                                                   |
|   Entities: BoardEntity -> BoardColumnEntity -> TaskEntity        |
|   (pure Dart, Equatable, no JSON / Supabase knowledge)            |
+------------------------------------------|------------------------+
                                            | implemented by
                                            v
+-----------------------------------------------------------------+
|                           DATA LAYER                             |
|                                                                   |
|   BoardRepositoryImpl  -------->  BoardRemoteDatasource           |
|   (Result<T> / ServerFailure)      (abstract interface)           |
|                                            |                      |
|                                            | implemented by       |
|                                            v                      |
|                                     BoardSupabaseDatasource        |
|                                     services.client.from(...)      |
|                                     throws ServerException         |
|                                            |                      |
|   Models: BoardModel <- BoardColumnModel <- TaskModel             |
|   fromJson / toJson / toEntity()   (used by the datasource above) |
+------------------------------------------|------------------------+
                                            | HTTP / WebSocket
                                            v
                              +--------------------------+
                              |  Supabase                 |
                              |  Postgres + Realtime       |
                              +--------------------------+
```

Dependency direction: an arrow always points from a layer to the thing
it *depends on*. Presentation depends on Domain (`BoardBloc` imports
`BoardRepo`, an interface); Data also depends on Domain (`BoardRepositoryImpl`
*implements* `BoardRepo`) — Domain itself imports nothing from the other
two layers. That inversion (`BoardRepositoryImpl implements BoardRepo`,
rather than `BoardRepo` depending on some concrete Supabase class) is
the Dependency Inversion Principle doing its actual job here: the
Bloc's compile-time dependency is an abstract contract it owns the
shape of, not a concrete implementation it would otherwise be coupled
to.

**Communication rule**: each layer only talks to its **interface**, never
the concrete class below it. `BoardBloc` depends on `BoardRepo` (an
`abstract class`), never on `BoardRepositoryImpl`. This is what lets the
data layer be swapped (e.g. for a fake in tests) without touching a single
line of Bloc or UI code.

---

## 3. Folder Structure

```
lib/features/boards/
├── domain/
│   ├── entity/
│   │   ├── board_entity.dart              # Board: id, workspaceId, name, columns
│   │   ├── board_column_entity.dart       # Column: id, boardId, name, position, tasks
│   │   └── task_entity.dart               # Task + isOverdue/isAssigned/isUrgent/isHigh getters
│   ├── repo/
│   │   └── board_repo.dart                # Abstract contract — 15 methods total
│   └── usecases/
│       ├── create_board_usecase.dart      # (pre-existing) board-list CRUD
│       ├── update_board_usecase.dart
│       ├── delete_board_usecase.dart
│       ├── get_board_usecase.dart         # Fetch one board with nested columns+tasks
│       ├── create_column_usecase.dart     # + name validation
│       ├── rename_column_usecase.dart     # + name validation
│       ├── reorder_columns_usecase.dart   # + position recalculation
│       ├── delete_column_usecase.dart
│       ├── create_task_usecase.dart       # + title/description/priority validation
│       ├── update_task_usecase.dart       # + conditional validation
│       ├── move_task_usecase.dart         # Change a task's column + position
│       ├── reorder_tasks_usecase.dart     # + position recalculation
│       └── delete_task_usecase.dart
│
├── data/
│   ├── models/
│   │   ├── board_model.dart               # fromJson parses nested board_columns
│   │   ├── board_column_model.dart        # fromJson parses nested tasks
│   │   └── task_model.dart                # fromJson parses nested profiles (nullable)
│   ├── datasources/
│   │   ├── board_remote_datasource.dart   # Abstract contract, model-typed
│   │   └── board_supabase_datasource.dart # Concrete Supabase queries + streams
│   └── repo/
│       └── board_repository_impl.dart     # Result<T> + entity conversion wrapper
│
└── presentation/
    ├── bloc/
    │   ├── board_event.dart               # 12 sealed events
    │   ├── board_state.dart               # 4 sealed states
    │   └── board_bloc.dart                # Optimistic updates + realtime merge
    ├── screens/
    │   └── board_screen.dart              # BlocBuilder-driven column scroller
    ├── widgets/
    │   ├── board_column_widget.dart       # Column header/body/footer + DragTarget
    │   ├── task_card_widget.dart          # Trello-style card (pure presentation)
    │   ├── draggable_task_card.dart       # LongPressDraggable wrapper
    │   ├── dashed_placeholder.dart        # Source-slot placeholder while dragging
    │   ├── add_column_bottom_sheet.dart
    │   ├── add_task_bottom_sheet.dart
    │   ├── task_detail_bottom_sheet.dart
    │   ├── move_task_bottom_sheet.dart    # "Move to" alternative to drag & drop
    │   ├── rename_column_bottom_sheet.dart
    │   └── reorder_columns_bottom_sheet.dart
    └── utils/
        ├── drag_task_data.dart            # {task, sourceColumnId} drag payload
        └── date_formatter.dart
```

---

## 4. Data Flow — Complete Lifecycle

### a) Board Loading Flow

```
BoardScreen mounts (router wraps it in BlocProvider<BoardBloc>)
        │
        ▼
BoardBloc constructor runs → add(BoardLoadRequested(boardId))
        │
        ▼
_onBoardLoadRequested   emit(BoardLoading())
        │
        ▼
GetBoardUseCase.call(boardId)
        │
        ▼
BoardRepo.getBoard(boardId)
        │
        ▼
BoardSupabaseDatasource.getBoard()
        │   SELECT * , board_columns(*, tasks(*, profiles(...)))
        │   FROM boards WHERE id = :boardId  (single nested query)
        ▼
Supabase Postgres ── one round trip, fully nested response ──▶
        │
        ▼
BoardModel.fromJson(response)   → recursively builds
        BoardColumnModel.fromJson → TaskModel.fromJson (sorted by position)
        │
        ▼
BoardRepositoryImpl wraps in Result.success(model.toEntity())
        │
        ▼
BoardBloc splits the tree into two caches:
   _columnsMeta      = columns with tasks stripped
   _tasksByColumn     = { columnId: [tasks] }
   emit(BoardLoaded(boardId, boardName, columns: merge(caches)))
        │
        ▼
_subscribeToColumns(boardId)   → opens the first realtime stream
        │
        ▼
BlocBuilder<BoardBloc, BoardState> rebuilds → column scroller renders
```

### b) Create Task Flow

```
User fills "Add Task" bottom sheet, taps Create
        │
        ▼
onSubmit callback → bloc.add(TaskCreated(columnId, title, description,
                                           priority, dueDate, assigneeId))
        │
        ▼
_onTaskCreated:
   1. snapshot _tasksByColumn (for rollback)
   2. build an optimistic TaskEntity with a temp id ("_temp_task_<ts>")
   3. append it to the column's task list, emit immediately
        │
        ▼
CreateTaskUseCase.call(...)
   — trims title, rejects empty title
   — trims/normalizes description (empty → null)
   — validates priority ∈ {low, medium, high, urgent}
        │
        ▼
BoardRepo.createTask → Datasource inserts the row, then (if assigneeId
   is set) re-fetches the row joined with `profiles` so the returned
   TaskEntity already has assigneeName/assigneeAvatarUrl populated
        │
        ▼
Result.success(realTask)
        │
        ▼
_onTaskCreated success branch: swap the temp-id entity for `realTask`
   in _tasksByColumn, emit merged state
        │
        ▼
UI shows the task — first optimistically (temp id), then again with
   the server's real id/timestamps a moment later (visually identical)
```

*(If the use case's validation fails — e.g. empty title reaches it somehow
— or the network call fails, the error branch restores the snapshot taken
in step 1 and the optimistic card disappears.)*

### c) Move Task Between Columns (Optimistic UI) Flow

```
User long-presses a card, drags it over another column, releases
        │
        ▼
DragTarget.onAcceptWithDetails computes the drop index from card
   RenderBox positions → BoardColumnWidget.onDropTask(data, index)
        │
        ▼
board_screen.dart → bloc.add(TaskMoved(taskId, fromColumnId,
                                         targetColumnId, newPosition))
        │
        ▼
_onTaskMoved:
   1. SAVE previous _tasksByColumn (full snapshot)
   2. Remove task from source list, insert into destination list at
      newPosition, reindex BOTH lists' `position` fields to 0..n-1
   3. UPDATE UI IMMEDIATELY — emit the merged, moved state
        │
        ▼
MoveTaskUseCase.call(taskId, targetColumnId, newPosition)
        │
        ├── SUCCESS ──▶ do nothing (UI is already correct);
        │               fire-and-forget ReorderTasksUseCase calls for
        │               both touched columns to persist sibling positions
        │
        └── FAILURE ──▶ _tasksByColumn = previous snapshot
                         emit(loaded.copyWith(columns: merge(previous)))
                         → the card visibly snaps back to where it was
```

### d) Real-time Update Flow

```
Another collaborator moves a task in the same board (their own
optimistic update round-trips through their Supabase write)
        │
        ▼
Postgres commits the UPDATE on `tasks`
        │
        ▼
Supabase Realtime broadcasts the change to every open
`tasks` stream filtered to this board's column ids
        │
        ▼
Our watchTasks() stream (a live Supabase query, not a diff — it
   re-emits the FULL current row set matching the filter) fires
        │
        ▼
_tasksSubscription.listen → add(RealtimeTasksUpdated(tasks))
        │
        ▼
_onRealtimeTasksUpdated:
   group the flat task list by columnId, sort each group by position,
   replace _tasksByColumn wholesale, emit merged state
        │
        ▼
UI updates — the other collaborator's move appears with no user
   interaction on this device
```

---

## 5. Optimistic UI Pattern — Deep Dive

### What it is, and why

Optimistic UI means: **update the screen as if the server call already
succeeded, before it actually has.** The alternative — spinner, wait,
then update — makes every drag, delete, and rename feel laggy, even on a
fast connection, because a full round trip (client → Postgres → client)
is still 100–300ms. For a direct-manipulation interaction like dragging a
card, that latency reads as "broken" rather than "loading."

### The exact pattern, used identically in every mutating handler

```dart
Future<void> _onSomeMutation(SomeEvent event, Emitter<BoardState> emit) async {
  if (_loaded == null) return;

  final previous = /* snapshot of the cache this mutation touches */;
  /* mutate the cache in place */
  _emitMerged(emit);                       // 1 + 2: save, then update UI now

  final result = await someUseCase(...);   // 3: call server in background

  result.when(
    success: (_) {},                       // 4: nothing to do, UI is correct
    error: (_) {
      /* restore from previous */          // 5: rollback
      _emitMerged(emit);
    },
  );
}
```

Concretely, from `_onColumnDeleted`:

```dart
final previousColumns = List<BoardColumnEntity>.from(_columnsMeta);
final previousTasks = Map<String, List<TaskEntity>>.from(_tasksByColumn);

_columnsMeta = _columnsMeta.where((c) => c.id != event.columnId).toList();
_tasksByColumn = Map.of(_tasksByColumn)..remove(event.columnId);
_emitMerged(emit);                          // column vanishes instantly

final result = await deleteColumnUseCase(columnId: event.columnId);

result.when(
  success: (_) {},
  error: (_) {
    _columnsMeta = previousColumns;         // column reappears
    _tasksByColumn = previousTasks;         // with its tasks, exactly as before
    _emitMerged(emit);
  },
);
```

### Why CREATE is optimistic *with a caveat*, not skipped

Every mutation in this Bloc is optimistic, including create — but create
is the one case where the optimistic entity is provably *fake* in one
respect: its `id` is a locally-generated placeholder
(`_temp_col_<timestamp>`, `_temp_task_<timestamp>`), because Postgres
hasn't assigned the real UUID yet. The UI can't wait for that id before
showing the card (that would defeat the purpose), so it shows the
temp-id version immediately, then **reconciles**: on success, the
temp-id entity is swapped in-place for the server's response (real id,
real `createdAt`, possibly server-normalized fields). This swap is
invisible to the user — same position in the list, same content — but it
matters internally, because every other action (tap to open detail, drag
to move) needs the *real* id to target the right Supabase row.

### Why DELETE and MOVE are (simple) optimistic

Delete and move don't have the id problem — they operate on an entity
that already has a real, server-assigned id. There's nothing to
reconcile on success, which is why their `success` branch is empty
(`success: (_) {}`): the optimistic state *is* the final state.

### What happens with no internet

The use case's `Future` never resolves with `Result.success` — it either
throws inside the datasource (caught, wrapped as
`ServerException` → `ServerFailure` → `Result.error`) or the underlying
Supabase call times out and surfaces the same way. Either way, the
`error` branch runs: the cache is restored to its pre-mutation snapshot,
`_emitMerged` re-runs, and the UI reverts. From the user's perspective:
they dragged a card, it moved, then — after the platform's default
network timeout — it silently slides back. There is currently **no
toast/snackbar** wired to that reversal (see §12 caveat below); the
revert itself is the only feedback.

### How rollback looks visually

Because the rollback re-emits a full `BoardLoaded` built from the
restored caches, Flutter's widget diffing (keyed by `task.id` in
`ReorderableListView`/`Column` children) animates the card back to its
original list position the same way it animated the optimistic move —
there's no special-cased "undo" animation, it's the same rebuild
machinery running in reverse.

---

## 6. Real-time Sync — Deep Dive

### How Supabase realtime works, mechanically

Under the hood, Supabase Realtime listens to Postgres's **logical
replication stream** (the same mechanism `LISTEN`/`NOTIFY` triggers, but
via `wal2json`/replication slots rather than a manual `NOTIFY` call) for
`INSERT`/`UPDATE`/`DELETE` on tables that have realtime enabled. Clients
subscribe over a WebSocket; `supabase_flutter`'s
`.stream(primaryKey: ['id'])` wraps that subscription and — critically —
**maintains a client-side materialized view** of the filtered result set:
every time a matching row changes, it re-emits the *entire current list*,
not a diff. That's why `watchColumns`/`watchTasks` are typed as
`Stream<List<...>>` rather than `Stream<SingleRowChange>`.

### Why only `board_columns` and `tasks` have it enabled

`boards` and `profiles` don't need live updates for this screen — the
board's own name/id essentially never changes mid-session, and profile
data (assignee name/avatar) is fetched once per query, not watched.
Enabling realtime has a cost (every write triggers a broadcast to every
subscriber), so it's scoped to exactly the two tables whose rows change
constantly during normal use.

### Two independent streams — and why they can't be one

```dart
Stream<List<BoardColumnEntity>> watchColumns({required String boardId});
Stream<List<TaskEntity>> watchTasks({required List<String> columnIds});
```

Supabase's realtime `.stream()` builder does **not support joins** — you
can filter by column value (`.eq()`, `.inFilter()`), but you can't ask it
to also embed a related table the way a normal `.select()` can. So a
`board_columns` row arrives with no `tasks` attached, and a `tasks` row
arrives with no `profiles` attached. This forces two consequences:

1. **Two separate subscriptions**, one per table.
2. **Client-side merging.** The Bloc is the thing that stitches "column
   metadata" and "column's tasks" back together, because Supabase won't
   do it for a realtime feed.

### When streams start / stop

- **Start**: only *after* the initial `getBoard()` REST fetch succeeds —
  `_subscribeToColumns` is called from inside the `success` branch of
  `_onBoardLoadRequested`, never before. This avoids a race where a
  realtime event could arrive and be merged against caches that don't
  exist yet.
- **Columns → Tasks chaining**: the tasks stream can't start until we
  know *which* column ids to filter on, so `_subscribeToTasks` is called
  from inside `_onRealtimeColumnsUpdated`, using the id list from the
  columns stream's own first emission (which fires immediately on
  subscribe, carrying the initial snapshot). If the set of column ids
  changes later (a column added/deleted), the same handler notices via
  `_sameIds()` and transparently cancels + re-subscribes the tasks
  stream to the new set.
- **Stop**: `BoardBloc.close()` cancels both `StreamSubscription`s. Every
  stream listener also checks `if (isClosed) return;` before calling
  `add()`, guarding against a stream event landing in the brief window
  between "user navigated away" and "subscription actually cancelled."

### How merging works, precisely

The Bloc never treats a `BoardLoaded.columns` list as its source of
truth — it treats two private fields as the source of truth, and
`columns` is *derived*:

```dart
List<BoardColumnEntity> _columnsMeta;               // no tasks attached
Map<String, List<TaskEntity>> _tasksByColumn;        // keyed by columnId

List<BoardColumnEntity> _mergedColumns() {
  return _columnsMeta
      .map((c) => c.copyWith(tasks: _tasksByColumn[c.id] ?? const []))
      .toList()
    ..sort((a, b) => a.position.compareTo(b.position));
}
```

Every write path — optimistic mutation *or* incoming realtime event —
updates one or both of these two fields, then calls `_emitMerged()`.
This is what makes "local optimistic change" and "remote realtime
change" compose correctly instead of racing: they're both just mutations
of the same two caches, applied in whatever order they actually occur
in, on the single-threaded event loop that `Bloc`'s event handlers run
on.

**Handling missing assignee data on the stream**: `TaskModel.fromJson`
reads `json['profiles'] as Map<String, dynamic>?` — a nullable cast. The
initial REST fetch's payload always has a `profiles` key (possibly
`null` if unassigned, but present); the realtime stream payload never
has the key at all (no joins). Both cases collapse to the same
`assignee == null` branch, so `assigneeName`/`assigneeAvatarUrl` end up
`null` either way — the model doesn't need to know or care which source
produced the row.

### Race condition: local move + concurrent realtime update

Say the user drags Task A optimistically (step 2 of §5's pattern
mutates `_tasksByColumn` and emits), and *before* the network confirms,
a realtime event for an unrelated change (someone else edited Task B)
arrives. `_onRealtimeTasksUpdated` runs, and its handler does:

```dart
_tasksByColumn = grouped;   // full replace, built from the stream's payload
```

This is a **last-write-wins on the whole map**, keyed by whatever
Postgres's replication stream currently reflects. Since the local
optimistic move for Task A hasn't been persisted to Postgres yet (it's
still in flight), the realtime snapshot doesn't include it — so this
*could* transiently overwrite the optimistic move, then the move's own
success handler is a no-op (nothing to reconcile), meaning **the
optimistic UI could flicker back to pre-move state until the move's
Postgres write lands and the next realtime tick reflects it.** In
practice this window is small (both operations typically resolve within
one round trip of each other), but it is a real, acknowledged race —
Bloc events are processed strictly in the order they're added
(`Bloc` uses a sequential `EventTransformer` by default), so there's no
data corruption, just a possible brief visual flicker. A stronger fix
would track "pending optimistic task ids" and skip clobbering them
during a realtime merge; that's not implemented here.

### Why streams skip `Result<T>`

`Result<T>` (`success`/`error`) models a single request/response — it's
built for `Future<Result<T>>`, not `Stream<T>`. A `Stream` already has
its own, native error channel (`onError` in `.listen()`), and Dart's
`Stream.map()` propagates upstream errors through automatically without
needing to be caught and re-wrapped. Wrapping every emission in a
`Result` would mean allocating a `Result.success(...)` for every single
row-set update — pure overhead for a channel that already has
first-class error handling. This is also why `BoardSupabaseDatasource`'s
`watchColumns`/`watchTasks` have **no `try`/`catch`** around them, unlike
every other method in that file — a thrown error inside `.map()`'s
callback (e.g. a malformed JSON row) becomes a stream error naturally.

---

## 7. Drag & Drop Architecture

### Two operations, one mental model

| | Within a column | Between columns |
|---|---|---|
| Trigger | `LongPressDraggable` + `DragTarget` | Same widgets, or the "Move to" bottom sheet |
| Bloc event | `TaskMoved` (`fromColumnId == targetColumnId`) | `TaskMoved` (different ids) |
| Handler | `_onTaskMoved`, `sameColumn` branch | `_onTaskMoved`, cross-column branch |

Both are literally **the same event and the same handler** — the Bloc
doesn't have a separate "reorder within column" concept at the event
level; `TaskMoved(taskId, fromColumnId, targetColumnId, newPosition)`
covers both, and the handler branches internally on
`fromColumnId == targetColumnId`. This was a deliberate simplification:
a cross-column move and a same-column reorder are the same operation
(remove from one ordered list, insert into an ordered list at an index)
with the degenerate case being "the two lists happen to be the same
list."

`board_column_widget.dart` implements the drag surface with
`LongPressDraggable<DragTaskData>` per card and a single `DragTarget`
wrapping the whole column body (not one target per possible drop slot).
The drop **index** is computed on release by walking the column's
currently-rendered cards, reading each one's `RenderBox` position via a
`GlobalKey`, and finding the first card whose vertical midpoint sits
below the drop point (`board_column_widget.dart`'s `_dropIndex`).

### How position integers move

Given column `[A(0), B(1), C(2)]` and dragging `A` to index 2 (past `C`):

```
remove A                →  [B(0-ish), C(1-ish)]   (not yet reindexed)
reindex 0..n-1           →  [B(0), C(1)]
insert A at clamp(2, 2)   →  [B(0), C(1), A(2)]     (before reindex)
reindex again 0..n-1      →  [B(0), C(1), A(2)]     (already correct here)
```

For a cross-column move, the **source** column's remaining tasks are
reindexed to close the gap, and the **destination** column's tasks are
reindexed around the inserted task — both lists always end up with dense
`0..n-1` positions, never gaps. This happens twice: once locally
(instantly, for the optimistic UI) and once server-side, via
`MoveTaskUseCase` (sets the moved task's own `column_id`/`position`) plus
two `ReorderTasksUseCase` calls (persist the corrected positions for
every *other* task in both affected columns).

### Why position math lives in the use case, not the Bloc

```dart
// ReorderTasksUseCase
Future<Result<void>> call({required String columnId, required List<TaskEntity> tasks}) {
  final reindexed = tasks
      .asMap()
      .entries
      .map((e) => e.value.copyWith(position: e.key))
      .toList();
  return repository.reorderTasks(columnId: columnId, tasks: reindexed);
}
```

This is business logic — "positions are dense, zero-based, and derived
from list order" is a rule about the *domain*, true regardless of
whether the caller is this Bloc, a future admin tool, or a test. Putting
it in the use case means the Bloc can pass it *any* ordered list (even
one that's already slightly out of sync) and trust the use case to
normalize it before it reaches Supabase — the Bloc doesn't have to
re-derive or double-check the invariant itself, and neither would any
other future caller.

---

## 8. State Management Decisions

### Sealed classes for events

```dart
sealed class BoardEvent extends Equatable { ... }
class ColumnCreated extends BoardEvent { ... }
class TaskMoved extends BoardEvent { ... }
// ...
```

`sealed` (Dart 3) means the compiler knows the *complete* set of
subtypes at compile time. Combined with a `switch` (not used directly in
this Bloc, since `on<T>()` registration is exhaustive by construction —
every event type has exactly one registered handler), the payoff is that
adding a 13th event type and forgetting to register its handler is a
silent bug `on<T>()` won't catch, but is very hard to *smuggle past
review*, because `sealed` forces every consumer that *does* pattern-match
on `BoardEvent` (tests, logging middleware, future refactors) to handle
it or get a compile error.

### Sealed classes for states

```dart
sealed class BoardState extends Equatable { ... }
class BoardInitial extends BoardState {}
class BoardLoading extends BoardState {}
class BoardLoaded extends BoardState { ... }
class BoardError extends BoardState { ... }
```

This is the bigger payoff of `sealed`: in `board_screen.dart`'s
`BlocBuilder`, the moment you write `if (state is BoardError) { ... }`
and then `if (state is! BoardLoaded) { ...spinner... }`, the compiler
*knows* those two branches plus the fall-through cover every possible
state — there's no `BoardSomethingElse` that could sneak in
unhandled, because nothing outside this file is allowed to extend
`BoardState` at all.

### Why `BoardLoaded` holds the full tree, not separate lists

An earlier-considered shape was `BoardLoaded(columns: [...], tasksByColumnId: {...})`
— i.e., expose the same two-cache split the Bloc uses internally. That
was rejected because it pushes the merge logic (§6) out into every
widget that reads the state, multiple times, instead of once inside the
Bloc. `BoardColumnEntity.tasks` being populated means `board_column_widget.dart`
can be a dumb, stateless renderer of "here is a column, fully formed" —
it never needs to know that columns and tasks arrived from two different
sources.

### The guard pattern: `if (state is! BoardLoaded) return;`

Every mutating handler starts with this (via the `_loaded` getter). It's
not defensive-programming padding — it's a real business rule: **you
cannot create/move/delete anything until the board has successfully
loaded once.** If a `TaskMoved` event somehow fires while the Bloc is
still in `BoardLoading` (a stale gesture from before a screen transition,
a double-tap race), silently no-op-ing is correct: there is no `_loaded`
board state to mutate, and doing nothing is strictly safer than crashing
on a null `_columnsMeta` lookup.

### How `Equatable` prevents unnecessary rebuilds

`BlocBuilder` (like `BlocConsumer`, `BlocListener`) only rebuilds when
the *new* state is `!=` the *previous* state, by `==` (or, for
`Equatable` classes, member-wise value equality). If a stream re-emits
the exact same task list (Supabase's client-side materialized view can
re-broadcast on reconnect, for instance), the resulting `BoardLoaded` has
identical `columns`, so `==` is `true`, no rebuild happens — pure
efficiency, not correctness, but it means the Bloc doesn't need any
manual "did anything actually change?" diffing of its own.

### `BoardError` vs. keeping the loaded state

`BoardError` is only ever emitted from `_onBoardLoadRequested`'s failure
branch — i.e. **the initial fetch itself failed** (no board to show at
all). Every other handler's failure path deliberately does **not**
emit `BoardError`; it reverts `_columnsMeta`/`_tasksByColumn` and
re-emits `BoardLoaded`. This is a considered asymmetry: `BoardError` in
this design means "there is nothing to render," and a failed *mutation*
on an already-loaded board is never that — the board is still there, still
correct, just missing the one change that didn't stick. Blowing away the
whole screen to a full-page error for a failed rename would be a much
worse experience than a card quietly sliding back.

---

## 9. Entity Design

### Immutability: `final` fields + `copyWith`

```dart
class TaskEntity extends Equatable {
  final String id;
  final String title;
  // ... all final
  const TaskEntity({ required this.id, ... });
  TaskEntity copyWith({ String? id, ... }) => TaskEntity(id: id ?? this.id, ...);
}
```

Every entity is a `const`-constructible value object — there is no
setter anywhere. This matters specifically *because* of the optimistic
UI pattern in §5: "snapshot, mutate, maybe rollback" only works cleanly
if "mutate" always means "produce a new object," never "change the old
one in place." If `TaskEntity.position` were a mutable field, the
`previous` snapshot taken before a reorder would be the *same object* as
the one being reordered — rollback would restore nothing, because
there'd be nothing left to restore *to*.

The `copyWith` methods intentionally use the simple `field ?? this.field`
pattern (no sentinel-value trick for "explicitly set to null"). That's a
real, accepted limitation — you can't use `copyWith` to *clear* a
nullable field like `dueDate` — but nothing in this codebase currently
needs to; every actual `copyWith` call sets a non-null replacement value
(a new `position`, a new `title`, a new `tasks` list). Adding sentinel
support before it's needed would be exactly the kind of premature
abstraction worth avoiding.

### `Equatable`

Two independently-constructed `TaskEntity`s with identical field values
compare `==`. This is what makes the `Equatable`-rebuild-skipping in §8
work, and it's also what makes `_columnsMeta`/`_tasksByColumn` diffing
implicit rather than something the Bloc has to hand-write — list/map
`==` on entities "just works" for the merge logic's assumptions.

### Computed getters live on the entity, not scattered in widgets

```dart
bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now());
bool get isAssigned => assigneeId != null;
bool get isUrgent => priority == 'urgent';
bool get isHigh => priority == 'high';
```

`task_card_widget.dart` and `task_detail_bottom_sheet.dart` both need
"is this task overdue" logic — putting it on the entity means both
widgets ask the same question the same way, instead of one of them
drifting (e.g. one comparing `DateTime.now()` at build time, another
using a cached "now" from initState). It's a single, testable source of
truth for a domain concept ("overdue"), not a UI concept.

### Why `Entity` and `Model` are separate classes

`BoardColumnEntity`/`TaskEntity` (domain) know nothing about JSON,
Supabase's `snake_case` column names, or nested-select response shapes.
`BoardColumnModel`/`TaskModel` (data) know all of that, and nothing else
— they don't have `isOverdue`, because a data model has no business
computing domain rules. The seam between them is one method:

```dart
class TaskModel {
  factory TaskModel.fromJson(Map<String, dynamic> json) { ... }
  TaskEntity toEntity() => TaskEntity(id: id, columnId: columnId, ...);
}
```

This means a schema change (say, Supabase renames `due_date` to
`due_at`) is a one-line fix in `TaskModel.fromJson`, and every use case,
every Bloc handler, every widget — all of which only ever see
`TaskEntity` — needs zero changes.

### `Model.fromJson` and nested joins

```dart
factory TaskModel.fromJson(Map<String, dynamic> json) {
  final assignee = json['profiles'] as Map<String, dynamic>?;
  return TaskModel(
    id: json['id'] as String,
    // ...
    assigneeName: assignee?['full_name'] as String?,
    assigneeAvatarUrl: assignee?['avatar_url'] as String?,
    // ...
  );
}
```

`BoardModel.fromJson` reads `json['board_columns']`, recursively calling
`BoardColumnModel.fromJson` on each; `BoardColumnModel.fromJson` reads
`json['tasks']`, recursively calling `TaskModel.fromJson`. This mirrors
exactly the nested `select()` string used in the query
(`'*, board_columns(*, tasks(*, profiles(...)))'`) — Supabase returns
related rows as nested arrays/objects keyed by table name, and the
`fromJson` chain is a direct, one-to-one unwrapping of that shape. Every
level also defensively defaults a missing/`null` nested key to `[]`
(`json['tasks'] as List<dynamic>? ?? []`) and sorts by `position` right
there in the constructor, so nothing downstream has to re-sort.

---

## 10. Use Case Business Logic

### Why business logic lives in use cases, not the Bloc

The Bloc's job is **orchestration**: apply an optimistic change, call the
right thing, revert on failure, merge realtime data. It should not also
be the place that decides "is this a valid task title." Two reasons:

1. **Reuse.** If a future feature (bulk CSV import, an admin panel,
   another Bloc) needs to create a task, it should get the *same*
   validation for free by calling `CreateTaskUseCase`, not by
   re-implementing "trim, check empty, check priority enum" a second
   time next to a different Bloc.
2. **Testability.** `CreateTaskUseCase` is a pure function of its
   inputs and a mocked `BoardRepo` — testing "empty title is rejected"
   doesn't require spinning up a `Bloc`, registering handlers, or
   awaiting `emit()` calls.

### Concrete business logic in this feature

```dart
// CreateColumnUseCase / RenameColumnUseCase
final trimmedName = name.trim();
if (trimmedName.isEmpty) {
  return Result.error(const ServerFailure('Column name cannot be empty'));
}

// CreateTaskUseCase / UpdateTaskUseCase
final trimmedTitle = title.trim();
if (trimmedTitle.isEmpty) { ... }
final normalizedDescription =
    (trimmedDescription == null || trimmedDescription.isEmpty) ? null : trimmedDescription;
if (!_validPriorities.contains(priority)) {
  return Result.error(const ServerFailure('Invalid priority value'));
}

// ReorderColumnsUseCase / ReorderTasksUseCase
final reindexed = items.asMap().entries
    .map((e) => e.value.copyWith(position: e.key))
    .toList();
```

Trimming whitespace, collapsing an empty-after-trim description to
`null` (so the database stores `NULL`, not `""`), rejecting an
out-of-enum priority string, and recalculating positions from list
order — none of these are Supabase concerns (the datasource just
inserts/updates whatever map it's given) and none are UI concerns (the
Bloc just orchestrates) — they're the actual rules of the domain, so
they live in the layer whose entire purpose is "rules of the domain."

### One class, one `call()` method

```dart
class CreateColumnUseCase {
  final BoardRepo repository;
  const CreateColumnUseCase(this.repository);
  Future<Result<BoardColumnEntity>> call({ ... }) async { ... }
}
```

Making the class callable (`call()`) means call sites read like a
function invocation — `await createColumnUseCase(boardId: ..., name: ...)`
— rather than `await createColumnUseCase.execute(...)`. Combined with
"one class per operation" (rather than one `BoardUseCases` god-class with
twelve methods), each use case is independently constructible,
independently mockable, and its single responsibility is legible from
its file name alone.

---

## 11. Error Handling Chain

```
Supabase / Postgres error
   (network failure, constraint violation, RLS denial)
        │ throws
        ▼
PostgrestException
   (supabase_flutter's own typed exception)
        │ caught in the datasource: `on Exception catch (e)`
        ▼
ServerException
   (lib/core/errors/exceptions.dart — data-layer vocabulary, thrown)
        │ caught in BoardRepositoryImpl: `on ServerException catch (e)`
        ▼
ServerFailure
   (lib/core/errors/failures.dart — domain-layer vocabulary, wrapped)
        │ returned inside Result.error(failure)
        ▼
Result<T>
   ( .when(success: ..., error: ...) )
        │
        ▼
BoardBloc's error branch
   rollback the optimistic snapshot, re-emit BoardLoaded
   (or emit BoardError, for the initial load only)
        │
        ▼
UI
   card snaps back silently (see §5/§11 caveat), or
   full-screen error + Retry button (initial load only)
```

### Why exceptions in the data layer, failures in the domain layer

`throw`/`catch` is idiomatic for *unexpected, exceptional* control flow
close to the actual I/O — `ServerException` is thrown right where a
`PostgrestException` was thrown, one layer up. By the time execution
reaches the repository, though, "a network call failed" is an
**expected, first-class outcome** the domain layer's callers need to
branch on every single time — that's what `Failure`/`Result<T>` are for:
values, not control flow. Converting exception → failure at the
repository boundary is the one place in the codebase where the
"exceptions vs. values" style switches, deliberately, at the layer
seam.

### Why `Result<T>` instead of `Either` or bare `try`/`catch`

`Either<L, R>` (from `dartz` or similar) is the same idea, generic over
"left"/"right" rather than named "failure"/"success" — this codebase's
`Result<T>` is a small, dependency-free, purpose-built version of the
same pattern, with a `.when(success:, error:)` API that reads clearly at
every call site and doesn't require pulling in a functional-programming
library for one type. Bare `try`/`catch` at every call site was rejected
because it would mean every use case, every Bloc handler, re-implements
its own ad hoc "what does failure look like here" — `Result<T>` makes
failure a **type-checked, impossible-to-forget** part of every
repository method's signature; you cannot call `getBoard()` and
accidentally ignore that it might fail, the way you can silently skip a
`catch`.

### How stream errors differ

As covered in §6: streams have no `Result<T>` wrapper at all. An error
inside `watchColumns`/`watchTasks` propagates as a native `Stream` error.
Currently, `BoardBloc`'s `.listen((data) { ... })` calls don't attach an
`onError` callback — an unhandled stream error would surface as an
uncaught exception in the zone, not as a `BoardError` state. This is a
gap worth closing (attaching `onError: (e) => ...` to both subscriptions)
if realtime reliability becomes a priority; it's flagged here rather than
silently left implicit.

### How the UI distinguishes error types today

It doesn't finely — `board_screen.dart` only branches on
`state is BoardError` (full-page, with Retry) versus everything else.
There's no per-mutation error surface (toast/snackbar) yet; see the
optimistic-UI caveat in §5 and the DI/UX note in §12.

---

## 12. Dependency Injection

### How GetIt wires it together

`lib/core/di/di_container.dart`'s `_initBoard()` registers, in order:

```dart
// Datasource
sl.registerLazySingleton<BoardRemoteDatasource>(() => BoardSupabaseDatasource(sl()));

// Repository
sl.registerLazySingleton<BoardRepo>(() => BoardRepositoryImpl(sl()));

// Use Cases (10 of them)
sl.registerLazySingleton(() => GetBoardUseCase(sl()));
sl.registerLazySingleton(() => CreateColumnUseCase(sl()));
// ...

// Bloc
sl.registerFactoryParam<BoardBloc, String, void>(
  (boardId, _) => BoardBloc(boardId: boardId, boardRepo: sl(), getBoardUseCase: sl(), ...),
);
```

### Why `registerLazySingleton` for datasource/repo/use cases

None of these classes hold per-screen state — `BoardSupabaseDatasource`
just wraps a shared `SupabaseServices` client, `BoardRepositoryImpl` just
wraps the datasource, and every use case just wraps the repository.
There is exactly one correct instance of each for the whole app's
lifetime, created lazily (only if/when the board feature is first used)
and then reused for every subsequent call — a `Singleton`, not a
`Factory`, because creating a fresh `CreateTaskUseCase` object per call
would be pure allocation churn for zero benefit (it has no mutable
state to reset).

### Why `registerFactoryParam` for `BoardBloc`

`BoardBloc` is the opposite: it **does** hold per-screen state
(`_columnsMeta`, `_tasksByColumn`, two live `StreamSubscription`s) and
it's constructed with a `boardId` that's only known at navigation time,
not at app-startup DI-wiring time. `registerFactoryParam<BoardBloc, String, void>`
is GetIt's mechanism for "build me a *new* instance every time, and let
me pass one runtime parameter into the constructor" —
`sl<BoardBloc>(param1: boardId)`, called from `router.dart`'s `GoRoute`
builder, produces a fresh Bloc (fresh caches, fresh subscriptions) every
time the user navigates to a *different* board, and disposing the
`BlocProvider` (navigating away) triggers `BoardBloc.close()`, tearing
down that instance's stream subscriptions.

### How `sl()` resolves dependencies by type

`sl()` (no type argument) works because Dart infers the expected type
from the constructor parameter it's being passed into — writing
`BoardRepositoryImpl(sl())` inside a `BoardRepositoryImpl(BoardRemoteDatasource datasource)`
constructor call means the compiler already knows `sl()` must return
`BoardRemoteDatasource`, and `get_it` resolves that request against
whatever was last registered under that exact type. This is why
registration order (datasource → repo → use cases → Bloc) matters for
*readability and lazy-init correctness*, though not strictly for
runtime correctness with lazy singletons — a `LazySingleton` isn't
actually constructed until first requested, so `BoardRepositoryImpl`
being registered before `BoardSupabaseDatasource` would still resolve
correctly the first time something asks for `BoardRepo`, as long as both
registrations have happened by then. The `_initBoard()` function running
at app-startup, all at once, guarantees that.

---

## 13. Supabase Queries

### The `getBoard` nested select

```dart
await services.client
    .from(SupabaseTables.boards)
    .select('*, board_columns(*, tasks(*, profiles(full_name, email, avatar_url)))')
    .eq('id', boardId)
    .single();
```

PostgREST (Supabase's REST layer) resolves `table_a(*, table_b(*))`
nested-select syntax via the foreign-key relationships already defined
in the schema — `board_columns.board_id → boards.id`,
`tasks.column_id → board_columns.id`, `tasks.assignee_id → profiles.id`
— and returns one JSON document with `board_columns` embedded as an
array of objects, each of which embeds its own `tasks` array, each of
which embeds its own `profiles` object (or `null`, for an unassigned
task). One HTTP round trip fetches the entire board tree; this is the
query `BoardModel.fromJson`'s recursive parsing (§9) exists to consume.

### RLS and workspace membership

This repo's Flutter code never queries `boards`/`board_columns`/`tasks`
with an explicit `workspace_id`/`user_id` filter for authorization
purposes — `getBoard(boardId: ...)` just asks for the board by id, with
no visible access check. That's the point of **Row Level Security**:
the authorization decision ("is the currently-authenticated user allowed
to see this row at all") is enforced by Postgres itself, as a `WHERE`
clause the database silently ANDs onto every query, not by
application code that could be bypassed or forgotten. Concretely for
this app's shape, that means a policy on `boards` (and, transitively via
each table's own policy, `board_columns`/`tasks`) restricting visible
rows to boards whose `workspace_id` is one the requesting user belongs
to — mirroring the membership check already visible in the *workspace*
feature's own query
(`workspace_supabase_data_source.dart`'s `getWorkspaces()` joins through
`workspace_members` filtered by `user_id = auth.uid()`).

**Caveat, stated plainly**: the actual RLS policy SQL and any
security-definer helper function (a `get_user_workspace_ids(uid)`-style
function is a common, idiomatic way to let a policy check "is this
board's workspace one of the ones I belong to" without a slow
correlated subquery per row) live in the Supabase project's own
database — they are **not** version-controlled inside this Flutter
repository (there's no `supabase/migrations` directory checked in), so
this section describes the *expected/conventional* shape based on how
the client code queries and on the sibling workspace feature's pattern,
not a policy definition this document can point to a specific file for.
Anyone picking this up should verify the live policies against the
Supabase dashboard directly rather than trusting this paragraph as a
schema source of truth.
