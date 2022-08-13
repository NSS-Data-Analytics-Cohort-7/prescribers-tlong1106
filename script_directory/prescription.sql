/*1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.*/
  
--ACTUAL ANSWER: NPI 1881634483, 99707 Claims
--ACTUAL CODE:
SELECT prescriber.npi,
  SUM(total_claim_count) AS total_claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
GROUP BY prescriber.npi
ORDER BY total_claim_count DESC;

--MY ANSWER: NPI 1912011792, 4538 Claims
--MY CODE:
SELECT prescriber.npi,
  total_claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
ORDER BY total_claim_count DESC;
  
/*1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.*/

--ACTUAL ANSWER: Bruce / Pendley / Family Practice
--ACTUAL CODE:
SELECT prescriber.npi,
  nppes_provider_first_name,
  nppes_provider_last_org_name,
  specialty_description,
  SUM(total_claim_count) AS total_claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
GROUP BY prescriber.npi,
  nppes_provider_first_name,
  nppes_provider_last_org_name,
  specialty_description
ORDER BY total_claim_count DESC;

--MY ANSWER: David / Coffey / Family Practice
--MY CODE:
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

--ACTUAL ANSWER: Family Practice / 9752347
--ACTUAL CODE:
SELECT specialty_description, SUM(total_claim_count) AS claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
GROUP BY specialty_description
ORDER BY claim_count DESC;

--MY ANSWER: Nurse Practitioner / 164609
--MY CODE:
SELECT specialty_description, COUNT(total_claim_count) AS claim_count
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT null
GROUP BY specialty_description
ORDER BY claim_count DESC;

/*2b. Which specialty had the most total number of claims for opioids?*/

--ACTUAL ANSWER: Nurse Practitioner / 900845
--ACTUAL CODE:
SELECT SUM(total_claim_count) AS total_claim, p2.specialty_description
FROM prescription AS p1
LEFT JOIN prescriber AS p2
ON p1.npi = p2.npi
LEFT JOIN drug AS d
ON p1.drug_name = d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY p2.specialty_description
ORDER BY total_claim DESC;

--MY ANSWER: Nurse Practitioner / 9551
--MY CODE:
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
--Any JOIN works because every drug has exactly 1 (never 0, never 2)  prescription

--ACTUAL ANSWER: INSULIN GLARGINE,HUM.REC.ANLOG / 104264066
--ACTUAL CODE:
SELECT generic_name, ROUND(SUM(total_drug_cost),0) AS high_cost
FROM drug
INNER JOIN prescription
USING (drug_name)
WHERE total_drug_cost IS NOT null
GROUP BY generic_name
ORDER BY high_cost DESC;

--MY ANSWER: INSULIN GLARGINE,HUM.REC.ANLOG / 104264066
--MY CODE:
SELECT generic_name, ROUND(SUM(total_drug_cost),0) AS high_cost
FROM drug
LEFT JOIN prescription
USING (drug_name)
WHERE total_drug_cost IS NOT null
GROUP BY generic_name
ORDER BY high_cost DESC;

/*3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.*/

--ACTUAL ANSWER:
--ACTUAL CODE:
SELECT ROUND(SUM(total_drug_cost)/SUM(total_day_supply)) AS per_day, d.generic_name
FROM prescription AS p
LEFT JOIN drug AS d
USING (drug_name)
WHERE total_drug_cost IS NOT null
GROUP BY d.generic_name, total_day_supply
ORDER BY per_day DESC;

--MY ANSWER: PIRFENIDONE / 7751.16 ( ... / 365)
--           Changes to IMMUN GLOB / 7141.11 ( ... / total_day_supply)
--           Changes to LEDIPASVIR / 11414.04 ( SUM(total_drug_cost) )

SELECT generic_name, ROUND(SUM(total_drug_cost) / total_day_supply,2) AS high_cost
FROM drug
LEFT JOIN prescription
USING (drug_name)
WHERE total_drug_cost IS NOT null
GROUP BY generic_name, total_day_supply
ORDER BY high_cost DESC;

/*4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.*/


--ACTUAL ANSWER:
--ACTUAL CODE:
SELECT drug_name,
  CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
       WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
       ELSE 'neither' END
       AS drug_type
