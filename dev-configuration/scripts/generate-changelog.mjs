import fs from "fs";
import { fileURLToPath } from "url";
import path from "path";
import conventionalChangelog from "conventional-changelog";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const changelogPath = path.join(__dirname, "..", "CHANGELOG.md");
const output = fs.createWriteStream(changelogPath);

conventionalChangelog(
  {
    config: await import("../conventional-changelog-config.js").then(m => m.default || m),
    releaseCount: 0
  },
  null,
  null,
  null,
  null
).pipe(output);
