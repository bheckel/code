
-- Using the relational tables
declare @num varchar(30)
select @num = '00074611411'

use sandbox
select a.brand_description
from SEDNEY.NDC_BRAND_NAME a join SEDNEY.NDC_CORE_DESCRIPTION b on a.brand_code=b.brand_code
where b.ndc_code=@num

select y.active_ingredient
from SEDNEY.NDC_ACTIVE_INGREDIENT_LIST x join SEDNEY.NDC_ACTIVE_INGREDIENT y on x.active_ingredient_code=y.active_ingredient_code 
     and x.main_multum_drug_code=(select a.main_multum_drug_code
                                  from SEDNEY.NDC_CORE_DESCRIPTION a join SEDNEY.NDC_BRAND_NAME b on a.brand_code=b.brand_code
                                  where a.ndc_code=@num)



-- Or using the denormalized table
use sandbox
select distinct *
from ndc_denorm 
where ndc_code='00074611411'
