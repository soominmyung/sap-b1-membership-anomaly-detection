/*
Membership Claim Drill-Down Query
--------------------------------
This parameterised query returns the full claim history
for a single customer.

The CustomerCode value is provided by the user via
SAP Business One Query Manager.
*/

SELECT
    CustomerCode,
    ClaimDatetime,
    Points
FROM MembershipClaims
WHERE CustomerCode = @CustomerCode
ORDER BY ClaimDatetime;
