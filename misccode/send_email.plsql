PROCEDURE send_email_message(p_subject IN VARCHAR2, p_message VARCHAR2)
	IS
	C_JIRA_ID CONSTANT VARCHAR2(20) := 'ORION-26403';
	BEGIN
			 e_mail_message(
					 from_name => 'replies-disabled@as.com',
					 to_name   => 'r.syl@as.com',
					 cc_name   => NULL,
					 subject   => C_JIRA_ID ||' - '|| p_subject,
					 message   => p_message);   
END send_email_message;

send_email_message('ERROR',SQLCODE||'-'||SQLERRM||' - '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
