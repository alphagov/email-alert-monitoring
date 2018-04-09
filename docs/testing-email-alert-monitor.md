# Testing the Email Alert Monitor

1. In the inbox for whichever alert type you're checking, delete an
   email that was received during the inspection period. The monitor
   inspects all emails received from 2 days ago to 1 hour ago.
   The credentials for the email account are in the 2nd line pass store.
2. In Jenkins on production, run the `EmailAlertCheck` task. This should
   fail and output an error message reporting the absence of the deleted
   email.
3. Check the alert is triggered correctly in Icinga.
4. The 2nd line Slack channel should receive PagerDuty alerts.
5. Back in the inbox, restore the email from trash.
6. Run the Jenkins job again.
7. Everything should be green.
