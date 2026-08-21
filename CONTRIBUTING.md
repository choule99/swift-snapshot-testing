# Contributing

## Publishing the documentation site

GitHub Pages publishes the committed `docs/` directory from `main`. Set this once in the
repository's [Pages publishing settings](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).
Choose **Deploy from a branch**, then select the `main` branch and `/docs` folder.

After publishing a GitHub release, rebuild the site with:

```sh
make website-install
make site-build
make site-check
```

Review the generated release information and DocC output under `docs/`, then commit those changes
with the release.

Preview the assembled site with:

```sh
make site-preview
```

Open the exact URL printed by the command. Do not open `docs/index.html` directly or serve `docs/`
at the URL root. The generated asset URLs include the `/swift-snapshot-testing/` prefix required by
GitHub Pages.
