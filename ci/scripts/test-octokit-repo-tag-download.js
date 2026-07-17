#!/usr/bin/env node

const fs = require('fs')
const { Octokit } = require('@octokit/rest')
const { GITHUB_TOKEN: githubToken } = process.env
const octokit = new Octokit({ auth: githubToken })

async function run () {
  try {
    const refResult = await octokit.git.getRef({ owner: 'alphagov', repo: 'pay-ci', ref: 'tags/pactbroker_alpha_release-3' })
    const tagSha = refResult.data.object.sha
    const tagResult = await octokit.git.getTag({ owner: 'alphagov', repo: 'pay-ci', tag_sha: `${tagSha}` })
    console.log(`git sha: ${tagResult.data.object.sha}`)
    fs.writeFileSync('git-sha/git-sha', tagResult.data.object.sha)
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()