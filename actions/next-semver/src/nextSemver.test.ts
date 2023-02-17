const core = require('@actions/core')
const { nextSemver, arrayValuesAreNumbers, incrementPatchValue, compareSemver, errorMessages } = require('./nextSemver.ts')

// @ts-ignore
global.console = {
  log: jest.fn(),
  debug: console.debug,
  trace: console.trace
}

describe('the action should', () => {
  beforeEach(() => {
    core.setOutput = jest.fn()
    core.setFailed = jest.fn()
  })
  afterEach(() => {
    core.setOutput.mockRestore()
    core.setFailed.mockRestore()
  })
  it.each([
    ['1.2.3', '4.5.6', '4.5.7'],
    ['2.2.2', '2.2.2', '2.2.3'],
    ['4.4.4', '3.3.3', '4.4.4']
  ])('given package version %p and current release version %p return version %p', (packageVersion: string, currentReleaseVersion: string, result :string) => {
    nextSemver(packageVersion, currentReleaseVersion)
    expect(core.setOutput).toHaveBeenCalledWith('version', result)
  })
  it('handle empty inputs', () => {
    nextSemver('', '')
    expect(core.setFailed).toHaveBeenCalledWith(errorMessages.empty)
  })
  it('handle malformed inputs', () => {
    nextSemver('1.2.3', '1.2.3-alpha')
    expect(core.setFailed).toHaveBeenCalledWith(errorMessages.malformed)
  })
})

describe('the arrayValuesAreNumbers function should', () => {
  it.each([
    [['1', '2', '3'], ['4', '5', '6'], true],
    [['1', 'two', '3'], ['4', '5', '6'], false],
    [['1', '2', '3'], ['4', '5', '6-alpha'], false]
  ])('given %p %p return %p', (a: string[], b: string[], result: boolean) => {
    expect(arrayValuesAreNumbers([a, b])).toBe(result)
  })
})

describe('the incrementPatchValue function should', () => {
  it.each([
    [['1', '2', '3'], ['1', '2', '4']],
    [['4', '5', '6'], ['4', '5', '7']],
    [['0', '1', '2'], ['0', '1', '3']],
    [['0', '0', '0'], ['0', '0', '1']],
    [['1', '2', '10'], ['1', '2', '11']],
    [['11', '12', '0'], ['11', '12', '1']],
    [['12', '13'], ['12', '14']],
    [['13'], ['14']]
  ])('given %p return %p', (a: string[], result: string[]) => {
    expect(incrementPatchValue(a)).toEqual(result)
  })
})

describe('the compareSemver function should', () => {
  it.each([
    ['0.0.0', '0.0.0', 0],
    ['0.0.1', '0.0.1', 0],
    ['1.0.1', '1.0.1', 0],
    ['1.1.0', '1.1.0', 0],
    ['1.1.1', '1.1.1', 0],
    ['22.22.22', '22.22.22', 0],
    ['123.456.789', '123.456.789', 0],
    ['0.0.1', '0.0.0', 1],
    ['0.1.0', '0.0.2', 1],
    ['1.0.1', '0.2.1', 1],
    ['2.0.0', '1.3.0', 1],
    ['11.12.13', '11.12.12', 1],
    ['456.123.789', '123.456.789', 1],
    ['0.0.0', '0.0.1', -1],
    ['0.0.2', '0.1.0', -1],
    ['0.2.1', '1.0.1', -1],
    ['1.3.0', '2.0.0', -1],
    ['11.12.12', '11.12.13', -1],
    ['123.456.789', '123.789.456', -1],
  ])('compare %p to %p and return %p', (a: string, b: string, result: number) => {
    expect(compareSemver(a, b)).toEqual(result)
  })
})
