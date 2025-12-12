/*
Rule-Based Membership Claim Irregularity Detection
--------------------------------------------------
This query returns customers who trigger at least one
stakeholder-defined screening rule.

The output includes rule-level indicators (O/X) to
explain which conditions were met.
*/

WITH Base AS (
    SELECT
        CustomerCode,
        ClaimDatetime,
        Points,
        CAST(ClaimDatetime AS DATE) AS ClaimDate,
        FORMAT(ClaimDatetime, 'yyyy-MM') AS ClaimMonth
    FROM MembershipClaims
),

DailyAgg AS (
    SELECT
        CustomerCode,
        ClaimDate,
        COUNT(*) AS DailyCount
    FROM Base
    GROUP BY CustomerCode, ClaimDate
),

MonthlyAgg AS (
    SELECT
        CustomerCode,
        ClaimMonth,
        COUNT(*) AS MonthlyCount,
        SUM(Points) AS MonthlyPoints
    FROM Base
    GROUP BY CustomerCode, ClaimMonth
),

Burst AS (
    SELECT DISTINCT
        b1.CustomerCode,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM Base b2
                WHERE b2.CustomerCode = b1.CustomerCode
                  AND b2.ClaimDatetime <> b1.ClaimDatetime
                  AND ABS(DATEDIFF(MINUTE, b1.ClaimDatetime, b2.ClaimDatetime)) <= 5
            )
            THEN 1 ELSE 0
        END AS Burst5MinFlag
    FROM Base b1
),

MembershipAggregates AS (
    SELECT
        b.CustomerCode,
        MAX(d.DailyCount) AS MaxDailyCount,
        MAX(m.MonthlyCount) AS MaxMonthlyCount,
        MAX(m.MonthlyPoints) AS MaxMonthlyPoints,
        MAX(ISNULL(br.Burst5MinFlag, 0)) AS Burst5MinFlag
    FROM Base b
    LEFT JOIN DailyAgg d
        ON b.CustomerCode = d.CustomerCode
    LEFT JOIN MonthlyAgg m
        ON b.CustomerCode = m.CustomerCode
    LEFT JOIN Burst br
        ON b.CustomerCode = br.CustomerCode
    GROUP BY b.CustomerCode
)

SELECT
    CustomerCode,

    CASE
        WHEN MaxDailyCount >= 3 THEN 'O' ELSE 'X'
    END AS Daily3Plus,

    CASE
        WHEN Burst5MinFlag = 1 THEN 'O' ELSE 'X'
    END AS Burst5Min,

    CASE
        WHEN MaxMonthlyPoints >= 100 THEN 'O' ELSE 'X'
    END AS MonthlyPoints100Plus,

    CASE
        WHEN MaxMonthlyCount >= 15 THEN 'O' ELSE 'X'
    END AS MonthlyClaims15Plus

FROM MembershipAggregates
WHERE
      MaxDailyCount     >= 3
   OR Burst5MinFlag     = 1
   OR MaxMonthlyPoints >= 100
   OR MaxMonthlyCount  >= 15
ORDER BY CustomerCode;
