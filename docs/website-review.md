# WWMSID website review

Prepared 2026-11-21 for owner review. Branch: `codex/wwmsid-career-redesign`.

The work is a local proposal. Nothing has been pushed, merged or deployed. `main`, the live site, DNS and the existing `CNAME` have not been changed. The branch base matches `origin/main` after fetching. Existing original assets remain in the repository, and OneDrive originals have only been read.

## Website audit and improvement plan

| Priority | Finding in the original repository | Proposed resolution and status |
| --- | --- | --- |
| High | 42 broken local references, counting repeated references separately | Fixed. Fifteen distinct numbered gallery images were absent, `3.JPG` had the wrong case, six CSS backgrounds were absent, and navigation linked to nonexistent `videos.html`. |
| High | Windows tolerated image filename casing that GitHub Pages would reject | Corrected to `3.jpg`; added a case-sensitive static checker and a check-only GitHub workflow. |
| High | Canonical links used `yourdomain.com` | Set canonical URLs to the existing `www.wwmsid.ca` domain. Retained `CNAME`. `video.html` is canonical; `videos.html` is a compatibility redirect. |
| High | Three YouTube embeds used `VIDEO_ID_2`, `VIDEO_ID_3`, `VIDEO_ID_4` | Replaced active fake embeds with honest inactive slots, grouped under “Additional video slots.” Retained the real WWMSID feature and added three small, playable archive clips. |
| High | A clickable `div` served as the mobile menu; dropdowns depended on hover or a two-tap convention | Added a native Menu button, expanded state, consistent navigation, visible keyboard focus, Escape handling and a skip link. |
| High | Gallery opened original files in new tabs, lacked filters/captions, and assigned generic or misleading alt text | Added 37 visually selected photographs, seven editorial categories, factual subject captions and a keyboard-operated lightbox. Full portraits remain visible in the viewer. |
| Medium | The site was predominantly a book promotion, with limited visual narrative about the career | Added a photographic career-led homepage, introduction, Books page and Stories page using existing career facts and media links. |
| Medium | Original gallery and store pages loaded large source files | Added responsive photo derivatives at 640, 960 and 1600 pixel width, lazy loading, dimension attributes, smaller store/book images, and click-to-play 720p video. No new full-resolution originals were added. |
| Medium | Page styles repeated red/black cards and had inconsistent legacy navigation | Added a shared ocean-blue, white and dive-flag-red design, editorial typography, spacing and responsive layouts. Existing styling remains as the compatibility base. |
| Medium | The second book had no dedicated place and was described as postponed indefinitely | Added a second-book section. The owner confirmed a 2027 release during this review; both the homepage notice and Books page now say “planned for release in 2027.” Title, cover and precise date are not invented. |
| Medium | Store is a contact-to-order catalogue, with no cart/payment system | Preserved all product descriptions, prices and order enquiries. Confirm currency, current prices, availability and fulfilment before launch. A checkout would be a separate decision. |
| Medium | Contact form posts to an existing Formspree endpoint | Preserved the endpoint, method, field names and required fields. Reviewed layout and labels. No message was submitted; actual delivery is unverified. |
| Medium | Token page has a different layout and financial/store claims | Preserved its text and links, added shared navigation, and kept it reachable from the footer. Owner should decide its role on a professional career website; no removal or revalidation of its financial claims has been assumed. |
| Medium | Career credentials, personal history and media links require factual stewardship | Preserved existing career copy, certification lists and medical-history wording. Existing published claims have not been independently recertified. No new dates, training totals or first-person anecdotes have been invented. |
| Low | Sitemap omitted video content and duplicated the home URL | Updated the sitemap for the canonical pages and added its URL to `robots.txt`. |

### Content retained

Every original page path remains available, along with all 64 files in `Photos/` and the root branding assets. All 18 pre-existing gallery photographs can be browsed in an expandable original collection, including assets that were previously unlinked. Earlier gallery headings, descriptions and extant images remain in expandable sections. Nonexistent photo slots are labelled as awaiting confirmation rather than filled with unrelated photographs. The menu has been simplified; destinations remain reachable through the main menu, page links or footer.

