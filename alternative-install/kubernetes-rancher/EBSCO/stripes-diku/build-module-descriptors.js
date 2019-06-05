const fs = require('fs');
const childProcess = require('child_process');

const argv0 = process.argv[1];
const outdir = 'ModuleDescriptors';
let strict = false;
if (process.argv[2] === '--strict') {
  strict = true;
}

console.log('* build-module-descriptors');
if (!fs.existsSync(outdir)) {
  fs.mkdirSync(outdir);
}

// Use stripes-cli to obtain module descriptors
const cmd = `./node_modules/.bin/stripes mod descriptor stripes.config.js --full${strict ? ' --strict' : ''}`;
let descriptors = [];
try {
  const output = childProcess.execSync(cmd, { encoding: 'utf8' }).trim();
  descriptors = JSON.parse(output);
} catch (exception) {
  console.log(`${argv0}: cannot run '${cmd}':`, exception);
  process.exit(2);
}

// Write descriptors to individual files
descriptors.forEach(descriptor => {
  // Regex to find a name like "plugin-find-user" inside of an id like "folio_plugin-find-user-1.4.100038"
  const nameMatch = descriptor.id.match(/folio_(.*)-/);
  const filename = nameMatch ? nameMatch[1] : descriptor.id;
  console.log(`processing '${filename}'`);
  const formattedJson = JSON.stringify(descriptor, null, 2);
  fs.writeFileSync(`${outdir}/${filename}.json`, `${formattedJson}\n`, { encoding: 'utf8' });
});
