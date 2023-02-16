// noinspection DuplicatedCode

const core = require('@actions/core')

// this script expects two values, they must be semantic versions conforming to the MAJOR.MINOR.PATCH convention
semVer: try {
  const packageVersion: string = core.getInput('package_version')
  const currentReleaseVersion: string = core.getInput('release_version')

  if (packageVersion === '' || currentReleaseVersion === '') {
    core.setFailed('input values cannot be empty')
    break semVer
  }

  const packageVersionParts: string[] = packageVersion.split(".")
  const currentReleaseVersionParts: string[] = currentReleaseVersion.split(".")

  if (arrayValuesAreNumbers([packageVersionParts, currentReleaseVersionParts])) {
    let parts: string []
    switch (compareSemver(packageVersion, currentReleaseVersion)) {
      case 0:
        //  0: versions are equal, patch package version
        parts = incrementPatchValue(packageVersionParts)
        break
      case 1:
        //  1: package version is greater than current release version, use package version
        parts = packageVersionParts
        break
      default:
        //  -1: current release version is greater than package version and all other cases, patch current release version
        parts = incrementPatchValue(currentReleaseVersionParts)
        break
    }
    const newReleaseVersion: string = parts.join('.')
    console.log(`New release version: ${newReleaseVersion}`)
    core.setOutput('version', newReleaseVersion)
  } else {
    core.setFailed(`input values must be semantic (MAJOR.MINOR.PATCH) [values provided: ${packageVersion}, ${currentReleaseVersion}]`)
  }
} catch (error: any) {
  core.setFailed(error.message)
}

function arrayValuesAreNumbers(arrays: string[][]): boolean {
  return arrays.every(arr => arr.every(element => !isNaN(Number(element))))
}

function compareSemver(a: string, b: string): number {
  return a.localeCompare(b, undefined, {numeric: true, sensitivity: 'base'})
}

function incrementPatchValue(parts: string[]): string[] {
  let patchValue = Number(parts[parts.length - 1]!)
  patchValue++
  parts[parts.length - 1] = patchValue.toString()
  return parts
}


