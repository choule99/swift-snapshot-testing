import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://modern-swift-dev.github.io",
  base: "/docs/swift-snapshot-testing",
  outDir: "../.build/site",
  build: { assets: "_assets" },
  vite: { plugins: [tailwindcss()] },
});
