import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://modern-swift-dev.github.io",
  base: "/swift-snapshot-testing",
  outDir: "../docs",
  build: { assets: "_assets" },
  vite: { plugins: [tailwindcss()] },
});
