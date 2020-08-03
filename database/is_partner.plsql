FUNCTION is_partner(in_from_account NUMBER) RETURN BOOLEAN IS
	v_count NUMBER;
BEGIN
	select count(salesgroup)
		INTO v_count
		from account_base ab
	 where ab.account_id = in_from_account
		 and ab.partner = 1;

	RETURN(v_count = 1);
END;
