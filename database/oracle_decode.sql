SELECT DECODE(b.developer,
							1,
							1,
							DECODE(b.imitate_user,
										 1,
										 1,
										 CASE
											 WHEN b.administrator >= ADMIN_LEVEL_HELPDESK then
												1
											 else
												0
										 end))
	into canImitate
	FROM EMPLOYEE_BASE b
 where b.employee_id = imitatorId;

---

DECODE(checkmefield, ifcheckmeisthis, thenuseme, elseuseme)
DECODE(checkmefield, ifcheckmeisthis, thenuseme, [more pairs], elsenomatchuseme)

SELECT symbol, DECODE(earnings, 0, NULL, price / earnings)
