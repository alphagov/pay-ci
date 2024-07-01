const { WebClient } = require('@slack/web-api')

async function setSlackChannelTopic (channelId, newTopic) {
  const web = new WebClient(process.env.SLACK_SECRET)
  try {
    const response = await web.conversations.setTopic({
      channel: channelId,
      topic: newTopic
    });

    if (response.ok) {
      console.log('Channel topic updated successfully.');
    } else {
      console.error(`Error: ${response.error}`);
      process.exit(1)
    }
  } catch (error) {
    console.error(`Error setting slack channel topic: ${error.message}`);
    process.exit(1)
  }
}

module.exports = {
  setSlackChannelTopic
}
