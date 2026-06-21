# HouseScout — marketing site

Static landing page + legal/support pages for the HouseScout iOS app, served at
**housescout.dkcreative.uk**.

- `index.html` — landing page
- `privacy.html` — privacy policy (App Store **Privacy Policy URL**)
- `support.html` — support & FAQ (App Store **Support URL**)
- `terms.html` — terms of use
- `styles.css` — DKC design system (cream / terracotta, Plus Jakarta Sans + Inter)
- `images/` — app icon + screenshots
- `netlify.toml` — static publish config + security headers

No build step — it's plain HTML/CSS. Deployed to Netlify; the App Store listing points
its Privacy Policy URL at `/privacy.html` and Support URL at `/support.html`.

Contact: housescout@dkcreative.uk
