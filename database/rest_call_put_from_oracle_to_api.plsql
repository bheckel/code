
DECLARE
  l_http_request    UTL_HTTP.req;
  l_http_response   UTL_HTTP.resp;
  l_buffer_size     CONSTANT NUMBER := 3500;
  l_return_val      VARCHAR2(3500);
  l_response_status NUMBER := 0;
BEGIN
    REST.set_logging_on;
  BEGIN
    l_http_request := REST.start_http_request(p_rest_endpoint        => 'http://' || REST.getHostBasedOnDatabase() || '/rest/hub/update/accounts',
                                              p_http_method          => 'PUT',
                                              p_api_client           => 'Oracle',
                                              p_remote_user          => 'arynt\sppt',
                                              p_query_param          => NULL,
                                              p_request_content      => '{"accountId": 99999999, "HubAccountAction": "DELETE"}',
                                              p_request_content_type => 'application/json',
                                              p_request_accept_type  => 'application/json',
                                              p_rest_version         => 'EDGE');
    l_http_response   := UTL_HTTP.get_response(r => l_http_request);
    l_response_status := l_http_response.status_code;
    --REST.log_msg('DTO: ' || p_request_content);
    REST.log_msg('HTTP Response Code: ' || l_response_status);
    l_return_val := '<ERROR>ORION REST Service Response: ' || l_response_status || ' </ERROR>';
    IF (l_response_status <> utl_http.http_accepted OR
       l_response_status <> utl_http.http_no_content) THEN
      UTL_HTTP.read_text(l_http_response, l_return_val, l_buffer_size);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Must be null otherwise: ORA-29266: end-of-body reached: ORA-06512: at "SYS.UTL_HTTP", line 837
      NULL;
  END;

  IF l_http_request.private_hndl IS NOT NULL THEN
    UTL_HTTP.end_request(l_http_request);
  END IF;

  IF l_http_response.private_hndl IS NOT NULL THEN
    UTL_HTTP.end_response(l_http_response);
  END IF;

  REST.log_msg('RAW HTTP Response: ' || l_return_val);
  REST.set_logging_off;
END;
