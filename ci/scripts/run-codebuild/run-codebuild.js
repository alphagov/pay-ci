#!/usr/bin/env node

import { run } from './libs/executor.js'

process.on('unhandledRejection', error => {
  console.log('unhandledRejection', error.message)
  process.exit(1)
})

run()
