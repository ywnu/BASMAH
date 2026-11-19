# Aseel – SQL Operations & Evidence (Branch: `feature/sql-operations`)

## 1. Seed-data matrix (Week 12 – "Plan data")
| Table | Rows | Fixed IDs | Notes |
|---|---|---|---|
| Users | 6 | 1–6 | 2 Admin (Diyam=1, Jumanah=2), Researchers (Aseel=3, Sara=6), Reviewers (Hanan=4, Bayader=5) |
| Projects | 3 | 1–3 | Health Myths (owner 3), Science Facts (owner 6), Geography (owner 1) |
| Sources | 8 | 1–8 | 2–3 per project; types: Article, Report, Website, Book, Dataset |
| Claims | 12 | 1–12 | Status mix: 5 Verified, 4 Rejected, 2 Pending, 1 Disputed |
| Evidence | 16 | 1–16 | Supports / Contradicts / Neutral; each claim has 1–2 |
| Reviews | 12 | 1–12 | Claims 4 and 9 have no review (for LEFT JOIN demo) |
| Versions | 8 | 1–8 | Claims 1, 2, 5, 7 have 2 versions each |
| ActivityLogs | 0 | – | Filled only by Bayader's trigger |

**Reserved IDs:** 9000+ are for disposable test rows (Hanan/Bayader/Aseel). Seed never uses them.
**Insert order:** Users → Projects → Sources → Claims → Evidence → Reviews → Versions.

## 2. Query checklist (Week 12 – "Plan queries")
- [x] SELECT / WHERE / ORDER BY / LIMIT / LIKE / IN – Q1–Q5
- [x] JOIN (inner, multi-table, LEFT JOIN) – Q6–Q9
- [x] GROUP BY, aggregates (COUNT, MIN, MAX, SUM), HAVING – Q10–Q14
- [x] Subqueries – Q15–Q17
- [x] UPDATE (scoped + ROLLBACK) – Q18
- [x] Safe DELETE (disposable row) – Q19

## 3. Query descriptions & expected results
See the comment above each query in `sql/operations/03_queries.sql` (purpose + expected result).

## 4. Demo script (Week 14 – "Support presentation")
1. Show the data: "6 users, 3 projects, 12 claims…" (row counts).
2. **JOIN (Q7):** "Each claim is linked to its evidence and the source that provides it."
3. **LEFT JOIN (Q9):** "These two claims have not been reviewed yet."
4. **GROUP BY (Q10/Q11):** "Claims per status; claims with 2+ pieces of evidence."
5. **Subquery (Q15):** "Claims that have at least one contradicting evidence."
6. **UPDATE + ROLLBACK (Q18):** "Status changes inside a transaction, then is rolled back – data is intact."
7. **DELETE (Q19):** "Only a disposable row is deleted, never real data."

## 5. Screenshots to take (when real MySQL is available)
Folder `evidence/`: row counts after seed, then one screenshot per query Q1–Q19 (statement + output table).
