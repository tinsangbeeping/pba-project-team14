# Codebook — Taipei housing sales (Milestone 3)
Source: Taipei City Actual Price Weekly Data, file RPWeekData(1151103).csv.

| Variable | Description | Notes |
|---|---|---|
| CASE_T | Transaction type | Keep 買賣 |
| CASE_F | Transaction category | Keep 房地(土地+建物) and 房地(土地+建物)+車位 |
| DISTRICT | Taipei administrative district | Original Chinese labels |
| SDATE | Transaction date | ROC date; first 3 digits used for year |
| year | Gregorian transaction year | ROC year + 1911 |
| UPRICE | Reported sale unit price | NT$10,000 per ping; verify against official metadata |
| price_per_ping_10k_ntd | Plot outcome | Copy of UPRICE, positive records only |
| TPRICE | Total transaction price | NT$10,000 |
| FAREA | Reported building area | Ping; must be positive for plot sample |
| BUITYPE | Building type | Original Chinese labels |
| building_group | Derived building type | High-rise, mid-rise with elevator, walk-up; other/missing unclassified |
| FDATE | Building completion date | Mostly missing in this snapshot; not used for age plots |
| ELEVATOR | Elevator indicator | Reserved for later analysis |
| PARKTYPE | Parking category | Reserved for later analysis |

**Cleaning:** Exclude rent/pre-sales/land-only/parking-only; require valid positive UPRICE and FAREA, district and year. The plotting script uses only 2026 transactions and requires at least 5 observations per displayed district/type. No outlier trimming or imputation is applied. Snapshot coverage is not a random sample of the full market.
