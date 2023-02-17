### Next Semver Action

A GitHub Action that, given two possible version values, determines the next [semantic release version](https://semver.org/)

#### Updating this action

This action uses `ncc` to compile the module to a single `.js` file. 

When making changes to the source you must also run the following and ensure the output `dist` directory is checked in as part of the change.

```bash
npm run compile
```
