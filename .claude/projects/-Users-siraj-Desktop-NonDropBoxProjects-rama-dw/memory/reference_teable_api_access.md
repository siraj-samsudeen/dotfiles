---
name: reference-teable-api-access
description: "Teable Cloud REST API — base id, root, browser-UA required (Cloudflare 1010), 4 traps; token is a secret"
metadata: 
  node_type: memory
  type: reference
  originSessionId: e4d90a40-8d43-41ab-a38b-b8cc95a3b5a8
---

Teable Cloud REST API for the reference-data base (#307, [[project-reference-data-teable-307]]).

- **Root:** `https://app.teable.ai/api`. **Auth:** `Authorization: Bearer <token>`.
- **Base:** `bsel9E8xTO9V3ZrOxmV`. Token is a **Personal Access Token** — never commit it; for the
  step-2 sync it lives as a **Railway secret** (this session it sat only in the run scratchpad).
- Key endpoints: `POST /base/{base}/table` (create table w/ `fields`), `POST /table/{tid}/record`
  (`fieldKeyType:name`, `typecast:true`), `DELETE /table/{tid}/record/{rid}`, `DELETE /base/{base}/table/{tid}`.
  Link-field record value = `{"id": <foreign recordId>}`.

**Four traps (cost real time this session):**
1. **Cloudflare blocks a bare `urllib` User-Agent** → misleading `403 code 1010` on *every* call
   (even unauthenticated). Send a browser-like `User-Agent` header.
2. **Every new table is seeded with 3 empty phantom rows** — the loader must delete them post-insert.
3. **A link field cannot be a table's primary field** (`400 primaryFieldNotSupported`) — make the
   first field text/select, link fields come later.
4. **`DELETE /record` returns an empty body** — don't `json.loads` it blindly.
