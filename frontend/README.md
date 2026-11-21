# BASMAH Frontend (Prototype)

Owner: Deem | Branch: `feature/web-interface`

## Run locally
Open `frontend/index.html` in a modern browser. No installation is required.

## Implemented
- Responsive sidebar and dashboard counts
- Projects, Claims, Sources, Evidence, Reviews and History screens
- Search and add-record forms
- Accessible labels, keyboard focus, skip link, status announcements and modal focus containment
- HTML escaping for displayed mock records

## Important limitations
- All records are **mock data**, held in memory for the current page session only.
- Reloading the page resets changes.
- No authentication, real API, database persistence, edit/delete operations, or production security.
- Fields follow the initial BASMAH schema. Confirm any schema changes with Jumanah.
- The add-record forms do not yet validate foreign keys or cross-table integrity; the future backend must enforce these.
- Dashboard counts are derived from the current mock data.

## Next tasks
1. Agree API endpoints and response/error shapes with Aseel (backend) and Jumanah (schema).
2. Add loading, empty and server-error states for API-backed views.
3. Implement real API client with environment-based base URL.
4. Add record detail/edit flows and stronger validation.
5. Run accessibility and responsive QA, then integration tests.

## Suggested initial API endpoints
- `GET /api/projects`, `POST /api/projects`
- `GET /api/claims`, `POST /api/claims`
- `GET /api/sources`, `POST /api/sources`
- `GET /api/evidence`, `POST /api/evidence`
- `GET /api/reviews`, `POST /api/reviews`
- `GET /api/versions` (read-only initially)

These are **proposals**, not yet agreed with the backend team.
