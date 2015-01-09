# dirty code

cron = require 'cron'

module.exports = (robot) ->
  robot.brain.autoSave = true
  robot.brain.data.job_table ||= []

  createWorker = (job) ->
    new cron.CronJob job.time, ->
      robot.send room: job.room, job.message
    , null, true, "Asia/Tokyo"

  job_table = []
  for job, index in robot.brain.data.job_table
    job_table[index] = job
    job_table[index].worker = createWorker job

  getJobs = ->
    job_table

  addJob = (job) ->
    robot.brain.data.job_table.push job
    job.worker = createWorker job
    job_table.push job

  deleteJob = (index) ->
    job_table[index]?.worker.stop()
    job_table.splice index, 1
    robot.brain.data.job_table.splice index, 1

  robot.hear /^alert list$/i, (msg) ->
    console.log robot.brain.data

    if getJobs().length == 0
      msg.send "empty jobs"

    for job, i in getJobs()
      msg.send "#{i} : #{job.room} - #{job.message}"

  robot.hear /^alert (add|make|set) ([^ ]+ [^ ]+ [^ ]+ [^ ]+ [^ ]+ [^ ]+) (.+)/i, (msg) ->
    addJob(room: msg.message.room, time: msg.match[2], message: msg.match[3])
    console.log msg.match
    msg.send "good job"

  robot.hear /^alert (del|rm|unset) ([0-9]+)$/i, (msg) ->
    deleteJob(msg.match[2])
    msg.send "job was deleted"
