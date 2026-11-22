# What Would My Scuba Instructor Do?

A static, dependency-free website for Christopher Willey's scuba career, books, photographs, videos and WWMSID store. The existing domain remains `www.wwmsid.ca` through the unchanged `CNAME`.

## Preview and checks

Requires Node.js 22 or newer. From the repository root:

```powershell
node tools/preview.mjs
```

Open `http://127.0.0.1:4173`. Stop the server with Ctrl+C. All site pages also use relative links and can be opened as local HTML files.

```powershell
node --check script.js
node tools/check-site.mjs
```

The GitHub workflow only checks the site; it does not deploy it. Link checks are case-sensitive for GitHub Pages. `node tools/check-site.mjs --external` additionally records HTTP results in the ignored `.review` directory. An HTTP success does not prove that a retailer listing or contact endpoint works.

## Review before publication

Read `docs/website-review.md` and `docs/photo-selection.csv`. The review branch is `codex/wwmsid-career-redesign`. No merge, push or deployment is part of the current work. The second book is planned for 2027, confirmed by the owner during review. Its title, cover and exact date remain unspecified.

The photo selection is declared in `media-selection.json`. Captions describe visible subjects; people, individual locations and capture dates require confirmation. Most of the dive-shop and boat archive is from Roatan according to the owner, but this is not evidence for every photograph.

## Private media inventory

`.review/` is intentionally ignored by Git. It contains the private CSV/JSON inventory, contact sheets, original HTML snapshots, original metadata, duplicate candidates, video-frame samples and screenshots. Do not move this material into public website assets.

On this Windows workstation, PowerShell 7, System.Drawing, ffmpeg and ffprobe can reproduce the inventory and optimized assets:

```powershell
pwsh -NoProfile -File tools/inventory-media.ps1
pwsh -NoProfile -File tools/enrich-media.ps1
pwsh -NoProfile -File tools/optimize-media.ps1
node tools/build-gallery.mjs
node tools/analyze-media.mjs
```

The default source folders are the three authorized folders under the user's `OneDrive/Pictures`. Cloud-only files are opened through the signed-in Windows OneDrive provider. These commands read originals and write only derived files in the repository. Inventory IDs depend on the sorted source list; if files are added, reconcile the selection with filenames and hashes before rebuilding. Selection notes are editorial judgements, not automated quality scores. Source EXIF dates, filesystem dates and cloud upload dates are distinct.

`tools/optimize-site-images.ps1` creates smaller copies of existing store and book images. `tools/optimize-videos.ps1` creates full-duration 720p copies of three selected videos, preserving source audio when present. Original photographs and videos must not be copied into Git.

## GitHub Pages

The site needs no application server, database, build framework or secret. Keep the existing Pages configuration and `CNAME`. After approval, merge the reviewed branch using the repository's normal workflow and verify the deployed site, HTTPS, domain and contact form.

For an artifact-based GitHub Pages deployment, `node tools/package-pages.mjs` prepares `.review/pages` with the website and historic assets, excluding private inventory, review documents and tooling. The helper does not upload or publish anything. Existing original `Photos/` assets remain in the artifact to preserve direct URLs. New pages use optimized assets instead.
