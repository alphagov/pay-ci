// noinspection DuplicatedCode
// this script expects two values, they must be semantic versions conforming to the MAJOR.MINOR.PATCH convention
export {}
const core = require('@actions/core')
const { nextSemver } = require('./nextSemver')
const packageVersion: string = core.getInput('package_version')
const currentReleaseVersion: string = core.getInput('release_version')

nextSemver(packageVersion, currentReleaseVersion)
