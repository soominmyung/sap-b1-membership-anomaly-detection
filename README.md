# Rule-Based Membership Claim Irregularity Detection (SAP Business One)

This repository contains example SQL queries used to screen for irregular membership point claims in SAP Business One, based on stakeholder-defined, rule-based conditions.

The queries are designed to surface operational red flags for further manual review by Finance or Retail teams, rather than to make automated determinations.

## Background

In some SAP Business One environments, membership or loyalty data is managed through third-party Retail add-ons. These add-ons often use proprietary table structures and non-descriptive identifiers, which makes it difficult to directly identify membership-related records.

The queries in this repository assume that membership claim events have already been reconstructed into a normalised structure containing:
- CustomerCode
- ClaimDatetime
- Points

The focus here is on detection logic, not on schema reconstruction.

## Detection Logic

The screening logic is based on simple, transparent rules such as:
- unusually frequent claims within a single day
- multiple claims within a short time window
- high cumulative monthly point totals
- high monthly claim counts

A customer is returned if **at least one** rule is triggered.  
The output includes rule-level indicators (O/X) to explain which conditions were met.

Final determination of whether a case is inappropriate is expected to be made through manual review.

## Repository Structure

```
/
├─ queries/
│ ├─ membership_detection.sql
│ └─ membership_drilldown.sql
└─ sample_output/
  └─ detection_output.csv
```

- `membership_detection.sql`  
  Returns customers who trigger one or more screening rules.

- `membership_drilldown.sql`  
  Parameterised query to retrieve detailed claim history for a given customer.

- `sample_output/`  
  Contains anonymised example output for reference.

## Notes

- The queries are intentionally deterministic and easy to interpret.
- Thresholds can be adjusted depending on operational context.
- The examples provided here use anonymised and simplified data.
