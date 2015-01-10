# dirty code

cron = require 'cron'

module.exports = (robot) ->
  robot.brain.autoSave = true
  robot.brain.data.job_table ||= []

  createWorker = (job) ->
    new cron.CronJob job.time, ->
      robot.send room: job.room, job.message
    , null, true, "Asia/Tokyo"

  cloneJob = (job) ->
    {time: job.time, room: job.room, message: job.message}

  addJob = (job) ->
    job.worker = createWorker job
    job_table.push job
    robot.brain.data.job_table.push cloneJob job

  deleteJob = (index) ->
    job_table[index]?.worker.stop()
    job_table.splice index, 1
    robot.brain.data.job_table.splice index, 1

  job_table = []
  initializeCron = ->
    for job, index in robot.brain.data.job_table
      job_table[index] = cloneJob job
      job_table[index].worker = createWorker job

  setTimeout(initializeCron, 1000 * 10);

  robot.hear /^alert help$/i, (msg) ->
    msg.send """
    alert list
    alert add <second> <minute> <hour> <day> <month> <week> <message>
    alert rm <alert id>
    """

  robot.hear /^alert list$/i, (msg) ->
    console.log robot.brain.data

    if job_table.length == 0
      msg.send "empty jobs"
    else
      msg.send "no : room : time : message"
      for job, i in job_table
        msg.send "#{i} : ##{job.room} : #{job.time} : #{job.message}"

  robot.hear /^alert (add|make|set) ([^ ]+ [^ ]+ [^ ]+ [^ ]+ [^ ]+ [^ ]+) (.+)/i, (msg) ->
    addJob(room: msg.message.room, time: msg.match[2], message: msg.match[3])
    console.log msg.match
    msg.send "good job"

  robot.hear /^alert (del|remove|rm|unset) ([0-9]+)$/i, (msg) ->
    deleteJob(msg.match[2])
    msg.send "job was deleted"
