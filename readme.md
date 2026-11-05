# web-blog — User & Technical Requirements

## Rules
- Implement the package in Tcl and use `tpersist`, `cmark_gfm` and the shared Lexical visual editor.
- Provide `::web::blog::mount` in `library/mount.tcl`, following the [web package mount contract](../web-wiki/MOUNTING.md).
- Schema setup and directory import remain explicit maintenance work.

## Commandments
- Isolate posts in the `blog` collection, separately from wiki content with the same domain or path.
- Preserve revisions and deactivate removed sources.
- Reuse the publishing engine and editor distributed by `web-wiki`; do not duplicate them.
- Render the blog index, posts and editor with the shared `jinja2-tcl` templates.

## Principles
- The host owns its router, connection, authentication and CSRF callbacks.
- A blog is a chronological publication of dated Markdown files.

## Best Practices
- Open a dedicated `tpersist` connection with `-autobegin 0` in each worker.
- Mount before catch-all routes; use a distinct prefix for each collection.

## Generic Guidelines
- `library/mount.tcl` is the standardized entry-point location for all web packages.
- `web-wiki` owns shared persistence, HTML rendering, templates and editor assets. `web-blog` owns the public blog API and selects the blog collection and chronology rules.
- SQLite is the supported backend for this first release.

## Install and use

`ttrek.json` declares Tcl and `web-wiki`; persistence, routing, Markdown rendering, `jinja2-tcl` page templates, `tjson`, and the SQLite driver are inherited through `web-wiki`. The private registry provides the `web-wiki` recipe; its native dependencies come from the public registry.

With a current checkout of [private-ttrek-registry](https://github.com/jerily/private-ttrek-registry)
beside this project, install using a ttrek build with `-add-pubreg` support:

```sh
ttrek install -y -registry ../private-ttrek-registry -add-pubreg
```

`-add-pubreg` searches the public registry after the private recipes. It uses the
local copy maintained by `ttrek sync` when available, otherwise the public API.

Git must have access to the private package sources. Registry selection does not
require a token; source cloning uses Git's existing credentials.

Requires `web-wiki 0.1.0` and its dependencies. No native code or JavaScript build is needed:

```sh
cmake -S . -B build -DTCLSH=tclsh9.1
cmake --install build --prefix "$PWD/stage"
```

Installation creates `stage/lib/web-blog0.1.0`. Put that directory (or `stage/lib`) and dependency packages on the Tcl search path.

```tcl
package require web-blog 0.1.0
set db [::tpersist::db_connect -database company.sqlite -autobegin 0]
::web::blog::init_schema $db
set blog [::web::blog::create -connection $db -domain example.com -title Journal]
::web::blog::sync $blog ./content/blog
set router [::tpathexp::router]
::web::blog::mount $router -store $blog -prefix /blog
puts [dict get [$router dispatch {method GET path /blog}] body]
```

Use filenames such as `2026-11-05-launch.md` containing `# Launch`. The resulting path is `/2026-11-05-launch`, beneath the configured mount prefix. Nested source directories retain their slug hierarchy; the main blog index lists all active posts newest first, regardless of folder. Dates must be real calendar dates in `YYYY-MM-DD` form. A malformed filename aborts the import. Dates order posts; they do not schedule future publication. All successfully imported posts are public immediately.

The title comes from the first Markdown heading or filename stem after removing its date prefix. Renaming a heading changes the imported URL; browser title edits keep it stable. Source-baseline, revision, collision, deactivation and reactivation behavior matches `web-wiki`. A source change supersedes browser edits and retains them in history; unchanged sources preserve browser edits.

Public commands are `create`, `init_schema`, `sync`, `load`, `posts`, `history`, `save` and `mount`. Signatures match their wiki equivalents; `posts store` returns active post dictionaries ordered by `published_at DESC, path ASC`. `save` requires the expected revision. The initial browser editor updates existing posts; new posts are introduced through the source directory.

All mount options, authorization/CSRF callbacks and `/_assets`/`/_edit` route conventions match `web-wiki`. Lexical supplies rich editing for its supported Markdown subset and preserves tables, code and other unsupported constructs in source mode.

## Verification

Run `tclsh9.1 tests/all.tcl` with dependency packages discoverable. Tests cover date validation, ordering, domain/collection separation, import history and mounted routes. Shared request/editor behavior is tested by `web-wiki` and by the example site's browser suite.

## Security
### Surface
Public blog index, folder and post views, local editor assets, and optional editing routes.

### Protections
The shared engine binds SQL values, scopes every query, escapes metadata, uses safe cmark rendering, rejects invalid paths, checks authorization and CSRF, and prevents stale browser updates. Editing is disabled by default.

### Pending
The host owns production authentication, TLS, transport limits and rate limiting. RSS, tags, author profiles, drafts, scheduling and pagination are outside this initial package.
