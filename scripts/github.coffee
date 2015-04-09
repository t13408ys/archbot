github = new (require 'github')
  version: '3.0.0'
github.authenticate type: 'token', token: process.env['GITHUB_API_TOKEN']

module.exports = (robot) ->
  robot.hear /^issue\s+(.+)$/, (msg) ->
    title = msg.match[1]

    github.issues.create
      user: 'sfc-arch'
      repo: 'documents'
      title: title
      labels: []
