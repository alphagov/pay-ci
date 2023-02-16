const core = require('@actions/core')
const { determineVersion, arrayValuesAreNumbers, incrementPatchValue, compareSemver, errorMessages } = require('./index.ts')

// @ts-ignore
global.console = {
  log: jest.fn(),
  debug: console.debug,
  trace: console.trace
}

describe('determineVersion should', () => {
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
    determineVersion(packageVersion, currentReleaseVersion)
    expect(core.setOutput).toHaveBeenCalledWith('version', result)
  })
  it('handle empty inputs', () => {
    determineVersion('', '')
    expect(core.setFailed).toHaveBeenCalledWith(errorMessages.empty)
  })
  it('handle malformed inputs', () => {
    determineVersion('1.2.3', '1.2.3-alpha')
    expect(core.setFailed).toHaveBeenCalledWith(errorMessages.malformed)
  })
})

describe('arrayValuesAreNumbers should detect non-numeric strings', () => {
  it.each([
    [['1', '2', '3'], ['4', '5', '6'], true],
    [['1', 'two', '3'], ['4', '5', '6'], false],
    [['1', '2', '3'], ['4', '5', '6-alpha'], false]
  ])('given %p %p returns %p', (a: string[], b: string[], result: boolean) => {
    expect(arrayValuesAreNumbers([a, b])).toBe(result)
  })
})

describe('incrementPatchValue should increment the patch value of a split version by 1', () => {
  it.each([
    [['1', '2', '3'], ['1', '2', '4']],
    [['4', '5', '6'], ['4', '5', '7']],
    [['0', '1', '2'], ['0', '1', '3']],
    [['0', '0', '0'], ['0', '0', '1']],
    [['1', '2', '10'], ['1', '2', '11']],
    [['11', '12', '0'], ['11', '12', '1']],
    [['12', '13'], ['12', '14']],
    [['13'], ['14']]
  ])('given %p returns %p', (a: string[], result: string[]) => {
    expect(incrementPatchValue(a)).toStrictEqual(result)
  })
})

describe('compareSemver should return 0 when equal, 1 when first arg is greater and -1 when second arg is greater', () => {
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
    ['123.456.789', '456.123.789', -1],
  ])('comparing %p to %p returns %p', (a: string, b: string, result: number) => {
    expect(compareSemver(a, b)).toEqual(result)
  })
})
