-- ----------------------------------------------------------------------------
-- Author: Bob Heckel
-- Date:   18JAN19
-- Usage:  Make the SPAM stop
-- JIRA:   ROION-34823
-- ----------------------------------------------------------------------------
DECLARE
  l_defect_num  VARCHAR2(50);
  l_release_num VARCHAR2(50);
  l_description VARCHAR2(4000);
  cnt           PLS_INTEGER;

BEGIN
  l_defect_num  := 'ROION-34823';
  l_release_num := '3.52';
  l_description := 'Make the SPAM stop';
   
  select count(1)
    into cnt
    from user_tables t
   where t.TABLE_NAME = 'EMAIL_MESSAGES';

  if cnt = 0 then
  
     EXECUTE IMMEDIATE 'CREATE SEQUENCE UID_EMAIL_MESSAGES MINVALUE 1 MAXVALUE 999999999999999999999999999 START WITH 1 INCREMENT BY 1';
     
     EXECUTE IMMEDIATE 'CREATE TABLE EMAIL_MESSAGES(
       EMAIL_MESSAGES_ID  NUMBER,
       SUBJECT            VARCHAR2(400),
       MSGBODY            VARCHAR2(4000),
       SCORE              NUMBER,
       PRIORITY           NUMBER,
       CREATED            DATE,
       CREATEDBY          NUMBER,
       UPDATED            DATE,
       UPDATEDBY          NUMBER,
       H_VERSION          NUMBER DEFAULT 0,
       ACTUAL_UPDATED     TIMESTAMP(6),
       ACTUAL_UPDATEDBY   NUMBER,
       RETIRED_TIME       TIMESTAMP(6),
       AUDIT_SOURCE       VARCHAR2(255) )';
       
     EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX EMAIL_MESSAGES_EMAIL_MESSAG_IX ON EMAIL_MESSAGES(EMAIL_MESSAGES_ID)';
     EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX EMAIL_MESSAGES_SUBJECT_IX ON EMAIL_MESSAGES(SUBJECT)';
     EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX EMAIL_MESSAGES_MSG_IX ON EMAIL_MESSAGES(MSGBODY)';

     EXECUTE IMMEDIATE 'ALTER TABLE EMAIL_MESSAGES ADD CONSTRAINT NN_EMAIL_MESSAGES_ID CHECK ("EMAIL_MESSAGES_ID" IS NOT NULL)';
     EXECUTE IMMEDIATE 'ALTER TABLE EMAIL_MESSAGES ADD CONSTRAINT NN_EMAIL_MESSAGES_CREATEDBY CHECK ("CREATEDBY" IS NOT NULL)';
     EXECUTE IMMEDIATE 'ALTER TABLE EMAIL_MESSAGES ADD CONSTRAINT NN_EMAIL_MESSAGES_CREATED CHECK ("CREATED" IS NOT NULL)';
     EXECUTE IMMEDIATE 'ALTER TABLE EMAIL_MESSAGES ADD CONSTRAINT NN_EMAIL_MESSAGES_HVER CHECK ("H_VERSION" IS NOT NULL)';

     EXECUTE IMMEDIATE 'ALTER TABLE EMAIL_MESSAGES ADD CONSTRAINT EMAIL_MESSAGES_PK PRIMARY KEY (EMAIL_MESSAGES_ID)';

     SETARS_HISTORY.create_hist_table('EMAIL_MESSAGES');
     MAINT.SET_SEQUENCE('EMAIL_MESSAGES');

  end if;
  
   MAINT.logdatachange(
      step      => 0,
      status    => l_description,
      release   => l_release_num,
      defect    => l_defect_num,
      startTime => SYSDATE);

END;
/
PROMPT ======== INCL === Executing e_mail_message.prc...
@/../e_mail_message.prc