Original snapshots are available locally under `.review/original/`. Navigation markup, placeholder instructions, alt text and presentation have been edited; no original book, career, merchandise, credential, media article, or token content has been silently discarded. The old indefinite book delay was replaced at the owner's explicit instruction.

### Recommended next editorial steps

1. Approve the proposed design, 37 photographs and three clips. Review the supplied screenshots, selection sheets and `photo-selection.csv`.
2. Identify the people, dive shops, geographic exceptions and events in the shortlisted photographs. The owner says most dive-shop and boat media is from Roatan. This supports collection-level context, not a location claim for every image. A location-specific Roatan album is reserved until individual assignments are confirmed.
3. Supply the second book's title and cover when ready; keep 2027 as the planned release year.
4. Provide confirmed career dates and two or three real anecdotes. A dated career timeline is deliberately deferred; the current site presents career themes without fabricating chronology. The Stories page is an index to existing career material, book content and published media, not invented new stories.
5. Confirm photo attribution and permission, particularly `gallery2.jpg` / `m0018`. Its EXIF Artist field credits **David Sanchez Pachon**. That credit is shown on the homepage, Stories page and curated gallery. The original visible watermark is preserved in full-image derivatives.
6. Decide whether to retain earlier empty gallery/video slots in the final visitor experience. They are retained in expandable sections pending approval to remove them.
7. Confirm store details and whether the token page should remain part of the public site. Test contact-form delivery with an explicitly authorized real test message.
8. Approve merging/deployment only after those decisions and a final review of the Git diff. Keep GitHub Pages and the existing domain. Verify HTTPS, apex/www routing, navigation, video playback and contact delivery after the approved deployment.

## OneDrive inventory

Both the signed-in OneDrive connector and local Files On-Demand paths were verified. A cloud-only photograph, `P1100414.Vivid.JPG`, was opened and decoded at **4000 × 3000**. No additional connection or download method is missing.

| Authorized folder | Images | Videos | Total |
| --- | ---: | ---: | ---: |
| done to be id | 1,410 | 14 | 1,424 |
| Garbage dive against debris | 160 | 0 | 160 |
| Scuba | 98 | 7 | 105 |
| **OneDrive total** | **1,668** | **21** | **1,689** |

The inventory also includes the 18 existing website gallery assets, making 1,707 records overall. All 1,668 OneDrive images decoded successfully. All 21 videos yielded metadata; 83 sample frames were generated and visually screened. One clip is extremely short and yielded three frames rather than four. Sampling is not a complete audio or frame-by-frame review of every original video.

The source collection totals approximately 3.82 GB. Files were opened through the current OneDrive provider, allowing Windows to retrieve cloud-only bytes. Files were not renamed, moved, edited, deleted, or pinned for permanent offline retention. Windows may retain retrieved bytes in its normal cache.

### Private inventory deliverables

These files are deliberately excluded from Git and publication:

- `.review/inventory.csv` and `.review/inventory.json`: source paths, filenames, folder, byte size, filesystem creation/modification times in UTC, original placeholder attributes, type, dimensions, EXIF capture time and camera where available, video duration, SHA-256, difference hash, quality candidates, category basis, selection and visual review notes.
- `.review/metadata/`: original available EXIF property values and ffprobe stream/format metadata. Precise location or other personal metadata is not copied to public image derivatives.
- `.review/sheets/`: 29 contact sheets covering all 1,686 images, including the 18 website assets. All sheets were visually screened.
- `.review/selected/`: larger review sheets for all 37 selected photographs.
- `.review/video-frames/`: video-frame samples and three review sheets covering all 21 clips.
- `.review/exact-duplicates.csv`: eight SHA-256 duplicate groups. Seven are existing website photographs also found in OneDrive; one group is duplicated within OneDrive itself.
- `.review/near-duplicates.json`: 23 candidate pairs from perceptual similarity. These are **candidates**, not 23 confirmed duplicates. Similar coral patterns and featureless backgrounds can produce false matches.
- `.review/review.html`: local visual review index linking these artifacts.

Filesystem creation/modification dates and cloud upload dates are not shooting dates. EXIF capture times are retained as source metadata; timezone, camera-clock accuracy and location are not assumed. Original folder labels are used only as provisional organization. Individual scientific species identification, people's names and story context are not inferred from filenames.

