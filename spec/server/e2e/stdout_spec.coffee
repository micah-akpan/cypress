e2e      = require("../helpers/e2e")
Fixtures = require("../helpers/fixtures")

normalize = (stdout) ->
  ## remove all of the dynamic parts of stdout
  ## to normalize against what we expected
  stdout
  .replace(/\(\d{1,4}m?s\)/g, "(123ms)")
  .replace(/\(\d{1,2}s\)/g, "(10s)")
  .replace(/coffee-\d{3}/g, "coffee-456")
  .replace(/(.+)\.projects\/e2e\/does-not-exist\.html/, "/foo/bar/.projects/e2e/does-not-exist.html")
  .replace(/\/.+\/cypress\/videos\/(.+)\.mp4/g, "/foo/bar/.projects/e2e/cypress/videos/abc123.mp4")
  .replace(/\/.+\/cypress\/screenshots/g, "/foo/bar/.projects/e2e/cypress/screenshots")
  .replace(/Cypress Version\: (.+)/, "Cypress Version: 1.2.3")
  .replace(/Duration\: (.+)/, "Duration:        10 seconds")
  .replace(/\r/g, "")

describe "e2e stdout", ->
  e2e.setup()

  it "displays errors from failures", ->
    e2e.exec(@, {
      port: 2020
      spec: "stdout_failing_spec.coffee"
      expectedExitCode: 3
    })
    .get("stdout")
    .then (stdout) ->
      stdout = normalize(stdout)

      contents1 = Fixtures.get("server/expected_stdout_failures.txt")
      contents2 = Fixtures.get("server/expected_stdout_failures_outro.txt")

      expect(stdout).to.include(contents1)
      expect(stdout).to.include(contents2)
      expect(stdout).to.include("3) stdout_failing_spec passing hook is failing:")

  it "does not duplicate suites or tests between visits", ->
    e2e.exec(@, {
      spec: "stdout_passing_spec.coffee"
      timeout: 60000
      expectedExitCode: 0
    })
    .get("stdout")
    .then (stdout) ->
      stdout = normalize(stdout)

      contents = Fixtures.get("server/expected_stdout_passing.txt")

      expect(stdout).to.include(contents)