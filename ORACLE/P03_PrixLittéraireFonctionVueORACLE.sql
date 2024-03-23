-- 1/ Voici trois vues basées sur des requêtes précédentes qui pourraient être utiles à un utilisateur :
-- Vue n°1 :  des Lauréats avec le Nombre de Livres Écrits
CREATE VIEW pO3_VueLaureatsNombreLivres AS
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
SELECT * FROM pO3_VueLaureatsNombreLivres ; -- quelques laureats ont 0 livres car ils ont eu un prix récompensant leurs carrières



-- Vue n°2 : des Livres avec les Détails des Auteurs :

CREATE VIEW p03_vueLivresAuteurs AS
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
SELECT  * FROM p03_vueLivresAuteurs;


-- Vue n°3 : Vue des Lauréats avec les Détails des Prix Remportés .
CREATE VIEW p03_vueLaureatsDetailsPrix AS
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
SELECT * FROM p03_vueLaureatsDetailsPrix;


--  //////////////////////////// Fonctions et procédures PL/*SQL ///////////////////////////////////////////////////::

-- 1/ Une procédure permettant l'édition de données en fonctions de paramètres d'entrée :

--  procédure qui prend en compte le nom et le prénom du laureat, ainsi que le nouveau pays que vous souhaitez attribuer.
-- Elle utilise ces paramètres pour mettre à jour la table des laureats.
CREATE OR REPLACE PROCEDURE p03_ModifierPaysLaureat(p_nom VARCHAR2, p_prenom VARCHAR2, p_nouveau_pays VARCHAR2) IS
BEGIN
    UPDATE p03_Laureat
    SET L_pays = p_nouveau_pays
    WHERE L_nom = p_nom AND L_prenom = p_prenom;
    COMMIT ;
END ;

-- pour le test
CALL p03_ModifierPaysLaureat('Prudhomme','Sully' , 'Algérie') ;
SELECT L_pays FROM p03_laureat WHERE L_nom ='Prudhomme' AND l_prenom = 'Sully' ;


