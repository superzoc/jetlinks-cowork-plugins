# Prototype Notes — {{FEATURE_NAME}}

> Status: `prototype-only` · Frontend boundary: _ui | runtime-ui | other_ · Last updated: _YYYY-MM-DD_

## 1. What this prototype covers

_1–2 sentences. Which screens / flows are being explored, and why._

## 2. Prototype location

- Frontend dir: _e.g. `ui/`_
- Route URL: _e.g. `/tenant/quota-preview`_
- Page component: _path from repo root_
- Mock data: _path from repo root_
- Other touched files (router config, menu, etc.):
  - _path_

## 3. Mock data shape

A stripped-down schema of what the page reads. Keep it minimal — real fields/types, no implementation noise.

```ts
// example
type QuotaItem = {
  tenantId: string
  used: number
  limit: number
  updatedAt: string
}
```

## 4. What real backend integration would need

When promoting this from prototype to real implementation:

### Endpoints

- `GET /api/...` — _purpose, query params, response shape_
- `POST /api/...` — _purpose, request body, response shape_

### Data model

- `<entity>` — fields, types, primary key, source-of-truth module
- Relationships / joins to existing entities: _list, or "none"_

### Behaviour the mock currently fakes

- _e.g. pagination is faked client-side; real backend should support `page`/`size` params_
- _e.g. tenant scoping is hardcoded to current user; real backend needs row-level filter_

### Auth / authz / tenant considerations

- _which roles can see this page_
- _multi-tenant isolation requirements_
- _data sensitivity / audit logging needs_

## 5. How to run

```bash
cd <frontend-dir>
pnpm install   # first time only
pnpm dev
```

Open `<route URL>` to view the prototype.

## 6. Promotion plan

What happens to this prototype after the design is validated:

- [ ] Promote: replace mock with real API, keep page in production
- [ ] Park: hide behind feature flag / admin-only route until backend ready
- [ ] Delete: tear down page + route + mock once purpose is served

When promoting:

1. Run `/spec-scaffold {{FEATURE_NAME}}` in this directory if not already done
2. Use this file's section 4 as input to `plan.md` (backend implementation steps)
3. Use this file's section 3 to align `requirements.md` data model
4. Replace mock data with real API calls in the existing component
5. Either delete this file or mark it superseded
