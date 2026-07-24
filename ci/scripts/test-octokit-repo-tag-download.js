const { Octokit } = require('@octokit/rest')
const octokit = new Octokit()

async function run () {
  try {
    const refResult = await octokit.git.getRef({ owner: 'alphagov', repo: 'pay-ci', ref: 'tags/pactbroker_alpha_release-3' })
    console.log(`git sha: ${refResult.data.object.sha}`)
  } catch (err) {
    console.log(`An error occurred: ${err}`)
    process.exitCode = 1
  }
}

run()