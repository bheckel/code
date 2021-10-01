CREATE OR REPLACE EDITIONABLE FUNCTION check_perc_alert(entity VARCHAR2, prev_minutes NUMBER DEFAULT 5) RETURN NUMBER
IS
   l_http_request  UTL_HTTP.req;
   l_http_response UTL_HTTP.resp;
   response_text   VARCHAR2(300);
   endpoint        VARCHAR2(300);
   thisentity      VARCHAR2(100);
   cnt             NUMBER;
   db              VARCHAR2(6);
   pw              VARCHAR2(100);
 BEGIN
    thisentity := upper(entity);
    IF (thisentity = 'SDM_REVENUE') THEN
      thisentity := 'EDW_SDM_EXTRACT';
    END IF;
    IF (thisentity != 'EDW_SDM_EXTRACT') THEN
      RETURN 0;
    END IF;

    select LOWER(name) INTO db from V$database ;

    CASE db
       WHEN 'sd' THEN pw := 'mypw';
       WHEN 'st' THEN pw := 'mypw2';
       WHEN 'sp' THEN pw := 'mypw3';
    END CASE;

    FOR cnt IN 0 .. PREV_MINUTES LOOP
      -- generate the endpoint that is the url to be used in the REST call.
      endpoint := 'https://percapi.s.com/entities/' || thisentity || '/alerts/SDM/MISBIT_Monitor/clear/m/' || cnt;
       UTL_HTTP.set_wallet('file:/etc/ssl/certs/wlogin/' || db || 'wallet',pw);
       -- Make a HTTP request and get the response.
       l_http_request  := UTL_HTTP.begin_request(endpoint);
       UTL_HTTP.set_header(
          l_http_request,
          'Authorization',
          'Basic xyz123');
       l_http_response := UTL_HTTP.get_response(l_http_request);
       UTL_HTTP.read_text(l_http_response, response_text, 32766);
       utl_http.end_response(l_http_response);
       response_text := REPLACE(response_text, '"', '');
    END LOOP;

  RETURN 0;

EXCEPTION
  WHEN utl_http.request_failed THEN
    UTL_HTTP.END_RESPONSE(l_http_response);
    SELECT status INTO response_text FROM perc_alert_status WHERE entity='EDW_SDM_EXTRACT';
    IF (response_text = '1') THEN
       RETURN 1;
    END IF;
    RETURN 0;
  WHEN UTL_HTTP.TOO_MANY_REQUESTS THEN
    UTL_HTTP.END_RESPONSE(l_http_response);
    RETURN 0;
END check_perc_alert;
