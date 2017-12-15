-- Assumes we're using SANDBOX on wnetbpms1
SELECT * INTO va_prov_test
FROM bpms..t_ref_bpms_prescriber_info 
WHERE plancode = 'va' 

SELECT * FROM sandbox.rheckel.va_prov_test
