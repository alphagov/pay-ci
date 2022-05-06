#!/usr/bin/env node

const fs = require('fs')

async function run () {
  try {
    const dir = 'parse-perf-db-release-tag'
    if (!fs.existsSync(dir)){
      fs.mkdirSync(dir);
    }

    const tag = fs.readFileSync('ecr-repo/tag', 'utf8')
    fs.writeFileSync(`${dir}/tag`, tag.replace('release', 'perf-db'))

    console.log('Resulting tag: ' + fs.readFileSync(`${dir}/tag`, 'utf8'))
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()