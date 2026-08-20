import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { resolve } from "node:path";

const siteRoot = resolve(process.argv[2] ?? "../docs");
const basePath = "/swift-snapshot-testing/";

function filesBelow(directory) {
  return readdirSync(directory).flatMap((name) => {
    const path = resolve(directory, name);
    return statSync(path).isDirectory() ? filesBelow(path) : [path];
  });
}

function targetExists(pathname) {
  const relativePath = decodeURIComponent(pathname.slice(basePath.length));
  const target = resolve(siteRoot, relativePath);
  if (existsSync(target) && !statSync(target).isDirectory()) return true;
  return existsSync(resolve(target, "index.html"));
}

const failures = [];
for (const file of filesBelow(siteRoot).filter((path) => path.endsWith(".html"))) {
  const route = `${basePath}${file.slice(siteRoot.length + 1).replace(/index\.html$/, "")}`;
  const html = readFileSync(file, "utf8");
  for (const match of html.matchAll(/\b(?:href|src)=["']([^"']+)["']/g)) {
    const value = match[1];
    if (/^(?:#|data:|mailto:|tel:|javascript:)/.test(value)) continue;

    const url = new URL(value, `https://modern-swift-dev.github.io${route}`);
    if (url.origin !== "https://modern-swift-dev.github.io" || !url.pathname.startsWith(basePath)) {
      continue;
    }
    if (!targetExists(url.pathname)) failures.push(`${file}: ${value}`);
  }
}

if (failures.length > 0) {
  console.error(`Found ${failures.length} broken internal link${failures.length === 1 ? "" : "s"}:`);
  console.error(failures.join("\n"));
  process.exitCode = 1;
} else {
  console.log("All generated internal links resolve.");
}
