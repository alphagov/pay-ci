#!/usr/bin/env node

const fs = require('fs')

async function run () {
  try {
    const dir = 'parse-perf-release-tag'
    if (!fs.existsSync(dir)){
      fs.mkdirSync(dir);
    }

    const tag = fs.readFileSync('ecr-repo/tag', 'utf8')
    fs.writeFileSync('parse-perf-release-tag/tag', tag.replace('release', 'perf'))

    console.log('Resulting tag: ' + fs.readFileSync('parse-perf-release-tag/tag', 'utf8'))
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()