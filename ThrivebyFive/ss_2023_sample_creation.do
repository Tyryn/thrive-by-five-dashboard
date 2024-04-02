cap cd "~/Dropbox (ikapadata)/Data/2301SMARTSTART_EVL/ANALYSIS"
cap cd "$dropbox/2301SMARTSTART_EVL/ANALYSIS"
cap cd "/Users/ikapadata/ikapadata Dropbox/Georgi Borros/Data/2301SMARTSTART_EVL/ANALYSIS""


use ss_2023_data02, clear




cap cd "$dropbox/2301SMARTSTART_EVL/ANALYSIS/COUNTERFACTUAL/ThrivebyFive"
cap cd "~/Dropbox (ikapadata)/2306GA_Lebanon/2301SMARTSTART_EVL/ANALYSIS/COUNTERFACTUAL/ThrivebyFive"



use tb5i-ecda-2021-v4, clear

**# Create sample that matches SmartStart on province, quintile

* First do province
/* 
	Eastern Cape - 16.15%
	Free State - 6.72%
	Gauteng - 33.03%
	KwaZulu-Natal - 13.24%
	Limpopo - 9.98%
	Mpumalanga - 2.36%
	North West - 3.09%
	Northern Cape 2.54%
	Western Cape 12.89%
*/

* Need

/*
- Gauteng 571
- Free State 116.17
- Eastern Cape 279
- KwaZulu Natal 228.88
- Limpopo 172.5274
- Mpumalanga 40.798
- North West 53.418
- Northern Cape 43.909779
- Western Cape 222.83348

*/

gen randomiser = runiform()
sort randomiser
drop randomiser
bysort prov_geo: gen prov_index = _n

gen sample_keep=0
replace sample_keep = 1 if prov_index<=279 & prov_geo=="Eastern Cape"
replace sample_keep = 1 if prov_index<=116 & prov_geo=="Free State"
replace sample_keep = 1 if prov_index<=571 & prov_geo=="Gauteng"
replace sample_keep = 1 if prov_index<=228 & prov_geo=="KwaZulu-Natal"
replace sample_keep = 1 if prov_index<=172 & prov_geo=="Limpopo"
replace sample_keep = 1 if prov_index<=40.798 & prov_geo=="Mpumalanga"
replace sample_keep = 1 if prov_index<=53.41 & prov_geo=="North West"
replace sample_keep = 1 if prov_index<=43.90 & prov_geo=="Northern Cape"
replace sample_keep = 1 if prov_index<=222.83 & prov_geo=="Western Cape"

keep if sample_keep==1

save ss_2023_tb5_sample, replace





