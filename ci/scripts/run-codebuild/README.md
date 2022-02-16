# Run Codebuild

This script executes a CodeBuild build, allowing override of the source (and secondary source) versions, as well as the environment variables of the build. It will execute the build and then retrieve the logs from CloudWatch and print them to stdout.

This script expects to be run with an environment variable `PATH_TO_CONFIG` set which specifies a path relative (or an absolute path) to the `run-codebuild.js` script. This config defines which codebuild project to run and what params to pass.

## Environment Variables

variable | description
---|---
PATH\_TO\_CONFIG | A path (absolute, or relative to the run-codebuild.js script) to the JSON config file

## Config

Simple example config
```
{
    "projectName": "codebuild-e2e-spike-test-12",
    "sourceVersion": "123456",
    "secondarySourcesVersions": {
      "pay_frontend": "654321",
      "pay_foobar": "987654"
      
    },
    "environmentVariables": {
        "PAY_FRONTEND_RELEASE": "1734-release",
        "END_TO_END_TEST_SUITE": "products"
    }
}
```

The fields in this are:

field | description
---|----
projectName | The AWS CodeBuild project name to run
sourceVersion | The source version for the primary source of the CodeBuild project
secondarySourcesVersions | A map with keys for the secondary source names and values as the versions to use for those sources
environmentVariables | A map of with keys as environment variable names to set and values as the values of those environment variables
