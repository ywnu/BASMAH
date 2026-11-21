# Aseel – SQL Operations & Evidence (Branch: `feature/sql-operations`)

Written against Jumanah's schema (`01_create_tables.sql`, database `BASMAH`) and run on MySQL Workbench.

## 1. Seed-data matrix
| Table | Rows | Fixed IDs | Notes |
|---|---|---|---|
| Users | 6 | 1–6 | 1 Diyam Almneea (Admin), 2 Jumanah Alotaibi (Admin), 3 Aseel Alotaibi (Researcher), 4 Hanan Almutairi (Reviewer), 5 Bayader Alotaibi (Reviewer), 6 Sara Alshayea (Researcher) |
| Projects | 3 | 1–3 | Health Myths Check (owner 3), Science Facts Check (owner 6), Geography Basics Check (owner 1) |
| Sources | 8 | 1–8 | Sources are not tied to a project in the schema |
| Claims | 12 | 1–12 | Status: 5 Verified, 4 Rejected, 2 Pending, 1 Disputed |
| Evidence | 16 | 1–16 | Types: Study, Expert Statement, Reference Data, Social Media Post |
| Reviews | 12 | 1–12 | Claims 4 and 9 have no review (LEFT JOIN demo) |
| Versions | 5 | 1–5 | Claim 1 edited twice; claims 2, 5, 7 once. `PreviousText` = text before the edit |
| ActivityLogs | 0 | – | Intentionally empty; filled only by Bayader's trigger |

Reserved IDs for disposable test rows: **9000+** (Aseel 9001, Hanan from 9100, Bayader from 9200).
Insert order: Users → Projects → Sources → Claims → Evidence → Reviews → Versions.

## 2. Query checklist
- [x] SELECT / WHERE / ORDER BY / LIMIT / LIKE / IN – Q1–Q5
- [x] JOIN (inner, multi-table, LEFT JOIN) – Q6–Q9
- [x] GROUP BY, aggregates, HAVING – Q10–Q14
- [x] Subqueries – Q15–Q16
- [x] Versions query – Q17
- [x] UPDATE (scoped + ROLLBACK) – Q18
- [x] Safe DELETE (disposable row) – Q19

Purpose and expected result of each query are in the comments of `sql/operations/03_queries.sql`.

## 3. Results observed on MySQL (all matched the expected results)
| Query | Observed result |
|---|---|
| Q1 | 12 claims |
| Q2 | 5 verified claims (ids 2, 7, 8, 10, 12) |
| Q3 | ids 12, 11, 10, 9, 8 |
| Q4 | ids 3, 7, 8 |
| Q5 | ids 1, 4, 9 |
| Q6 | 12 rows (claim, project, creator) |
| Q7 | 16 rows (claim, evidence type, source) |
| Q8 | 12 rows (claim, reviewer, decision) |
| Q9 | claims 4 and 9 (no review) |
| Q10 | Disputed 1, Verified 5, Rejected 4, Pending 2 |
| Q11 | claims 1, 3, 10, 11 (2 evidence each) |
| Q12 | Health Myths 4/1, Science Facts 5/2, Geography Basics 3/2 (claims / verified) |
| Q13 | Hanan 6, Bayader 6 |
| Q14 | 8 sources; source 3 = 4 social media posts, source 8 = 3 reference data |
| Q15 | claims 1, 3, 5, 6, 11 |
| Q16 | claims 1, 3, 10, 11 |
| Q17 | claim 1 = 2 edits; claims 2, 5, 7 = 1 edit each |
| Q18 | claim 4: `Verified` inside the transaction, `Pending` after ROLLBACK |
| Q19 | row 9001 present after INSERT, count 0 after DELETE |

Data-quality checks DQ1–DQ5 (`02b_data_quality_checks.sql`): all returned 0 rows.
Row counts: Users 6, Projects 3, Sources 8, Claims 12, Evidence 16, Reviews 12, Versions 5, ActivityLogs 0.

## 4. Demo script
1. Row counts: "6 users, 3 projects, 8 sources, 12 claims…"
2. **JOIN (Q7):** each claim linked to its evidence and the source behind it.
3. **LEFT JOIN (Q9):** claims 4 and 9 have not been reviewed yet.
4. **GROUP BY (Q10/Q11):** claims per status; claims with 2+ pieces of evidence.
5. **Subquery (Q15):** claims that received a Reject review.
6. **UPDATE + ROLLBACK (Q18):** status changes inside a transaction, then is rolled back.
7. **DELETE (Q19):** only a disposable row is deleted.