### Quality review

The shortlist was selected through contact-sheet screening and larger exported-image review, considering focus, composition, visual variety and storytelling value. It includes career scenes, underwater portraits, reef details, dive teams, a pool scene, lionfish, cleanup activity, equipment and above-water moments. These are proposed editorial categories; course participants, friendships, specific cleanup events and individual locations still need owner confirmation.

84 OneDrive images have a longest edge below 1000 pixels; these are limited to small display uses. An additional 18 have low coarse edge detail and are flagged for closer review, not automatically declared blurred. Visually observed exclusions include `m1040` (motion blur), `m1437` (blurred moving fish), and `m1420` (clipped bright subject detail). Screenshots of profiles/cards and other material containing personal details were excluded from public assets. No source file was deleted or altered as a result of a quality flag.

## Optimization and hosting

The proposed site contains 37 curated photographs, the preserved original gallery, 36 optimized pre-existing site images, three 720p H.264/AAC clips and the existing YouTube feature. New still-image exports are capped at 1600 pixels wide, respect source aspect ratios/orientation and do not upscale smaller sources. Display images are metadata-free JPEG derivatives; full-resolution source files are not introduced into Git.

The hero source is approximately 4.41 MB; its 1600-pixel derivative is approximately 204 KB and the 640-pixel gallery version is approximately 42 KB. The three selected source videos total approximately 215 MB; their full-duration web copies total **8.82 MB**. Video uses `preload="none"`, controls and posters, so it is not downloaded or played automatically. Video source audio is retained when present. No subtitles or spoken transcript have been invented.

All newly generated web assets together total approximately 35.8 MB across 187 files, including multiple still-image sizes, preserved small-asset derivatives and video posters. Existing `Photos/` files remain unchanged to preserve historical direct links. GitHub Pages can serve the static site without a build service or runtime secrets.

`node tools/package-pages.mjs` creates a local GitHub Pages artifact under `.review/pages`; it excludes private inventory, source metadata and tooling. It does not deploy. The added GitHub workflow performs checks only.

## External links and verification limits

Read-only HTTP checks were performed outside the network sandbox. Results are recorded in `.review/external-links.json`.

- The current public site, Facebook, Amazon, DiveNewswire, DeeperBlue and Paya links returned HTTP 200. This does not independently establish current product availability or the accuracy of article text.
- The Reminder article redirected to the publication's homepage. The original link is retained and should be replaced with the correct article URL when confirmed.
- Audible returned 503; its availability remains unverified. Dexscreener and Solscan returned 403 and could not be verified automatically. These links were retained.
- The existing YouTube embed endpoint returned 200. Its in-player availability still needs verification independently of HTTP status.
- `books.html` and `stories.html` return 404 on the live domain because they are new, unpublished pages. The old `videos.html` URL also returned 404 live; the proposed compatibility redirect fixes it after an approved deployment.
- No order, payment, form submission, message, DNS change, push, merge or deployment was performed.

Validation details and screenshots are in the local review folder. Static checks cover all 11 HTML pages, case-sensitive assets, responsive-image references, fragments, duplicate IDs, one primary heading and active placeholder URLs. Browser checks cover mobile navigation, gallery filtering and lightbox behavior. Browser viewport and media checks are recorded separately; no Lighthouse score, network-throttled performance result, assistive-technology certification or real contact delivery is claimed.

Additional preservation checks found no missing items among 77 credential/heading entries on the career page, 69 product/price/heading entries in the store, the contact text/field configuration, or token-page text. Git confirms no changes to the original `Photos/`, branding files or `CNAME`.

Responsive layouts were checked at 320, 390, 768, approximately 769, 820, 1024 and 1440 pixels. A three-pixel overflow on the 320-pixel contact page was corrected and rechecked. Gallery filtering returned the expected four team photographs; next-image navigation stayed within that filtered group. Escape closed the lightbox and returned focus to the opening photograph. All three new MP4s were fully decoded with ffmpeg without errors, and browser playback was checked separately. Source soundtracks were not editorially transcribed or interpreted.
