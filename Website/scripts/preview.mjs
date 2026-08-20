import { createReadStream, existsSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, resolve, sep } from "node:path";

const siteRoot = resolve(process.argv[2] ?? "../docs");
const basePath = "/swift-snapshot-testing";
const startingPort = Number.parseInt(process.env.PORT ?? "4321", 10);

if (!existsSync(resolve(siteRoot, "index.html"))) {
  throw new Error(`No generated site found at ${siteRoot}. Run make site-build first.`);
}

const contentTypes = new Map([
  [".css", "text/css; charset=utf-8"],
  [".gif", "image/gif"],
  [".html", "text/html; charset=utf-8"],
  [".ico", "image/x-icon"],
  [".jpeg", "image/jpeg"],
  [".jpg", "image/jpeg"],
  [".js", "text/javascript; charset=utf-8"],
  [".json", "application/json; charset=utf-8"],
  [".png", "image/png"],
  [".svg", "image/svg+xml"],
  [".txt", "text/plain; charset=utf-8"],
  [".webp", "image/webp"],
]);

function fileForRequest(requestPath) {
  if (!requestPath.startsWith(`${basePath}/`)) return undefined;

  const relativePath = decodeURIComponent(requestPath.slice(basePath.length + 1));
  let file = resolve(siteRoot, relativePath);
  if (file !== siteRoot && !file.startsWith(`${siteRoot}${sep}`)) return undefined;
  if (existsSync(file) && statSync(file).isDirectory()) file = resolve(file, "index.html");
  return existsSync(file) && statSync(file).isFile() ? file : undefined;
}

const server = createServer((request, response) => {
  const url = new URL(request.url ?? "/", "http://localhost");
  if (url.pathname === "/" || url.pathname === basePath) {
    response.writeHead(302, { Location: `${basePath}/` });
    response.end();
    return;
  }

  let file;
  try {
    file = fileForRequest(url.pathname);
  } catch {
    file = undefined;
  }

  if (!file) {
    response.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    response.end("Not found\n");
    return;
  }

  response.writeHead(200, {
    "Content-Type": contentTypes.get(extname(file).toLowerCase()) ?? "application/octet-stream",
  });
  if (request.method === "HEAD") response.end();
  else createReadStream(file).pipe(response);
});

function listen(port) {
  function onError(error) {
    server.off("listening", onListening);
    if (error.code === "EADDRINUSE" && port < startingPort + 10) listen(port + 1);
    else throw error;
  }

  function onListening() {
    server.off("error", onError);
    console.log(`Preview: http://localhost:${port}${basePath}/`);
  }

  server.once("error", onError);
  server.once("listening", onListening);
  server.listen(port, "127.0.0.1");
}

listen(startingPort);