-- 2/ Donner une fonction qui retourne une valeur simple.
-- vérifier si un auteur (représenté par son nom / prénom ) a remporté un prix ou non.
--  fonction qui  renvoie un NUMBER (1 s'il a gagné un prix, 0 sinon):


CREATE OR REPLACE FUNCTION p03_AuteurAGagnePrix(p_nom VARCHAR2, p_prenom VARCHAR2) RETURN NUMBER IS
    v_a_gagne_prix NUMBER := 0;
    v_id_auteur NUMBER;
BEGIN
    -- Vérifie si l'auteur a gagné un prix dans la table p03_RecompenserLaureatOeuvre
    SELECT L_id INTO v_id_auteur
    FROM p03_laureat
    WHERE L_nom = p_nom AND L_prenom = p_prenom;

    -- Utiliser COUNT(*) pour vérifier l'existence de l'enregistrement
    SELECT COUNT(*) INTO v_a_gagne_prix
    FROM p03_RecompenserLaureatOeuvre
    WHERE L_id = v_id_auteur;

    -- Si l'auteur n'a pas gagné de prix dans la table p03_RecompenserLaureatOeuvre,
    -- vérifie dans la table p03_RecompenserLaureatCarriere
    IF v_a_gagne_prix = 0 THEN
        SELECT COUNT(*) INTO v_a_gagne_prix
        FROM p03_RecompenserLaureatCarriere
        WHERE L_id = v_id_auteur;
    END IF;

    RETURN v_a_gagne_prix;
END p03_AuteurAGagnePrix;


-- pour le test :
SELECT p03_AuteurAGagnePrix('Prudhomme', 'Sully') AS AuteurAGagnePrix
FROM dual;

-- 3/  Une fonction qui retourne un ensemble de valeurs.
--  Fonction qui renvoie un ensemble de noms d'auteurs dont le pays est passé en paramètre :
CREATE TYPE rec_nom AS OBJECT(nom VARCHAR2(255));
CREATE TYPE tab_resultat AS TABLE OF rec_nom;

CREATE OR REPLACE FUNCTION p03_AuteursParPays(p_pays VARCHAR2) RETURN tab_resultat PIPELINED IS
    auteur_nom VARCHAR2(255);
BEGIN
    SELECT L_nom INTO auteur_nom FROM p03_Laureat WHERE L_pays = p_pays AND ROWNUM = 1;

    IF auteur_nom IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ce pays ne figure pas sur la liste des laureats pays !');
    END IF;

    FOR ligne IN (SELECT DISTINCT L_nom FROM p03_Laureat WHERE L_pays = p_pays) LOOP
        PIPE ROW(rec_nom(ligne.L_nom));
    END LOOP;

    RETURN;
END p03_AuteursParPays;
/

    -- un test :
SELECT * FROM TABLE(p03_AuteursParPays('France'));
SELECT * FROM p03_AuteursParPays('Népal') ;



-- 4/ une fonction ou un procédure mettant en œuvre un curseur paramétrique
--  Une   fonction prend en paramètre un ID d'auteur, utilise un curseur pour récupérer le nombre de livres écrits par cet auteur, et retourne ce nombre.


CREATE OR REPLACE FUNCTION p03_AuteursLivre(p_auteur_id INT) RETURN NUMBER IS
    -- Déclaration du curseur
    CURSOR livres_cursor IS
        SELECT Liv.Liv_id
        FROM p03_Laureat A
        JOIN p03_Ecrire E ON A.L_id = E.L_id
        JOIN p03_Livre Liv ON E.Liv_id = Liv.Liv_id
        WHERE A.L_id = p_auteur_id;

    -- Variable pour stocker le nombre de livres
    v_nombre_livres INT := 0;

    -- Variable pour stocker l'ID du livre (utilisée pour le FETCH)
    v_livre_id INT;

BEGIN
    -- Ouverture du curseur
    OPEN livres_cursor;

    -- Boucle pour parcourir le curseur
    LOOP
        -- Fetch du prochain enregistrement dans la variable v_livre_id
        FETCH livres_cursor INTO v_livre_id;

        -- Sortir de la boucle si aucun enregistrement n'est trouvé
        EXIT WHEN livres_cursor%NOTFOUND;

        -- Incrémentation du nombre de livres
        v_nombre_livres := v_nombre_livres + 1;
    END LOOP;

    -- Fermeture du curseur
    CLOSE livres_cursor;

    -- Retourner le nombre de livres
    RETURN v_nombre_livres;
END;
/

-- Pour Le Test :
SELECT p03_AuteursLivre(425) AS NombreLivres FROM DUAL;

-- ///////////////////////////////////////////:: Triggers :: /////////////////////////////////////////////////////
--Trigger pour chaque ligne éditée

-- Création d'une table  qui calcule le nombre de prix remportés dans chaque pays

CREATE TABLE p03_prixParPays (
    L_pays VARCHAR2(60) PRIMARY KEY,
    nombre_prix NUMBER(10,0) DEFAULT 0
);

-- Implémentation :
INSERT INTO p03_prixParPays (L_pays, nombre_prix)
SELECT L_pays, COUNT(*) AS nombre_prix
FROM (
    SELECT * FROM p03_RecompenserLaureatOeuvre
    UNION ALL
    SELECT * FROM p03_RecompenserLaureatCarriere
) pays_laureat
INNER JOIN p03_Laureat ON pays_laureat.L_id = p03_Laureat.L_id
GROUP BY L_pays;


-- création d'un trigger qui sera déclenché après l'insertion dans la table p03_Laureat

-- Création de la procédure stockée
CREATE OR REPLACE PROCEDURE p03_updateNombrePrixParPays(p_new_pays VARCHAR2) AS
  v_count NUMBER;
BEGIN
  -- Mettre à jour le nombre de prix par pays après chaque insertion
  UPDATE p03_prixParPays
  SET nombre_prix = nombre_prix + 1
  WHERE L_pays = p_new_pays;

  -- Récupérer le nombre de lignes affectées par la mise à jour
  SELECT COUNT(*) INTO v_count
  FROM p03_prixParPays
  WHERE L_pays = p_new_pays;

  -- Si le pays du lauréat n'existe pas dans la table, l'ajouter
  IF v_count = 0 THEN
    INSERT INTO p03_prixParPays ( L_pays, nombre_prix)
    VALUES ( p_new_pays, 1);
  END IF;
END;
/

-- Création du déclencheur après insertion dans p03_Laureat
CREATE OR REPLACE TRIGGER after_insert_p03_RecompenserLaureatOeuvre
AFTER INSERT ON p03_laureat
FOR EACH ROW
BEGIN
  p03_updateNombrePrixParPays(:NEW.L_pays);
END;
/

-- pour le test:
-- Avant l'insertion :
SELECT * FROM p03_prixParPays ORDER BY L_pays;

INSERT INTO p03_laureat (L_nom,L_prenom,L_sexe,L_pays) VALUES
    ('Jamila', 'Afghani', 'Féminin', 'Afghanistan');
INSERT INTO p03_PrixCarriere (P_C_nom, P_C_anneeDeSortie) VALUES
    ('AURORA','2022') ;
INSERT INTO p03_recompenserlaureatcarriere(L_id, P_C_id, dateRC) VALUES
    ((SELECT L_id FROM p03_Laureat WHERE L_nom = 'Jamila' AND L_prenom = 'Afghani'),(SELECT P_C_id FROM p03_PrixCarriere WHERE P_C_nom = 'AURORA'),TO_DATE('2023-07-18', 'YYYY-MM-DD')) ;
-- Aprés l'insertion :
SELECT * FROM p03_prixParPays ORDER BY L_pays;



--        Trigger pour l'ensemble des lignes éditées
-- On a déja créé une vue des Lauréats avec le Nombre de Livres Écrits PO3_VueLaureatsNombreLivres,
-- Création d'un trigger qui fera une incrémentation/décrémentation de NombreLivresEcrits pour insertion/suppression d'un livre

-- Avant l'insertion :

SELECT * FROM  PO3_VueLaureatsNombreLivres WHERE L_id = (SELECT L_id FROM p03_laureat WHERE L_nom = 'Bonnie' AND L_prenom ='Julie') ;

-- Création de la procédure stockée
CREATE OR REPLACE PROCEDURE p03_majNBLivres AS
BEGIN
  -- Mettre à jour des statistiques pour l'ensemble des livres supprimés
  UPDATE PO3_VueLaureatsNombreLivres
  SET NombreLivresEcrits = (
    SELECT COUNT(*)
    FROM p03_Laureat L
    LEFT JOIN p03_Ecrire E ON L.L_id = E.L_id
    GROUP BY L.L_id, L.L_nom, L.L_prenom, L.L_pays
  );
END;
/

-- Création du déclencheur après suppression sur p03_Ecrire
CREATE OR REPLACE TRIGGER p03_maj_livres_trigger
AFTER DELETE ON p03_Ecrire
BEGIN
  p03_majNBLivres();
END;
/
-- pour le test d'insertion :
INSERT INTO p03_Livre (liv_titre, liv_editeur, liv_anneeedition, liv_nbpages) VALUES
    ('xxxxx','xxxxx','2023','200');
INSERT INTO p03_ecrire(Liv_id, l_id)VALUES
    ((SELECT Liv_id FROM p03_Livre WHERE liv_titre ='xxxxx') , (SELECT L_id FROM p03_laureat WHERE L_nom = 'Bonnie' AND L_prenom ='Julie')) ;
SELECT * FROM  PO3_VueLaureatsNombreLivres WHERE L_id = (SELECT L_id FROM p03_laureat WHERE L_nom = 'Bonnie' AND L_prenom ='Julie') ;
