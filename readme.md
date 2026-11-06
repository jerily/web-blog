# web-blog — User & Technical Requirements

## Rules
- Implement the package in Tcl and use `tpersist`, `cmark_gfm` and its own bundled Lexical visual editor.
- Provide `::web::blog::mount` in `library/mount.tcl`, following the [web package mount contract](MOUNTING.md).
- Schema setup and directory import remain explicit maintenance work.

## Commandments
- Own `web_blog_items` and `web_blog_revisions`; scope every query by domain.
- Install independently of web-wiki. Do not add a shared content package or compatibility layer.
- Preserve revisions and deactivate removed sources.
- Keep persistence, routing, rendering and editor assets inside this package.
- Render the blog index, posts and editor with its own `jinja2-tcl` templates.

## Principles
- The host owns its router, connection, authentication and CSRF callbacks.
- A blog is a chronological publication of dated Markdown files.

## Best Practices
- Open a dedicated `tpersist` connection with `-autobegin 0` in each worker.
- Mount before catch-all routes; use a distinct prefix for each mount.

## Generic Guidelines
- `library/mount.tcl` is the standardized entry-point location for all web packages.
- `::web::blog` owns its schema, persistence, routes, templates and editor assets, including publication-date rules. No procedure or runtime dependency is shared with web-wiki.
- SQLite is the supported backend for this first release.

## Install and use

`ttrek.json` directly declares Tcl, `tpersist`, `tpathexp`, `cmark-gfm-tcl`, `jinja2-tcl`, `tjson`, and `tdbcsqlite3`. The public registry supplies these dependencies. No wiki installation is required.

With a current checkout of [private-ttrek-registry](https://github.com/jerily/private-ttrek-registry)
beside this project, install using a ttrek build with `-add-pubreg` support:

```sh
ttrek install -y -registry ../private-ttrek-registry -add-pubreg
```

`-add-pubreg` searches the public registry after the private recipes. It uses the
local copy maintained by `ttrek sync` when available, otherwise the public API.

Git must have access to the private package sources. Registry selection does not
require a token; source cloning uses Git's existing credentials.

Requires the native dependencies listed above, matching the Tcl interpreter ABI. No native code or JavaScript build is needed:

```sh
cmake -S . -B build -DTCLSH=tclsh9.1
cmake --install build --prefix "$PWD/stage"
```

Installation creates `stage/lib/web-blog0.1.0`. Put that directory (or `stage/lib`) and dependency packages on the Tcl search path.

```tcl
package require web-blog 0.1.0
set db [::tpersist::db_connect -database company.sqlite -autobegin 0]
::web::blog::initdb $db
set blog [::web::blog::create -connection $db -domain example.com -title Journal]
::web::blog::sync $blog ./content/blog
set router [::tpathexp::router]
::web::blog::mount $router -store $blog -prefix /blog
puts [dict get [$router dispatch {method GET path /blog}] body]
```

Use filenames such as `2026-11-05-launch.md` containing `# Launch`. The resulting path is `/2026-11-05-launch`, beneath the configured mount prefix. Nested source directories retain their slug hierarchy; the main blog index lists all active posts newest first, regardless of folder. Dates must be real calendar dates in `YYYY-MM-DD` form. A malformed filename aborts the import. Dates order posts; they do not schedule future publication. All successfully imported posts are public immediately.

The title comes from the first Markdown heading or filename stem after removing its date prefix. Renaming a heading changes the imported URL; browser title edits keep it stable. A source change supersedes browser edits and retains them in history; unchanged sources preserve browser edits.

The saved title supplies the visible post heading. Rendering omits a leading Markdown H1 to avoid a duplicate title; stored Markdown remains unchanged.

Public commands are `create`, `initdb`, `sync`, `load`, `posts`, `history`, `add`, `save` and `mount`. `posts store` returns active post dictionaries ordered by `published_at DESC, path ASC`. `save` requires the expected revision. `add store /parent title markdown YYYY-MM-DD` creates a post at a date-and-title-derived URL with revision 1. The date must be a real calendar date; it orders posts without scheduling publication.

Mount options, authorization/CSRF callbacks and `/_assets`/`/_edit` route conventions are documented in [MOUNTING.md](MOUNTING.md). Lexical supplies rich editing for its supported Markdown subset and preserves tables, code and other unsupported constructs in source mode.

Mount accepts `-config [dict create master_template $trustedTemplateSource]` to
replace the package page layout for that instance. The optional `templates` config
key supplies additional named template sources. See the mount contract for the
layout blocks and context. `library/initdb.tcl` supplies the public `initdb`
entry point; hosts invoke it explicitly before importing blog content.

## Browser creation

Enable browser creation with `-config {allow_create true}` on the mount, alongside
both editor callbacks. The flag defaults to `false` and must be a boolean. It does
not enable editing by itself. The index and item pages show **New post** in edit
mode; the form uses the existing local Markdown editor. Creation is authorized,
CSRF checked and stored atomically with revision 1. Existing URLs, including
inactive items, return 409 instead of being overwritten.

Browser-created items have an empty `source_path` and are stored only in SQLite.
Sync preserves these items and their parent folders, even when a source folder
is removed. A source file colliding with a browser-created URL aborts sync with
409; it cannot silently replace that item. Source-backed items retain their
existing import/update/deactivation behavior.

## Schema and editor ownership

Tables are `web_blog_items` and `web_blog_revisions`, keyed by domain, path and
revision. Publication dates belong to the blog item schema. `initdb` creates only
these tables. Version remains `0.1.0`; there are no legacy-table reads, migrations
or compatibility wrappers. Initialize the new schema explicitly and import the
desired sources; old browser revisions are not copied automatically.

The repository contains `assets/`, `frontend/`, third-party licenses, `package.json`,
`package-lock.json`, and `rollup.config.mjs`. Rebuild its editor with `npm ci` and
`npm run build` in this repository. Node is unnecessary for installation/runtime.

## Verification

Run `tclsh9.1 tests/all.tcl` with dependency packages discoverable. Tests cover date validation, ordering, domain isolation, import history and mounted routes. The package tests cover editor authorization, CSRF, revisions, templates and assets without loading wiki.

## Security
### Surface
Public blog index, folder and post views, local editor assets, and optional editing routes.

### Protections
The blog implementation binds SQL values, scopes every query, escapes metadata, uses safe cmark rendering, rejects invalid paths, checks authorization and CSRF, and prevents stale browser updates. Editing is disabled by default; creation additionally requires `allow_create true`.

### Pending
The host owns production authentication, TLS, transport limits and rate limiting. RSS, tags, author profiles, drafts, scheduling and pagination are outside this initial package.
