export interface Release {
  tag: string;
  version: string;
  publishedAt: string;
  date: string;
  url: string;
}

const endpoint =
  "https://api.github.com/repos/modern-swift-dev/swift-snapshot-testing/releases/latest";

let cachedRelease: Promise<Release> | undefined;

function isRelease(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

async function fetchLatestRelease(): Promise<Release> {
  const headers: Record<string, string> = { Accept: "application/vnd.github+json" };
  const token = import.meta.env.GITHUB_TOKEN;
  if (token) headers.Authorization = `Bearer ${token}`;

  const response = await fetch(endpoint, {
    headers,
  });

  if (!response.ok) {
    throw new Error(`Could not fetch the latest GitHub release: ${response.status} ${response.statusText}`);
  }

  const payload: unknown = await response.json();
  if (!isRelease(payload)) throw new Error("GitHub returned an invalid release payload.");
  const { tag_name, published_at, html_url, draft, prerelease } = payload;
  if (
    typeof tag_name !== "string" ||
    !/^v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/.test(tag_name) ||
    typeof published_at !== "string" ||
    Number.isNaN(Date.parse(published_at)) ||
    typeof html_url !== "string" ||
    !html_url.startsWith("https://github.com/modern-swift-dev/swift-snapshot-testing/releases/") ||
    draft !== false ||
    prerelease !== false
  ) {
    throw new Error("GitHub returned a release that is missing required published-release fields.");
  }

  const version = tag_name.replace(/^v/, "");
  return {
    tag: tag_name,
    version,
    publishedAt: published_at,
    date: new Intl.DateTimeFormat("en", { dateStyle: "long", timeZone: "UTC" }).format(
      new Date(published_at),
    ),
    url: html_url,
  };
}

export function latestRelease(): Promise<Release> {
  cachedRelease ??= fetchLatestRelease();
  return cachedRelease;
}
