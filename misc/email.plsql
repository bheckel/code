
PROCEDURE do2 IS
  l_mail_conn UTL_SMTP.connection;

BEGIN
      l_mail_conn := start_e_mail_message('replies-disabled@ss.com',
                                          'bob@ss.com',
                                          'Error in DDL_LOGGING_TRIG trigger on ' || SYS_CONTEXT('USERENV', 'DB_NAME'),
                                          'Unexpected error: ' || SQLCODE || ', ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || CHR(13) || CHR(10)
                                          );
  UTL_SMTP.close_data(l_mail_conn);
  UTL_SMTP.quit(l_mail_conn);
END;
