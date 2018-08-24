-- pause execution for 60 seconds 
SELECT sysdate INTO l_now FROM DUAL;
LOOP
	EXIT WHEN l_now +(60 * (1 / 86400)) = sysdate;
END LOOP;
