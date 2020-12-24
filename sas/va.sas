 /* Calculate Age */
Floor(( ( TreatAs(_Number_, DatePart(Now())) - TreatAs(_Number_, 'Birth Date'n) ) / 365.25 ))


IF ( ( 'Geo3'n In ('Education', 'Education Division') ) AND (
'Fcst USD'n >= 50000 ) )
RETURN 100000
ELSE (
IF ( ( 'Geo3'n In ('Government') ) AND ( 'Fcst USD'n >= 75000 ) )
RETURN 100000
ELSE 'Fcst USD'n )
