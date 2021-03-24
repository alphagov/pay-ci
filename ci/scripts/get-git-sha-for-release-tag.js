#!/usr/bin/env node

const fs = require('fs')
const { Octokit } = require('@octokit/rest')
const octokit = new Octokit()
const { APPLICATION_IMAGE_TAG: imageTag, APP_NAME: appName } = process.env

async function run () {
  try {
    const gitTag = `alpha_release-${imageTag}`.replace('-release', '')
    const refResult = await octokit.git.getRef({ owner: 'alphagov', repo: `pay-${appName}`, ref: `tags/${gitTag}` })
    const tagSha = refResult.data.object.sha
    const tagResult = await octokit.git.getTag({ owner: 'alphagov', repo: `pay-${appName}`, tag_sha: `${tagSha}` })
    console.log(`git sha: ${tagResult.data.object.sha}`)
    fs.writeFileSync('git-sha/git-sha', tagResult.data.object.sha)
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()
