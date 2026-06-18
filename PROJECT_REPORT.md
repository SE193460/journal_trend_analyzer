# 📊 Journal Trend Analyzer — Project Report

**Course:** PRM  
**Semester:** 8 — FPT University  
**Checkpoint:** CP2  
**Date:** June 18, 2026  

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [System Design](#2-system-design)
3. [Implementation Details](#3-implementation-details)
4. [API Integration Approach](#4-api-integration-approach)
5. [Screenshots of Major Features](#5-screenshots-of-major-features)
6. [Trend Analysis Results](#6-trend-analysis-results)
7. [AI-Assisted Code Review Findings](#7-ai-assisted-code-review-findings)
8. [Challenges Encountered](#8-challenges-encountered)
9. [Lessons Learned](#9-lessons-learned)

---

## 1. Project Overview

### 1.1 Introduction

**Journal Trend Analyzer** is a cross-platform mobile application built with **Flutter** that enables users to explore, search, and analyze academic research publication trends. The app integrates with the **OpenAlex API** — a free, open-source catalog of the global research system — to provide real-time insights into scholarly works, authors, journals, and citation metrics.

### 1.2 Objectives

- Allow users to **search** academic publications by keyword/topic.
- Visualize **publication trends** over time using interactive line charts.
- Rank and display **top influential papers** by citation count.
- Identify **top authors** and **top journals** for a given research topic.
- Provide a **research dashboard** with key performance indicators (KPIs) such as total publications, average citations, most active year, top journal, and top author.
- Enable users to view **detailed metadata** for each publication (authors, institutions, DOI, FWCI, topic taxonomy, funders, awards, abstract, etc.).

### 1.3 Target Users

- Undergraduate and graduate students conducting literature reviews
- Researchers exploring new domains or tracking research trends
- Academic advisors looking for publication insights

### 1.4 Technology Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) — SDK ^3.11.5 |
| **State Management** | Provider (^6.1.5) |
| **HTTP Client** | Dio (^5.8.0) |
| **Charting** | fl_chart (^1.0.0) |
| **Image Caching** | cached_network_image (^3.4.1) |
| **URL Launching** | url_launcher (^6.3.0) |
| **API** | OpenAlex REST API (https://api.openalex.org) |
| **Target Platforms** | Android, iOS, Web, macOS, Linux, Windows |

---

## 2. System Design

### 2.1 Architecture Pattern

The application follows a **clean layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│                  UI Layer                    │
│  (Screens & Widgets)                        │
│  search_screen, trend_screen, dashboard_    │
│  screen, detail_screen, top_paper_screen,   │
│  top_journal_screen, top_author_screen      │
├─────────────────────────────────────────────┤
│              State Management               │
│  (Provider — PublicationProvider)            │
│  Manages loading states, error handling,    │
│  and data caching for all screens           │
├─────────────────────────────────────────────┤
│              Service Layer                  │
│  (OpenAlexService)                          │
│  Handles all API calls to OpenAlex          │
├─────────────────────────────────────────────┤
│              Data Models                    │
│  Publication, PublicationTrendPoint,         │
│  ResearchDashboardSummary                   │
└─────────────────────────────────────────────┘
```

### 2.2 Project Structure

```
lib/
├── main.dart                          # App entry point & Provider setup
├── models/
│   ├── publication.dart               # Publication & PublicationTrendPoint models
│   ├── author.dart                    # Author model
│   └── dashboard_summary.dart         # ResearchDashboardSummary model
├── providers/
│   └── publication_provider.dart      # ChangeNotifier for state management
├── services/
│   └── openalex_service.dart          # OpenAlex API integration layer
├── screens/
│   ├── search_screen.dart             # Home screen with search & navigation
│   ├── trend_screen.dart              # Publication trend analysis with charts
│   ├── dashboard_screen.dart          # Research dashboard with KPIs
│   ├── detail_screen.dart             # Detailed publication view
│   ├── top_paper_screen.dart          # Top influential papers ranking
│   ├── top_journal_screen.dart        # Top journals by publication count
│   └── top_author_screen.dart         # Top authors by publication count
└── widgets/
    ├── publication_card.dart          # Reusable publication list card
    └── chart_widget.dart              # Reusable chart component
```

### 2.3 Navigation Flow

```
                    ┌──────────────────┐
                    │   SearchScreen   │ ← Entry Point
                    │  (Bottom Nav)    │
                    └──────┬───────────┘
                           │
        ┌──────────────────┼─────────────────────┐
        │                  │                     │
   ┌────▼─────┐    ┌──────▼──────┐    ┌─────────▼──────────┐
   │  Trend   │    │  Top Papers │    │    Dashboard       │
   │  Screen  │    │   Screen    │    │     Screen         │
   └──────────┘    └──────┬──────┘    └────────┬───────────┘
                          │                    │
                   ┌──────▼──────┐      ┌──────▼──────┐
                   │   Detail    │      │   Detail    │
                   │   Screen    │      │   Screen    │
                   └─────────────┘      └─────────────┘

   Drawer Menu → Top Journals Screen
               → Top Authors Screen
```

The app uses a **BottomNavigationBar** (4 tabs: Search, Trends, Papers, Dashboard) as the primary navigation and a **Drawer** for secondary features (Top Journals, Top Authors).

---

## 3. Implementation Details

### 3.1 State Management — Provider Pattern

The app uses a single `PublicationProvider` (extends `ChangeNotifier`) to manage all application state:

```dart
class PublicationProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  List<Publication> publications = [];
  List<PublicationTrendPoint> trendData = [];
  List<Publication> topPapers = [];
  List<Map<String, dynamic>> topAuthors = [];
  ResearchDashboardSummary? dashboardSummary;
  
  bool isLoading = false;
  String errorMessage = "";
  String currentTopic = "";

  Future<void> search(String keyword) async {
    // Parallel API calls with Future.wait for performance
    var futures = await Future.wait([
      _service.searchPublication(keyword),
      _service.fetchPublicationTrend(keyword),
      _service.fetchTopInfluentialPapers(keyword),
      _service.fetchTopAuthors(keyword),
      _service.fetchResearchDashboardSummary(keyword),
    ]);
    // ... assign results and notifyListeners()
  }
}
```

**Key design decisions:**
- **`Future.wait`** is used to execute all API calls **in parallel**, significantly reducing load time.
- A single search action populates data for **all screens** simultaneously.
- Error and loading states are centrally managed.

### 3.2 Data Models

#### Publication Model (`publication.dart`)

The `Publication` model is the core data structure with **25 fields** capturing extensive metadata from the OpenAlex API:

| Field | Type | Description |
|---|---|---|
| `title` | `String` | Title of the work |
| `year` | `int` | Publication year |
| `citationCount` | `int` | Number of citations received |
| `doi` | `String` | Digital Object Identifier |
| `journal` | `String` | Source journal name |
| `authors` | `List<String>` | List of author names |
| `abstractText` | `String` | Reconstructed abstract text |
| `type` | `String` | Work type (article, review, etc.) |
| `institutions` | `List<String>` | Affiliated institutions |
| `language` | `String` | Language of the work |
| `fwci` | `double` | Field-Weighted Citation Impact |
| `cites` | `int` | Number of references cited |
| `relatedTo` | `int` | Number of related works |
| `topic` | `String` | Primary topic |
| `subfield` | `String` | Research subfield |
| `field` | `String` | Research field |
| `domain` | `String` | Research domain |
| `sdg` | `String` | UN Sustainable Development Goal |
| `openAccessStatus` | `String` | Open access status |
| `funders` | `List<String>` | Funding organizations |
| `awards` | `List<String>` | Award/Grant IDs |

**Abstract Reconstruction:** The OpenAlex API returns abstracts in an inverted index format. The `fromJson` factory method reconstructs the readable abstract:

```dart
if (json['abstract_inverted_index'] != null) {
  Map<String, dynamic> indexMap = json['abstract_inverted_index'];
  Map<int, String> wordsMap = {};
  indexMap.forEach((word, positions) {
    for (var pos in positions) {
      wordsMap[pos] = word;
    }
  });
  var sortedKeys = wordsMap.keys.toList()..sort();
  reconstructedAbstract = sortedKeys.map((k) => wordsMap[k]).join(" ");
}
```

#### PublicationTrendPoint Model

```dart
class PublicationTrendPoint {
  final int year;
  final int count;
}
```

#### ResearchDashboardSummary Model

```dart
class ResearchDashboardSummary {
  final int totalPublications;
  final double averageCitationCount;
  final int? mostActiveYear;
  final String? topJournal;
  final String? topAuthor;
  final Publication? mostInfluentialPaper;
  final List<PublicationTrendPoint> publicationTrend;
}
```

### 3.3 Key UI Components

#### Search Screen
- **Header** with deep purple gradient and rounded bottom corners
- **Search bar** with prefix/suffix icons and keyboard submit support
- **Quick topic chips** for one-tap search (AI, Data Science, Cybersecurity, Blockchain, IoT)
- **Feature shortcut grid** in empty state for quick navigation
- **Bottom navigation bar** with 4 tabs
- **Drawer menu** for secondary features

#### Trend Screen
- **Interactive year range slider** (`RangeSlider`) for filtering data
- **Summary cards** showing Total Papers, Peak Year, and Year Range
- **Interactive line chart** (`fl_chart` `LineChart`) with curved lines, gradient fill area, and touch tooltips
- **Insight section** with auto-generated text analysis of publication trends

#### Dashboard Screen
- **KPI grid** with 5 cards: Total Papers, Avg Citations, Most Active Year, Top Author, Top Journal
- **Mini trend chart** for quick visual overview
- **Most Influential Paper card** with citation count, year badge, and action buttons (View Details, View Paper via DOI)
- **Skeleton loading** with shimmer-style placeholder cards

#### Detail Screen
- Comprehensive publication metadata displayed in sections separated by dividers
- **Expandable lists** for Authors, Institutions, Funders, and Awards (show first 5, then "+N more")
- **DOI link** with external browser launch
- Topic taxonomy hierarchy: Topic → Subfield → Field → Domain

#### Top Papers Screen
- **Ranked list** with gold/silver/bronze badge system for top 3
- Citation count and journal info per paper
- Tap to navigate to Detail Screen

#### Top Journals Screen / Top Authors Screen
- Aggregated data from search results
- Sorted by publication count

---

## 4. API Integration Approach

### 4.1 API Overview — OpenAlex

[OpenAlex](https://openalex.org/) is a free and open index of the world's research system. Key characteristics:

- **No API key required** — public access
- **RESTful** endpoints at `https://api.openalex.org/`
- Returns **JSON** responses with rich metadata
- Supports **search, filtering, sorting, and grouping**

### 4.2 HTTP Client Configuration

```dart
final Dio dio = Dio(
  BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ),
);
```

**Dio** is used as the HTTP client with a 10-second timeout for both connection and response to prevent hanging on slow networks.

### 4.3 API Endpoints Used

| # | Endpoint | Purpose | Parameters |
|---|---|---|---|
| 1 | `GET /works?search={keyword}&per-page=200` | Search publications by keyword | `search`, `per-page` |
| 2 | `GET /works?search={keyword}&group_by=publication_year` | Get publication count per year | `search`, `group_by` |
| 3 | `GET /works?search={keyword}&sort=cited_by_count:desc&per-page=20` | Get top 20 most cited papers | `search`, `sort`, `per-page` |
| 4 | `GET /works?search={keyword}&group_by=author.id` | Get top authors by publication count | `search`, `group_by` |
| 5 | `GET /works?search={keyword}&per-page=1` | Get total publication count from meta | `search`, `per-page` |
| 6 | `GET /works?search={keyword}&group_by=primary_location.source.id` | Get top journal | `search`, `group_by` |
| 7 | `GET /works?search={keyword}&group_by=authorships.author.id` | Get top author for dashboard | `search`, `group_by` |
| 8 | `GET /works?search={keyword}&sort=cited_by_count:desc&per-page=1` | Get most influential paper | `search`, `sort`, `per-page` |
| 9 | `GET /works?search={keyword}&sort=cited_by_count:desc&per-page=200` | Calculate average citation count | `search`, `sort`, `per-page` |

### 4.4 Dashboard Summary — Parallel Aggregation

The `fetchResearchDashboardSummary` method demonstrates an efficient parallel API pattern:

```dart
Future<ResearchDashboardSummary> fetchResearchDashboardSummary(String keyword) async {
  var futures = await Future.wait([
    fetchTotalPublicationCount(keyword),      // 0
    fetchPublicationTrend(keyword),           // 1
    fetchTopJournal(keyword),                 // 2
    fetchDashboardTopAuthor(keyword),         // 3
    fetchMostInfluentialPaper(keyword),       // 4
    fetchAverageCitationCount(keyword),       // 5
  ]);
  // Construct and return ResearchDashboardSummary from results
}
```

Six API calls are executed **simultaneously** using `Future.wait`, reducing total load time from the sum of all calls to the duration of the **slowest** call.

### 4.5 Author Name Filtering

The service includes a shared validation method to filter out invalid or bot-generated author names:

```dart
static bool _isValidAuthorName(String name) {
  // Filters out: "Unknown", "N/A", "Anonymous"
  // Filters out: AI-related names (ChatGPT, Gemini, Claude, etc.)
  // Filters out: URLs and certification exam entries
  // Filters out: names starting with "http"
}
```

This ensures data quality in the Top Authors and Dashboard screens.

---

## 5. Screenshots of Major Features

> **Note:** Screenshots should be captured from the running application and inserted here.

### 5.1 Search Screen
```
┌─────────────────────────────┐
│ ☰  Journal Trend Analyzer   │ ← Deep purple header
│    Explore research trends   │
│ ┌─────────────────────────┐ │
│ │ 🔍 Search research topic│ │ ← Search bar
│ └─────────────────────────┘ │
│ [AI] [Data Science] [Cyber] │ ← Quick topic chips
├─────────────────────────────┤
│                             │
│    📚 Enter a topic         │ ← Empty state
│       to begin              │
│                             │
│  ┌──────┐ ┌──────┐         │
│  │Trend │ │Papers│         │ ← Feature shortcuts
│  ├──────┤ ├──────┤         │
│  │Journl│ │Author│         │
│  └──────┘ └──────┘         │
├─────────────────────────────┤
│ 🔍    📈    📄    📊       │ ← Bottom navigation
└─────────────────────────────┘
```

### 5.2 Trend Analysis Screen
```
┌─────────────────────────────┐
│      Publication Trend       │
│ Research trend for: AI       │
│                             │
│ Filter by Year: 2000-2024   │
│ ═══●═══════════●═══        │ ← Range slider
│                             │
│ ┌──────┬──────┬──────┐     │
│ │15,432│ 2023 │00-24 │     │ ← Summary cards
│ │Total │ Peak │Range │     │
│ └──────┴──────┴──────┘     │
│                             │
│ Papers by Publication Year   │
│     📈 ___/‾‾‾\            │ ← Interactive chart
│   __/          \            │
│  /              ‾           │
│ 2000   2010   2020   2024   │
│                             │
│ 💡 Publication activity     │ ← Auto-generated
│    peaked in 2023...        │    insight
└─────────────────────────────┘
```

### 5.3 Research Dashboard
```
┌─────────────────────────────┐
│     Research Dashboard       │
│  Key insights for: AI        │
│                             │
│ ┌───────────┬───────────┐  │
│ │📄 128.5K  │⭐ 45.2    │  │ ← KPI cards
│ │Total Paper│Avg Cite*  │  │
│ ├───────────┼───────────┤  │
│ │📅 2023    │👤 J.Smith │  │
│ │Active Year│Top Author │  │
│ └───────────┴───────────┘  │
│ ┌─────────────────────────┐│
│ │📚 Nature               ││ ← Wide KPI card
│ │   Top Journal           ││
│ └─────────────────────────┘│
│                             │
│ Publication Trend (mini)    │
│ 📈 ___/‾‾\_               │
│                             │
│ 🏆 Most Influential Paper  │
│ "Attention Is All You Need" │
│ [🔍 View] [🔗 Open Paper]  │
└─────────────────────────────┘
```

### 5.4 Publication Detail Screen
```
┌─────────────────────────────┐
│ ←  Work          🔌  ⋮     │
│                             │
│ Attention Is All You Need   │ ← Title (large, bold)
│                             │
│ [🔒 HTML ↗]               │ ← DOI link button
│─────────────────────────────│
│ Year: 2017                  │
│ Type: article               │
│ Source: NeurIPS              │
│ Authors: A. Vaswani, +7more │ ← Expandable
│ Institutions: Google, +3    │ ← Expandable
│ Language: en                 │
│─────────────────────────────│
│ FWCI: 12.3                  │
│ Cites: 45                   │
│ Cited by: 98,432            │
│ DOI: https://doi.org/...    │
│─────────────────────────────│
│ Topic: Transformers          │
│ Subfield: NLP               │
│ Field: Computer Science      │
│ Domain: Physical Sciences    │
│ SDG: N/A                    │
│─────────────────────────────│
│ Open Access status: gold     │
│─────────────────────────────│
│ Funders: Google Research     │
│ Awards: N/A                 │
│─────────────────────────────│
│ Abstract                     │
│ The dominant sequence...     │
└─────────────────────────────┘
```

### 5.5 Top Papers Screen
```
┌─────────────────────────────┐
│        Top Papers            │
│                             │
│ Top Influential Papers       │
│ Most cited research for: AI  │
│                             │
│ ┌─ 🥇 ─────────────────┐   │
│ │ 1  Attention Is All    │   │
│ │    You Need             │   │
│ │    📅 2017 · 📝 98.4K  │   │
│ │    📚 NeurIPS          │   │
│ ├─ 🥈 ─────────────────┤   │
│ │ 2  BERT: Pre-training  │   │
│ │    📅 2019 · 📝 75.2K  │   │
│ ├─ 🥉 ─────────────────┤   │
│ │ 3  Deep Residual...    │   │
│ │    📅 2016 · 📝 62.1K  │   │
│ └───────────────────────┘   │
└─────────────────────────────┘
```

---

## 6. Trend Analysis Results

### 6.1 How Trend Analysis Works

The Trend Analysis feature uses the OpenAlex `group_by=publication_year` parameter to retrieve the number of publications for each year associated with a given search keyword. The data is then:

1. **Filtered** to include only valid years (1900 – current year).
2. **Sorted** chronologically by year.
3. **Visualized** as an interactive line chart using `fl_chart`.
4. **Analyzed** programmatically to generate insights.

### 6.2 Interactive Features

- **Year Range Slider**: Users can narrow the displayed year range with a `RangeSlider` to focus on specific periods.
- **Touch Tooltips**: Tapping on any point in the chart displays a tooltip showing the exact year and publication count.
- **Curved Line with Gradient Fill**: The chart uses `isCurved: true` with a semi-transparent `belowBarData` gradient for visual appeal.
- **Dot Indicators**: Each data point is marked with a bordered circle dot for clarity.

### 6.3 Auto-Generated Insights

The app automatically generates textual insights based on trend data:

```dart
String insightText = "Publication activity peaked in $peakYear with $maxCount papers.";
if (lastCount > firstCount && lastYear > peakYear - 2) {
  insightText += " Research activity has generally increased over time.";
} else if (lastCount < maxCount && lastYear > peakYear) {
  insightText += " Research activity declined after its peak.";
}
```

### 6.4 Example Analysis Results

| Topic | Total Papers | Peak Year | Trend |
|---|---|---|---|
| Artificial Intelligence | ~128,000+ | 2023 | Strong upward trend, accelerating since 2018 |
| Blockchain | ~30,000+ | 2022 | Rapid growth from 2017, slight plateau in 2023 |
| Data Science | ~85,000+ | 2023 | Consistent growth since 2010 |
| Cybersecurity | ~45,000+ | 2023 | Steady upward trend |
| IoT | ~55,000+ | 2021 | Growth peaked in 2021, slight decline after |

> **Note:** Actual numbers vary based on the OpenAlex database at the time of query.

---

## 7. AI-Assisted Code Review Findings

### 7.1 Code Quality Assessment

The following observations were made during an AI-assisted code review of the entire codebase:

#### ✅ Strengths

| Area | Finding |
|---|---|
| **Architecture** | Clean separation between UI, state management, service, and model layers |
| **Parallel API Calls** | Effective use of `Future.wait` in both `PublicationProvider.search()` and `OpenAlexService.fetchResearchDashboardSummary()` for performance |
| **Data Parsing** | Robust `Publication.fromJson()` with null-safety checks and default values for all 25 fields |
| **Abstract Reconstruction** | Correct implementation of OpenAlex's inverted index format to readable text |
| **Author Filtering** | Thoughtful filtering of invalid/AI-generated author names |
| **UI/UX** | Skeleton loading states, error handling UI, and empty state handling |
| **Reusable Components** | `ExpandableListRow` widget for handling long lists gracefully |
| **Chart Interaction** | Touch tooltips and dynamic axis labeling |

#### ⚠️ Areas for Improvement

| # | Issue | Severity | File | Recommendation |
|---|---|---|---|---|
| 1 | **Duplicate imports** in `search_screen.dart` — all imports from lines 1–11 are duplicated in lines 13–23 | Low | `search_screen.dart` | Remove duplicate import block (lines 13–23) |
| 2 | **No input sanitization** — search keywords are passed directly to the API URL without encoding | Medium | `openalex_service.dart` | Use `Uri.encodeComponent(keyword)` |
| 3 | **No pagination support** — searches are limited to `per-page=200` | Medium | `openalex_service.dart` | Implement cursor-based pagination |
| 4 | **No data caching** — every search triggers fresh API calls even for the same keyword | Medium | `publication_provider.dart` | Add in-memory or local cache |
| 5 | **Hardcoded strings** — UI strings are not externalized for localization | Low | All screens | Use `intl` package or `AppLocalizations` |
| 6 | **No unit tests** — the `test/` directory is empty | Medium | `test/` | Add tests for service and model classes |
| 7 | **Map literal syntax** in `fetchTopAuthors` uses method body syntax for a map literal | Low | `openalex_service.dart:82-85` | Verify map literal syntax compiles correctly |
| 8 | **No retry mechanism** — API failures throw exceptions with generic messages | Low | `openalex_service.dart` | Add retry logic with exponential backoff |
| 9 | **Magic numbers** — values like `1900`, `200`, `20`, `5` are scattered in code | Low | Multiple files | Extract to named constants |

### 7.2 Security Review

| # | Finding | Risk | Recommendation |
|---|---|---|---|
| 1 | No API key is used (OpenAlex is public) | N/A | No action needed — by design |
| 2 | DOI URLs are launched in external browser without validation | Low | Add URL validation before `launchUrl()` |
| 3 | No SSL pinning | Low | Consider for production releases |

### 7.3 Performance Review

| # | Finding | Impact | Recommendation |
|---|---|---|---|
| 1 | Provider search triggers 5+ parallel API calls per search | High network usage | Add debounce on search input |
| 2 | Dashboard summary triggers 6 additional parallel calls | Redundant work | Some calls overlap with main search — consider caching |
| 3 | Full publication list rebuilds on every `notifyListeners()` | UI performance | Use `Selector` or `Consumer` for targeted rebuilds |
| 4 | `chart_widget.dart` and `author.dart` exist but are empty/unused | Dead code | Remove or implement |

---

## 8. Challenges Encountered

### 8.1 OpenAlex Abstract Format

**Challenge:** The OpenAlex API returns abstracts in an **inverted index** format (`{"word": [position1, position2, ...]}`) instead of plain text.

**Solution:** Implemented a reconstruction algorithm that:
1. Maps each word to its position(s)
2. Sorts by position
3. Joins words with spaces to produce readable text

### 8.2 Invalid Author Names in API Data

**Challenge:** The OpenAlex API sometimes returns bot/AI-generated names (e.g., "ChatGPT", "Gemini"), certification exam entries, or URLs as author names, polluting the Top Authors rankings.

**Solution:** Created a shared `_isValidAuthorName()` method with pattern matching against known invalid entries, applied consistently in both the Top Authors API call and the Dashboard Top Author call.

### 8.3 Duplicate Authors with Different IDs

**Challenge:** The same author may appear multiple times with different OpenAlex IDs due to name variants or institutional affiliations.

**Solution:** Implemented a merge strategy in `fetchTopAuthors()` that groups by `key_display_name` and sums publication counts:

```dart
Map<String, int> mergedAuthors = {};
for (var e in results) {
  String name = e['key_display_name']?.toString().trim() ?? "Unknown";
  mergedAuthors[name] = (mergedAuthors[name] ?? 0) + count;
}
```

### 8.4 Chart Edge Cases

**Challenge:** When only one year of data exists or all data points have the same year, the chart and slider crash due to `min == max`.

**Solution:** Added guard logic:
```dart
if (absoluteMin == absoluteMax) {
  absoluteMin -= 1;
  absoluteMax += 1;
}
```

### 8.5 Average Citation Calculation Limitations

**Challenge:** The OpenAlex API doesn't provide a direct average citation count metric. Calculating it over all results is impractical.

**Solution:** Approximated by calculating the average over the **top 200 papers** (sorted by citation count), with a disclaimer note in the UI: *"Average citations calculated from top 200 sampled papers"*.

### 8.6 API Response Timeouts

**Challenge:** Some complex searches with many results caused timeout errors.

**Solution:** Configured Dio with explicit 10-second timeouts and wrapped all API calls in try-catch blocks with user-friendly error messages and retry buttons.

---

## 9. Lessons Learned

### 9.1 Technical Lessons

1. **Parallel API calls with `Future.wait`** can dramatically improve perceived performance — reducing 5 sequential calls (potentially 5–10 seconds) to the duration of the slowest single call (~1–2 seconds).

2. **Provider pattern** offers a good balance of simplicity and power for medium-sized Flutter apps. A single `ChangeNotifier` was sufficient to manage state across 7 screens.

3. **Real-world API data is messy.** The OpenAlex data required significant cleaning — from abstract reconstruction to author name validation to handling null/missing fields for 25+ attributes.

4. **`fl_chart` is powerful but requires careful configuration.** Edge cases like empty data, single data points, and very large ranges needed explicit handling to prevent crashes.

5. **UI skeleton loading** is a better user experience than a simple spinner — it gives users spatial awareness of where content will appear.

### 9.2 Design Lessons

1. **Bottom navigation + Drawer** is an effective pattern when you have 4 primary features and additional secondary features.

2. **Quick topic chips** significantly improve first-time user experience by providing immediate, one-tap searches.

3. **Auto-generated insights** (like the trend analysis text) add significant value beyond raw data visualization.

4. **KPI dashboard cards** are more impactful when they include contextual icons and color coding.

### 9.3 Process Lessons

1. **Iterative development** works well — starting with the search feature, then layering on trends, top papers, and finally the dashboard allowed incremental testing.

2. **API exploration first** — spending time understanding the OpenAlex API capabilities (grouping, sorting, meta counts) before coding enabled better feature design.

3. **Data validation cannot be an afterthought** — the author name filtering logic was added after initial testing revealed data quality issues.

---

## Appendix

### A. API Reference

- OpenAlex API Documentation: https://docs.openalex.org/
- OpenAlex Works Endpoint: https://docs.openalex.org/api-entities/works
- OpenAlex Group By: https://docs.openalex.org/how-to-use-the-api/get-groups-of-entities

### B. Dependencies (pubspec.yaml)

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Core framework |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `dio` | ^5.8.0 | HTTP client for API calls |
| `provider` | ^6.1.5 | State management |
| `fl_chart` | ^1.0.0 | Interactive charts |
| `cached_network_image` | ^3.4.1 | Image caching |
| `url_launcher` | ^6.3.0 | External URL launching |
| `flutter_lints` | ^6.0.0 | Code quality linting |

### C. How to Run

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd journal_trend_analyzer

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

*Report generated on June 18, 2026*
