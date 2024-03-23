-- 1/ Voici trois vues basées sur des requêtes précédentes qui pourraient être utiles à un utilisateur :

-- Vue n°1 :  des Lauréats avec le Nombre de Livres Écrits
CREATE VIEW PO3_VueLaureatsNombreLivres AS
SELECT
    L.L_id,
    L.L_nom,
    L.L_prenom,
    L.L_pays,
    COUNT(E.Liv_id) AS NombreLivresEcrits
FROM
    p03_Laureat L
LEFT JOIN
    p03_Ecrire E ON L.L_id = E.L_id
GROUP BY
    L.L_id, L.L_nom, L.L_prenom, L.L_pays;
-- Intérêt :
-- Cette vue affiche des informations sur les laureats, y compris le nombre de livres qu'ils ont écrits.
-- Cela peut être utile pour avoir une vue d'ensemble du succès d'un laureat en fonction du nombre de livres écrits.

-- pour le test
SELECT * FROM PO3_VueLaureatsNombreLivres ; -- quelques laureats ont 0 livres car ils ont eu un prix récompensant leurs carrières


-- Vue n°2 : des Livres avec les Détails des Auteurs :
CREATE VIEW P03_vueLivresAuteurs AS
SELECT
    Liv.Liv_id,
    Liv.Liv_titre,
    Liv.Liv_editeur,
    Liv.Liv_anneeEdition,
    Liv.Liv_nbPages,
    L.L_nom AS Auteur_Nom,
    L.L_prenom AS Auteur_Prenom,
    L.L_pays AS Auteur_Pays
FROM
    p03_Livre Liv
JOIN
    p03_Ecrire E ON Liv.Liv_id = E.Liv_id
JOIN
    p03_Laureat L ON E.L_id = L.L_id;

-- Intérêt :
-- Cette vue donne des informations détaillées sur les livres, y compris le nom, prénom et pays de l'auteur.
-- Cela permet à un utilisateur de voir les détails complets des livres, y compris qui les a écrits.

-- pour le test
SELECT  * FROM P03_vueLivresAuteurs;


-- Vue n°3 : Vue des Lauréats avec les Détails des Prix Remportés .
CREATE VIEW P03_vueLaureatsDetailsPrix AS
SELECT
    L.L_id,
    L.L_nom,
    L.L_prenom,
    L.L_pays,
    RO.P_Oeu_id AS PrixOeuvreRemporte,
    RC.P_C_id AS PrixCarriereRemporte
FROM
    p03_Laureat L
LEFT JOIN
    p03_RecompenserLaureatOeuvre RO ON L.L_id = RO.L_id
LEFT JOIN
    p03_RecompenserLaureatCarriere RC ON L.L_id = RC.L_id;

-- Cette vue affiche des informations sur les laureats, y compris les détails des Prix Oeuvre et Prix Carrière qu'ils ont remportés.
-- Cela peut fournir une vue d'ensemble complète des réalisations d'un laureat.
-- le test :
SELECT * FROM P03_vueLaureatsDetailsPrix;


