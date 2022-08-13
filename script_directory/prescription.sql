/*1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.*/
  
--ANSWER: 1912011792 API, 4538 Claims

SELECT prescriber.npi,
  total_claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
ORDER BY total_claim_count DESC;
  
/*1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.*/
  
--ANSWER: David / Coffey / Family Practice

SELECT prescriber.npi,
  nppes_provider_first_name,
  nppes_provider_last_org_name,
  specialty_description,
  total_claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
ORDER BY total_claim_count DESC;

/*2a. Which specialty had the most total number of claims (totaled over all drugs)?*/
   
--ANSWER: Nurse Practitioner / 164609

SELECT specialty_description, COUNT(total_claim_count) AS claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
GROUP BY specialty_description
ORDER BY claim_count DESC;

/*2b. Which specialty had the most total number of claims for opioids?*/

--ANSWER: Nurse Practitioner / 9551

SELECT specialty_description, COUNT(opioid_drug_flag) AS opioid_flag
FROM prescriber
LEFT JOIN prescription
  USING (npi)
LEFT JOIN drug
  USING (drug_name)
WHERE total_claim_count IS NOT null AND UPPER(opioid_drug_flag) = 'Y'
GROUP BY specialty_description
ORDER BY opioid_flag DESC;

/*2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?*/

--ANSWER: 92 specialties total

SELECT specialty_description, COUNT(total_claim_count)
FROM prescriber
LEFT JOIN prescription
USING (npi)
WHERE total_claim_count IS null
GROUP BY specialty_description;

/*2d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?*/

--ANSWER:



/*3a. Which drug (generic_name) had the highest total drug cost?*/

--ANSWER: INSULIN GLARGINE,HUM.REC.ANLOG / 104264066

SELECT generic_name, ROUND(SUM(total_drug_cost),0) AS high_cost
FROM drug
LEFT JOIN prescription
USING (drug_name)
WHERE total_drug_cost IS NOT null
GROUP BY generic_name
ORDER BY high_cost DESC;

/*3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.*/

--ANSWER: PIRFENIDONE / 7751.16 ( ... / 365)
--NOTES: Changes to IMMUN GLOB / 7141.11 ( ... / total_day_supply)
--       Changes to LEDIPASVIR / 11414.04 ( SUM(total_drug_cost) )

SELECT generic_name, ROUND(SUM(total_drug_cost) / total_day_supply,2) AS high_cost
FROM drug
LEFT JOIN prescription
USING (drug_name)
WHERE total_drug_cost IS NOT null
GROUP BY generic_name, total_day_supply
ORDER BY high_cost DESC;

/*4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.*/

--ANSWER:

SELECT p.drug_name,
  CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
       WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
       ELSE 'neither' END
       AS drug_type
FROM prescription AS p
LEFT JOIN drug
USING (drug_name)

/*4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.*/

--ANSWER: Opioid $105,080,626.37 / Antibiotic $38,435,121.26

SELECT subquery.drug_type,
       CAST(SUM(total_drug_cost) AS money) AS total_cost
FROM
  (SELECT drug_name,
    CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
         WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
         ELSE 'neither' END AS drug_type
   FROM drug) AS subquery
LEFT JOIN prescription
ON subquery.drug_name = prescription.drug_name
WHERE drug_type = 'opioid' OR drug_type = 'antibiotic'
GROUP BY subquery.drug_type
ORDER BY total_cost DESC;

/*5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.*/

--ANSWER: 10 CBSAs in Tennessee

SELECT COUNT(DISTINCT cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

/*5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.*/

/*  ANSWER: Nashville-Davidson-Murfreesboro-Franklin : 1830410
            Morristown                               : 116352  */

SELECT DISTINCT c.cbsaname, SUM(p.population) AS combined_pop
FROM cbsa AS c
LEFT JOIN fips_county AS f
USING (fipscounty)
LEFT JOIN population as p
USING (fipscounty)
WHERE p.population IS NOT null
GROUP BY c.cbsaname
ORDER BY combined_pop DESC;

/*5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.*/

--ANSWER: Largest: Sevier 95523 / Smallest: Pickett 5071

SELECT county, cbsa, SUM(population) AS total_pop
FROM fips_county AS f
LEFT JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
LEFT JOIN population AS p
ON f.fipscounty = p.fipscounty
WHERE TRUE
AND c.cbsa IS NULL AND state = 'TN' AND county != 'STATEWIDE'
GROUP BY county, cbsa
ORDER BY total_pop DESC;

SELECT county, cbsa, SUM(population) AS total_pop
FROM fips_county AS f
LEFT JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
LEFT JOIN population AS p
ON f.fipscounty = p.fipscounty
WHERE TRUE 
AND c.cbsa IS NULL AND state = 'TN' AND county != 'STATEWIDE'
GROUP BY county, cbsa
ORDER BY total_pop;

/*6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.*/

--ANSWER: 9 rows

SELECT p.drug_name, total_claim_count
FROM prescription AS p
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

/*6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.*/

--ANSWER: OXYCODONE HCL 4538 / HYDROCODONE-ACETAMINOPHEN 3376

SELECT p.drug_name, total_claim_count
FROM prescription AS p
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;

/*6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.*/

SELECT p.drug_name, total_claim_count,
  nppes_provider_first_name,
  nppes_provider_last_org_name
FROM prescription AS p
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
LEFT JOIN prescriber AS pr
ON p.npi = pr.npi
WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;

/*The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.*/

/*7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.*/

/*7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).*/

/*7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.*/