FROM drug

--MY ANSWER:
--MY CODE:
SELECT p.drug_name,
  CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
       WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
       ELSE 'neither' END
       AS drug_type
FROM prescription AS p
LEFT JOIN drug
USING (drug_name)

/*4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.*/

--ACTUAL ANSWER: Opioid $105,080,626.37 / Antibiotic $38,435,121.26
--ACTUAL CODE:


--MY ANSWER: Opioid $105,080,626.37 / Antibiotic $38,435,121.26
--MY CODE:
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

--ACTUAL ANSWER: 10 CBSAs in Tennessee
--ACTUAL CODE:
SELECT COUNT(DISTINCT cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

SELECT DISTINCT cbsaname, cbsa
FROM cbsa
LEFT JOIN fips_county
USING (fipscounty)
WHERE fips_county.state = 'TN'

--MY ANSWER: 10 CBSAs in Tennessee
--MY CODE:
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

/*5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.*/

--ACTUAL ANSWER: Nashville-Davidson-Murfreesboro-Franklin : 1830410
--               Morristown                               : 116352
--ACTUAL CODE:


--MY ANSWER: Nashville-Davidson-Murfreesboro-Franklin : 1830410
--           Morristown                               : 116352
--MY CODE:
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

--KEVIN ANSWER: Largest: Sevier 95523

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

--KEVIN ANSWER: Smallest: Pickett 5071

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

--ROB ANSWER: Largest: Shelby 937847

SELECT f.county, p.population
FROM cbsa AS c
LEFT JOIN fips_county AS f
ON c.fipscounty = f.fipscounty
LEFT JOIN population AS p
ON c.fipscounty = p.fipscounty
WHERE county NOT IN (c.cbsa)
  AND p.population IS NOT NULL
  AND c.cbsaname LIKE '%TN%'
GROUP BY f.county, p.population
ORDER BY p.population DESC;

--ROB ANSWER: Smallest: TROUSDALE 8773

SELECT f.county, p.population
FROM cbsa AS c
LEFT JOIN fips_county AS f
ON c.fipscounty = f.fipscounty
LEFT JOIN population AS p
ON c.fipscounty = p.fipscounty
WHERE county NOT IN (c.cbsa)
  AND p.population IS NOT NULL
  AND c.cbsaname LIKE '%TN%'
GROUP BY f.county, p.population
ORDER BY p.population;

/*6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.*/

--ACTUAL ANSWER: 9 rows
--ACTUAL CODE:
SELECT p.drug_name, total_claim_count
FROM prescription AS p
--LEFT JOIN drug AS d
--ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

--MY ANSWER: 9 rows
--MY CODE:
SELECT p.drug_name, total_claim_count
FROM prescription AS p
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

/*6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.*/

--ACTUAL ANSWER:
--ACTUAL CODE:


--MY ANSWER: OXYCODONE HCL 4538 / HYDROCODONE-ACETAMINOPHEN 3376
--MY CODE:
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
ON 
WHERE total_claim_count >= 3000 AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;

/*The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.*/

/*7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.*/

--ANSWER:
SELECT specialty_description, npi, drug_name
FROM prescriber AS p1
CROSS JOIN drug AS d1
WHERE nppes_provider_city = 'NASHVILLE'
  AND opioid_drug_flag = 'Y'
  AND specialty_description = 'Pain Management';

/*7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).*/

--ANSWER:
SELECT specialty_description, npi, drug_name,
  (SELECT COUNT(total_claim_count)
   FROM prescription)
FROM prescriber AS p1
CROSS JOIN drug AS d1
WHERE nppes_provider_city = 'NASHVILLE'
  AND opioid_drug_flag = 'Y'
  AND specialty_description = 'Pain Management'
GROUP BY specialty_description, drug_name, npi;

/*7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.*/

--ANSWER:
SELECT specialty_description, npi, drug_name,
  (SELECT SUM(total_claim_count)
   FROM prescription)
FROM prescriber AS p1
CROSS JOIN drug AS d1
WHERE nppes_provider_city = 'NASHVILLE'
  AND opioid_drug_flag = 'Y'
  AND specialty_description = 'Pain Management'
GROUP BY specialty_description, drug_name, npi;