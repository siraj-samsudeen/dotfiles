---
name: SQL Server logon trigger rejects DB-Library / FreeTDS clients
description: The Gofrugal SQL Server at 192.168.2.62 has a logon trigger that appears to gate on client_interface_name, rejecting FreeTDS/DB-Library (TablePlus on Mac) and accepting Microsoft-official drivers (pyodbc+Driver 18, mssql-jdbc). feather-etl works; TablePlus does not.
type: reference
originSessionId: 404a21b0-cf5e-4125-a0ff-c58091dce4c6
---
## Production impact: none

feather-etl uses `pyodbc` + `ODBC Driver 18 for SQL Server` on Mac — this path **passes the logon trigger** (verified 2026-04-13 with DataAnalyst login). Production ETL will work.

## The finding

The SQL Server at `192.168.2.62:1433` (Gofrugal/ZAKYA/HRDS/etc. databases) runs a server-level logon trigger that rolls back sessions post-auth with error 17892.

Empirical results with the same Mac, VPN, login, and credentials:

| Client | Driver / `client_interface_name` | `APP_NAME()` | Result |
|---|---|---|---|
| TablePlus (Mac) | FreeTDS → `DB-Library` | `TablePlus` | ❌ rejected |
| DBeaver 26 (Mac) | `Microsoft JDBC Driver for SQL Server` | `DBeaver 26.0.2 - SQLEditor <Script.sql>` | ✅ works |
| feather-etl / pyodbc | `ODBC Driver 18 for SQL Server` | `python3` | ✅ works |

APP_NAME is **not** the discriminator (`python3` is accepted). The only attribute that separates accepted from rejected is `client_interface_name` — trigger almost certainly gates on driver type, blocking `DB-Library%` and allowing `Microsoft JDBC%` / `ODBC Driver%`.

## Implications

- **TablePlus on Mac is architecturally incompatible** with this server. TablePlus uses FreeTDS and has no UI to switch drivers. No amount of whitelisting APP_NAME will fix it — even `'TablePlus'` in an allowlist wouldn't matter because the gate is on driver interface, not app name. Recommend DBeaver on Mac for interactive work.
- **TablePlus quirk (separate from trigger issue):** on Mac it sends `HOST_NAME() = "<connection-target>:<port>"` (e.g. `"127.0.0.1:14330"`), not the real hostname. Cosmetic but worth noting.
- **ODBC driver install:** `msodbcsql18` from `microsoft/mssql-release` Homebrew tap. `pyodbc.drivers()` returns `['ODBC Driver 18 for SQL Server']`. feather-etl already surfaces a clear install-hint error when this driver is missing.

## Root-cause doc

`~/Desktop/sqlserver-tableplus-rootcause.md` — DBA-facing write-up from 2026-04-13 investigation. Rewrites primary ask from "whitelist TablePlus" to "confirm the driver-gating policy"; de-escalates urgency since production ETL works.

## Probe server gotcha (for future repro)

- SQL Server 2022 image fails on Apple Silicon under default QEMU emulation. Fix: use `mcr.microsoft.com/azure-sql-edge:latest` (native arm64), or enable Rosetta in Docker Desktop.
- Azure SQL Edge's `sys.dm_exec_sessions` lacks `protocol_type` and `client_net_address` columns. Use `CONNECTIONPROPERTY(...)` instead — works on both Edge and full SQL Server.
- `DataAnalyst` login lacks `VIEW SERVER STATE`, so DMV queries on the real server return permission denied. Session-local functions (`APP_NAME()`, `HOST_NAME()`, `CONNECTIONPROPERTY(...)`) don't need that permission and are sufficient.
