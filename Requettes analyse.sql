--Quels sont les 5 produits les plus vendus ?
SELECT TOP 5 
    P.Product_Name,
    SUM(F.Quantity) AS Total_Quantity_Sold
FROM 
    Order_Fact F
JOIN 
    Product_Dim P ON F.ID_DIM_Product = P.ID_DIM_Product
GROUP BY 
    P.Product_Name
ORDER BY 
    Total_Quantity_Sold DESC;

--Quel est le chiffre d’affaires généré par produit ?

SELECT 
    P.Product_Name,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Order_Fact F
JOIN 
    Product_Dim P ON F.ID_DIM_Product = P.ID_DIM_Product
GROUP BY 
    P.Product_Name
ORDER BY 
    Chiffre_Affaires DESC;

--Quels sont les 5 meilleurs fournisseurs ?

SELECT TOP 5 
    P.Supplier_Name,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Order_Fact F
JOIN 
    Product_Dim P ON F.ID_DIM_Product = P.ID_DIM_Product
GROUP BY 
    P.Supplier_Name
ORDER BY 
    Chiffre_Affaires DESC;

--Quel est le chiffre d’affaires généré par continent ?
SELECT 
    G.Continent,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Order_Fact F
JOIN 
    Geography_Dim G ON F.ID_DIM_Street = G.ID_DIM_Street
GROUP BY 
    G.Continent
ORDER BY 
    Chiffre_Affaires DESC;

-- Quelle est la marge générée par année et par mois ?
-- Comme je n’ai pas la colonne Num_Annee dans mon modèle, je l’ai remplacée par la colonne Annee.

SELECT 
	T.Annee,
    T.Num_Mois,
    SUM((F.Total_Retail_Price - F.CostPrice_Per_Unit) * F.Quantity) AS Marge_Totale
FROM 
    Order_Fact F
JOIN 
    DIM_TEMPS T ON F.ID_Date = T.ID_Date
GROUP BY 
    T.Annee,
    T.Num_Mois
ORDER BY
    T.Annee,
    T.Num_Mois;

--Quel est le chiffre d’affaires généré par année et par mois ?

SELECT 
    T.Annee,
    T.Num_Mois,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Order_Fact F
JOIN 
    DIM_TEMPS T ON F.ID_Date = T.ID_Date
GROUP BY 
    T.Annee,
    T.Num_Mois
ORDER BY 
    T.Annee,
    T.Num_Mois;

--Quel est le coût total par année et par mois ?

SELECT 
    T.Annee,
    T.Num_Mois,
    SUM(F.Quantity * F.CostPrice_Per_Unit) AS Cout_Total
FROM 
    Order_Fact F
JOIN 
    DIM_TEMPS T ON F.ID_Date = T.ID_Date
GROUP BY 
    T.Annee,
    T.Num_Mois
ORDER BY 
    T.Annee,
    T.Num_Mois;

--Quels sont les commerciaux réalisant le plus de ventes ?

SELECT 
    E.Org_Name AS Commercial,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Order_Fact F
JOIN 
    Organization_Dim E ON F.ID_DIM_Employee = E.ID_DIM_Employee
GROUP BY 
     E.Org_Name 
ORDER BY 
    Chiffre_Affaires DESC;

--Quelles sont les caractéristiques des commerciaux (pays, sexe, âge, salaire, chiffre d’affaires
SELECT 
    E.Org_Name AS Commercial,
    G.Country AS Pays,
    E.Gender AS Sexe,
    DATEDIFF(YEAR, E.Birth_Date, GETDATE()) AS Age,
    E.Salary AS Salaire,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Organization_Dim E
JOIN 
    Geography_Dim G ON E.ID_Geography = G.ID_Geography
LEFT JOIN 
    Order_Fact F ON E.ID_DIM_Employee = F.ID_DIM_Employee
GROUP BY 
    E.Org_Name, G.Country, E.Gender, E.Birth_Date, E.Salary
ORDER BY 
    Chiffre_Affaires DESC;

--Y a-t-il une différence significative entre la moyenne du chiffre d’affaires généré par les commerciaux de sexe féminin et ceux de sexe masculin ?

WITH CA_Par_Commercial AS (
    SELECT 
        E.ID_DIM_Employee,
        E.Gender,
        SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
    FROM 
        Order_Fact F
    JOIN 
        Organization_Dim E ON F.ID_DIM_Employee = E.ID_DIM_Employee
    GROUP BY 
        E.ID_DIM_Employee, E.Gender
)

SELECT 
    Gender,
    COUNT(*) AS Nombre_Commerciaux,
    AVG(Chiffre_Affaires) AS Moyenne_CA_Par_Commercial
FROM 
    CA_Par_Commercial
GROUP BY 
 Gender;

 --Quels sont les 5 meilleurs clients ?

 SELECT TOP 5 
    C.[Customer_Name] AS Client,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
    Order_Fact F
JOIN 
    Customer_Dim C ON F.ID_DIM_Customer = C.ID_DIM_Customer
GROUP BY 
    C.[Customer_Name]
ORDER BY 
    Chiffre_Affaires DESC;

/*Déterminer l’âge des clients ainsi que leur tranche d’âge afin de leur proposer une offre adaptée 
o	Moins de 30 ans :"Tranche "moins de 30 ans"
o	De 30 à 45 ans : "Tranche "30-45 ans"
o	De 46 à 60 ans : "Tranche "46-60 ans"
o	De 61 à 75 ans : "Tranche "61-75 ans"
o	Plus de 75 ans : "Tranche "plus de 75 ans*/


SELECT 
    C.Customer_Name AS Client,
    DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) AS Age,
    CASE 
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) < 30 THEN 'Tranche moins de 30 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 30 AND 45 THEN 'Tranche 30-45 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 46 AND 60 THEN 'Tranche 46-60 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 61 AND 75 THEN 'Tranche 61-75 ans'
        ELSE 'Tranche plus de 75 ans'
    END AS Tranche_Age
FROM 
    Customer_Dim C;

--Quel est le chiffre d’affaires généré par groupe de clients (par tranche d’âge) ?

SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) < 30 THEN 'Tranche moins de 30 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 30 AND 45 THEN 'Tranche 30-45 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 46 AND 60 THEN 'Tranche 46-60 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 61 AND 75 THEN 'Tranche 61-75 ans'
        ELSE 'Tranche plus de 75 ans'
    END AS Tranche_Age,
    SUM(F.Quantity * F.Total_Retail_Price) AS Chiffre_Affaires
FROM 
          Order_Fact F
JOIN 
          Customer_Dim C ON F.ID_DIM_Customer = C.ID_DIM_Customer
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) < 30 THEN 'Tranche moins de 30 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 30 AND 45 THEN 'Tranche 30-45 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 46 AND 60 THEN 'Tranche 46-60 ans'
        WHEN DATEDIFF(YEAR, C.Customer_Birth_Date, GETDATE()) BETWEEN 61 AND 75 THEN 'Tranche 61-75 ans'
        ELSE 'Tranche plus de 75 ans'
    END
ORDER BY 
    Chiffre_Affaires DESC;


