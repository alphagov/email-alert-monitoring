#!/usr/bin/env groovy

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'
  try {
    stage("Checkout") {
      checkout(scm)
    }

    stage("Clean up workspace") {
      govuk.cleanupGit()
    }

    stage("Merge master") {
      govuk.mergeMasterBranch()
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("Lint Ruby") {
      govuk.rubyLinter("app lib spec test")
    }

    stage("Run tests") {
      govuk.runTests()
    }
  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
