#!/usr/bin/env node

const fs = require('fs')
const sidecars = ['egress','stunnel','carbon-relay']

async function run () {
  try {
    const dir = 'parse-perf-release-tag'
    if (!fs.existsSync(dir)){
      fs.mkdirSync(dir);
    }

    const tag = fs.readFileSync('ecr-repo/tag', 'utf8')
    const releaseNum = tag.split('-')[0]
    const maybeSidecar = tag.split('-')[1]
    if (sidecars.includes(maybeSidecar)) {
      fs.writeFileSync('parse-perf-release-tag/tag', `${releaseNum}-${maybeSidecar}-perf`)
    } else {
      fs.writeFileSync('parse-perf-release-tag/tag', `${releaseNum}-perf`)
    }
    console.log('Contents of parse-perf-release-tag/tag: ' + fs.readFileSync('parse-perf-release-tag/tag', 'utf8'))
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()