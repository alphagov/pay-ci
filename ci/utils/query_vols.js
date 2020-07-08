const { exec } = require('child_process');

const showVols = 'fly -t pay-deploy vs -d --json';
const showContainers = 'fly -t pay-deploy cs --json';

async function executeCommand(command) {
  return new Promise((resolve, reject) => exec(command, (error, stdout, stderr) => {
    if (error) {
      return reject(`something went wrong: ${error}`);
    }

    if (stderr) {
      return reject(`stderr: ${stderr}`);
    }

    return resolve(stdout);
  }));
}

function summariseAttribute(list, attribute) {
  return list.reduce((result, item) => {
    const itemValue = item[attribute];
    if (result[itemValue]) {
      result[itemValue] += 1;
    } else {
      result[itemValue] = 1;
    }
    return result;
  }, {});
}

async function getVols() {
  return JSON.parse(await executeCommand(showVols))
    .filter((v) => v.worker_name === 'ip-10-1-31-241');
}

(async function run() {
  try {
    const vols = await getVols();
    const containers = JSON.parse(await executeCommand(showContainers));
    vols.forEach((vol) => {
      const container = containers.find((cont) => cont.id === vol.container_handle);

      if (container) {
        vol.container = container;
      }
    });

    const filteredVols = vols.filter((v) => v.container);
    console.log(filteredVols);
    console.log(`total filtered vols: ${filteredVols.length}`);
    console.log(summariseAttribute(filteredVols, 'path'));
    console.log(summariseAttribute(filteredVols, 'type'));
    console.log(summariseAttribute(filteredVols, 'job_name'));
  } catch (ex) {
    console.log(ex);
  }
}());
