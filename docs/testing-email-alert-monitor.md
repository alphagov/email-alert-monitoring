# Testing the Email Alert Monitor

0. GOVUK Infrastructure have access to the relevant Google inboxes, the
   Production Jenkins instance where the monitor is run from, and Icinga. All
   three are required to test the monitor is working. Find someone from
   Infrastructure before proceeding!
0. In the inbox for whichever alert type you're checking, delete an email that
   was received during the inspection period. At time of writing, the monitor
   inspects all emails received from 2 days ago to 1 hour ago.
0. In Jenkins, run the EmailAlertCheck task. This should fail and output an
   error message reporting the absence of the deleted email.
0. Check the alert is triggered correctly in Icinga.
0. The 2nd Line Slack channel should receive PagerDuty alerts.
0. Back in the inbox, restore the email from trash.
0. Run the Jenkins job again.
0. Everything should be green.
