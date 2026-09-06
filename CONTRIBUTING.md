# Contributing

## Publishing the documentation site

Keep documentation sources in this repository. The [central documentation repository](https://github.com/modern-swift-dev/docs)
builds the Astro and DocC site daily and publishes it at
https://modern-swift-dev.github.io/docs/swift-snapshot-testing/.

After changing documentation or publishing a GitHub release, validate the site locally:

```sh
make website-install
make site-build
make site-check
```

Review the generated release information and DocC output under `.build/site/`, and commit only the
source changes. Generated HTML is ignored and is not committed to this module.

Preview the assembled site with:

```sh
make site-preview
```

Open the exact URL printed by the command. Do not open `.build/site/index.html` directly or serve
`.build/site/` at the URL root. The generated asset URLs include the `/docs/swift-snapshot-testing/`
prefix required by GitHub Pages. Pages deployment is configured in the central documentation repository.
