const core = require('@actions/core')

const errorMessages = {
  empty: 'input values cannot be empty',
  malformed: 'input values must be semantic (MAJOR.MINOR.PATCH)'
}

function nextSemver (packageVersion: string, currentReleaseVersion: string) :void {
  semVer: try {
    if (packageVersion === '' || currentReleaseVersion === '') {
      core.setFailed(errorMessages.empty)
      break semVer
    }

    const packageVersionParts: string[] = packageVersion.split('.')
    const currentReleaseVersionParts: string[] = currentReleaseVersion.split('.')

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
      core.setFailed(errorMessages.malformed)
    }
  } catch (error: any) {
    core.setFailed(error.message)
  }
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

export {
  nextSemver,
  arrayValuesAreNumbers,
  compareSemver,
  incrementPatchValue,
  errorMessages
}
