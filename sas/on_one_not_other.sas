
options ls=180 ps=max;

data potential_new_items;
  infile cards;
  input item :$80.;
  cards;
ALENDRONATE SODIUM
ATENOLOL
Advair
Amlodipine Besylate
Atorvastatin
CARVEDILOL
CITALOPRAM HBR
Clopidogrel
Crestor
Cymbalta
DONEPIZIL
ESCITALOPRAM
FINASTERIDE
FLUOXETINE HCL
FUROSEMIDE
GABAPENTIN
Glimepiride
HYDROCHLOROTHIAZIDE
JANUMET
JANUVIA
LAMOTRIGINE
LEVOTHYROXINE SODIUM
LISINOPRIL-HYDROCHLOROTHIAZIDE
LOSARTAN POTASSIUM
Losartan Potassium -Hydrochlorothiazide
LOVASTATIN
Lisinopril
METFORMIN HCL
Metformin Extended Release
METOPROLOL TARTRATE
Metroprolol Succinate
Montelukast
PAROXETINE HCL
POTASSIUM CHLORIDE
PRAVASTATIN SODIUM
RAMIPRIL
SERTRALINE HCL
SIMVASTATIN
TAMSULOSIN HCL
TRIAMTERENE-HYDROCHLOROTHIAZIDE
Valsartan
Quetiapine
Enbre
Humira
DIVALPROEX SODIUM
GEMFIBROZIL
GLYBURIDE
GLYBURIDE-METFORMIN-HCl
LEVETIRACETAM
OLANZAPINE
OXCARBAZEPINE
RISPERIDONE
TOPIRAMATE HCL
Acarbose
Amlodipine-Benazepril
Amlodipine-Valsartan
Amlodipine-Valsartan-Hydrochlorothiazide
Atorvastatin-Amlodipine
Avandia
Azor
Benazepril
Benazepril-Hydrochlorothiazide
Benicar
Benicar-HCTZ
Candesartan Cilexetil
Candesartan Cilexetil-Hydrochlorothiazid
Captopril
Captopril-Hydrochlorothizide      
Edarbi
Edarbyclor
Enalapril
Enalapril-Hydrochlorothiazide
Eprosartan Mesylate
Farxiga
Fluvastatin
Fluvastatin XL
Fosinopril Sodium    
Fosinopril Sodium-Hydrochlorothiazide
Glipizide
Glipizide XL
Glipizide-Metformin
Glyset
Glyxambi
Harvoni
Invokamet
Invokana
Irbesartan
Irbesartan-Hydrochlorothiazide
Jardiance
Jentadueto
Kazano
Kombiglyze
Livalo
Lovastatin XR
Moexipril
Moexipril-Hydrochlorothiazide
Nesina
Onglyza
Oseni
Perindopril Erbumine
Pioglitazone
Pioglitazone-Glimepiride
Pioglitazone-Metformin
Quinapril
Quinapril-Hydrochlorothiazide
Repaglinide-Metformin
Simcor
Synjardy
Tekturna
Tekturna HCTZ
Telmisartan
Telmisartan-Amlodipine
Telmisartan-Hydrochlorothiazide
Tradjenta
Trandolapril
Trandolapril-Verapamil
Tribenzor
Valsartan-Hydrochlorothiazide
Viekira
Vytorin
Xigduo XR
  ;
run;

data existing_items;
  infile cards;
  input item :$80.;
  cards;
ALENDRONATE SODIUM 
ATENOLOL 
Advair 
Amlodipine Besylate 
Atorvastatin 
CARVEDILOL 
CITALOPRAM HBR 
Clopidogrel 
Crestor 
Cymbalta 
DONEPIZIL 
ESCITALOPRAM 
FINASTERIDE 
FLUOXETINE HCL 
FUROSEMIDE 
GABAPENTIN 
Glimepiride 
HYDROCHLOROTHIAZIDE 
JANUMET 
JANUVIA 
LAMOTRIGINE 
LEVOTHYROXINE SODIUM 
LISINOPRIL-HYDROCHLOROTHIAZIDE 
LOSARTAN POTASSIUM 
Losartan Potassium -Hydrochlorothiazide 
LOVASTATIN 
Lisinopril 
METFORMIN HCL 
Metformin Extended Release 
METOPROLOL TARTRATE 
Metroprolol Succinate 
Montelukast 
PAROXETINE HCL 
POTASSIUM CHLORIDE 
PRAVASTATIN SODIUM 
RAMIPRIL 
SERTRALINE HCL 
SIMVASTATIN 
TAMSULOSIN HCL 
TRIAMTERENE-HYDROCHLOROTHIAZIDE 
Valsartan 
Quetiapine 
Enbre 
Humira 
DIVALPROEX SODIUM 
GEMFIBROZIL 
GLYBURIDE 
GLYBURIDE-METFORMIN-HCl 
LEVETIRACETAM 
OLANZAPINE 
OXCARBAZEPINE 
RISPERIDONE 
TOPIRAMATE HCL 
Acarbose 
Amlodipine-Benazepril 
Amlodipine-Valsartan 
Amlodipine-Valsartan-Hydrochlorothiazide 
Atorvastatin-Amlodipine 
Avandia 
Azor 
Benazepril 
Benazepril-Hydrochlorothiazide 
Benicar 
Benicar-HCTZ 
Candesartan Cilexetil 
Candesartan Cilexetil-Hydrochlorothiazid 
Captopril 
Captopril-Hydrochlorothizide       
Edarbi 
Edarbyclor 
Enalapril 
Enalapril-Hydrochlorothiazide 
Eprosartan Mesylate 
Farxiga 
Fluvastatin 
Fluvastatin XL 
Fosinopril Sodium     
Fosinopril Sodium-Hydrochlorothiazide 
Glipizide 
Glipizide XL 
Glipizide-Metformin 
Glyset 
Glyxambi 
Harvoni 
Invokamet 
Invokana 
Irbesartan 
Irbesartan-Hydrochlorothiazide 
Jardiance 
Jentadueto 
Kazano 
Kombiglyze 
Livalo 
Lovastatin XR 
Moexipril 
Moexipril-Hydrochlorothiazide 
Nesina 
Onglyza 
Oseni 
Perindopril Erbumine 
Pioglitazone 
Pioglitazone-Glimepiride 
Pioglitazone-Metformin 
Quinapril 
Quinapril-Hydrochlorothiazide 
Repaglinide-Metformin 
Simcor 
Synjardy 
Tekturna 
Tekturna HCTZ 
Telmisartan 
Telmisartan-Amlodipine 
Telmisartan-Hydrochlorothiazide 
Tradjenta 
Trandolapril 
Trandolapril-Verapamil 
Tribenzor 
Valsartan-Hydrochlorothiazide 
Vytorin 
Xigduo XR 
  ;
run;
/***title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;***/

proc sql;
  create table new_items as
  select a.item
  from potential_new_items a left join existing_items b on a.item=b.item
  where b.item is null
  ;
quit;
title "not on existing";proc print data=_LAST_ width=minimum heading=H;run;title;
proc sql;
  create table new_items as
  select b.item
  from potential_new_items a right join existing_items b on a.item=b.item
  where a.item is null
  ;
quit;
title "not on new";proc print data=_LAST_ width=minimum heading=H;run;title;
