#!/usr/bin/env node

const fs = require('fs')

async function run () {
  try {
    const dir = 'parse-perf-release-tag'
    if (!fs.existsSync(dir)){
      fs.mkdirSync(dir);
    }

    const tag = fs.readFileSync('ecr-repo/tag', 'utf8')
    const perfTag = tag.replace('release', 'perf')

    console.log(`BUILD_JOB_NAME: ` + process.env.BUILD_JOB_NAME)
    if (process.env.AWS_ROLE_ARN.includes('db-migration-prod')) {
      fs.writeFileSync('parse-perf-release-tag/tag', perfTag + '-db')
    } else {
      fs.writeFileSync('parse-perf-release-tag/tag',  perfTag)
    }

    console.log('Resulting tag: ' + fs.readFileSync('parse-perf-release-tag/tag', 'utf8'))
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()