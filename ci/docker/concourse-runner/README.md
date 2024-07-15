# Pay Concourse Runner

This Docker image is used as an environment to build and run pretty much everything
except for node scripts (for that we use the node-runner) -
for example pact tests, parts of the PR-ci pipeline, smoke tests, parts of the codebuild-e2e stuff,
java integration tests etc.

See the Dockerfile for the list of things it downloads.
