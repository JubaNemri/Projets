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

CREATE OR REPLACE  PROCEDURE p03_ModifierPaysLaureat ( p_nom VARCHAR , p_prenom VARCHAR ,  p_nouveau_pays VARCHAR )  AS $$
BEGIN
    UPDATE p03_Laureat
    SET L_pays = p_nouveau_pays
    WHERE L_nom = p_nom AND L_prenom = p_prenom;
END;
$$ LANGUAGE plpgsql;

-- pour le test
CALL p03_ModifierPaysLaureat('Prudhomme','Sully' , 'Algérie') ;
SELECT L_pays FROM p03_laureat WHERE L_nom ='Prudhomme' AND l_prenom = 'Sully' ;



-- 2/ Donner une fonction qui retourne une valeur simple.
-- vérifier si un auteur (représenté par son nom / prénom ) a remporté un prix ou non.
--  fonction qui  renvoie un booléen (true s'il a gagné un prix, false sinon) :

CREATE OR REPLACE FUNCTION p03_AuteurAGagnePrix( nom varchar, prenom varchar ) RETURNS BOOLEAN AS $$
DECLARE
    a_gagne_prix BOOLEAN;
    id_auteur INTEGER;
BEGIN
    SELECT L_id INTO id_auteur FROM p03_laureat WHERE L_nom = nom AND L_prenom = prenom ;

    -- Vérifie si l'auteur a gagné un prix dans la table p03_RecompenserLaureatOeuvre
    SELECT EXISTS ( SELECT 1 FROM p03_RecompenserLaureatOeuvre WHERE L_id = id_auteur ) INTO a_gagne_prix;

    -- Si l'auteur n'a pas gagné de prix dans la table p03_RecompenserLaureatOeuvre,
    -- vérifie dans la table p03_RecompenserLaureatCarriere
    IF NOT a_gagne_prix THEN
        SELECT EXISTS ( SELECT 1 FROM p03_RecompenserLaureatCarriere WHERE L_id = id_auteur ) INTO a_gagne_prix;
        IF NOT a_gagne_prix THEN
            RAISE NOTICE 'introuvable';
        END IF;
    END IF;
    RETURN a_gagne_prix;
END;
$$ LANGUAGE plpgsql;

-- pour le test :
SELECT p03_AuteurAGagnePrix('Mommsen' , 'Theodor');
SELECT p03_AuteurAGagnePrix('Meryous' , 'Louisa') ;


-- 3/  Une fonction qui retourne un ensemble de valeurs.
--  Fonction qui renvoie un ensemble de noms d'auteurs dont le pays est passé en paramètre :

CREATE OR REPLACE FUNCTION p03_AuteursParPays(p_pays VARCHAR) RETURNS SETOF VARCHAR AS $$
DECLARE
    auteur_nom VARCHAR;
    verif bool ;
BEGIN
    SELECT EXISTS ( SELECT 1 FROM p03_laureat WHERE L_pays = p_pays ) INTO verif;
    IF NOT verif THEN
        RAISE EXCEPTION 'Ce pays ne figure pas sur la liste des laureats pays ! ';
    END IF ;

    FOR auteur_nom IN (SELECT DISTINCT L_nom FROM p03_Laureat WHERE L_pays =  p_pays ) LOOP
        RETURN NEXT auteur_nom;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql;

-- un test :
SELECT * FROM p03_AuteursParPays('France') ;
SELECT * FROM p03_AuteursParPays('Népal') ;



-- 4/ une fonction ou un procédure mettant en œuvre un curseur paramétrique
--  Une fonction avec un curseur paramétrique qui renvoie des informations plus détaillées sur les livres écrits par un auteur donné,

CREATE OR REPLACE FUNCTION p03_LivresParAuteur( p_nom VARCHAR, p_prenom VARCHAR ) RETURNS SETOF p03_Livre  AS $$
DECLARE
    auteur_id INT;
    livre_info p03_Livre%ROWTYPE;
    livre_cursor refcursor;
BEGIN
    -- Vérifier si l'auteur existe
    SELECT L_id INTO auteur_id FROM p03_Laureat WHERE L_nom = p_nom AND L_prenom = p_prenom;
    IF auteur_id IS NULL THEN
        RAISE EXCEPTION 'Auteur non trouvé : % %', p_nom, p_prenom;
    END IF;

    OPEN livre_cursor FOR
        SELECT
            L.Liv_id,
            L.Liv_titre,
            L.Liv_editeur,
            L.Liv_anneeEdition,
            L.Liv_nbPages
        FROM
            p03_Laureat A
        JOIN
            p03_Ecrire E ON A.L_id = E.L_id
        JOIN
            p03_Livre L ON E.Liv_id = L.Liv_id
        WHERE
            A.L_nom = p_nom
            AND A.L_prenom = p_prenom;

    LOOP
        FETCH livre_cursor INTO livre_info;
        EXIT WHEN NOT FOUND;
        RETURN NEXT livre_info;
    END LOOP;
    CLOSE livre_cursor;

END;
$$ LANGUAGE plpgsql;


-- test
SELECT * FROM p03_LivresParAuteur('Sansal' , 'Boualem');
SELECT * FROM p03_LivresParAuteur('Nemri','Juba');


-- ///////////////////////////////////////////:: Triggers :: /////////////////////////////////////////////////////
--Trigger pour chaque ligne éditée

-- Création d'une table  qui calcule le nombre de prix remportés dans chaque pays
DROP TABLE IF EXISTS p03_prixParPays;
CREATE  TABLE p03_prixParPays (
    L_pays VARCHAR(60) PRIMARY KEY,
    nombre_prix INT DEFAULT 0
);

-- implémentation :
INSERT INTO p03_prixParPays (L_pays, nombre_prix)
SELECT L_pays, COUNT(*) AS nombre_prix
FROM (
    SELECT * FROM p03_RecompenserLaureatOeuvre
    UNION ALL
    SELECT * FROM p03_RecompenserLaureatCarriere
) AS pays_laureat
INNER JOIN p03_Laureat ON pays_laureat.L_id = p03_Laureat.L_id
GROUP BY L_pays  ;

-- création d'un trigger qui sera déclenché après l'insertion dans la table p03_Laureat

CREATE OR REPLACE FUNCTION p03_updateNombrePrixParPays() RETURNS TRIGGER AS $$
BEGIN
    -- Mettre à jour le nombre de prix par pays après chaque insertion
    UPDATE p03_prixParPays
    SET nombre_prix = nombre_prix + 1
    WHERE L_pays = NEW.L_pays;

    -- Si le pays du lauréat n'existe pas dans la table, l'ajouter
    IF NOT FOUND THEN
        INSERT INTO p03_prixParPays (L_pays, nombre_prix)
        VALUES (NEW.L_pays, 1);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Déclencheur après insertion dans p03_Laureat
CREATE TRIGGER after_insert_p03_RecompenserLaureatOeuvre
AFTER INSERT ON p03_laureat
FOR EACH ROW EXECUTE PROCEDURE p03_updateNombrePrixParPays();


-- pour le test:
-- Avant l'insertion :
SELECT * FROM p03_prixParPays ORDER BY L_pays;

INSERT INTO p03_laureat (L_nom,L_prenom,L_sexe,L_pays) VALUES
    ('Jamila', 'Afghani', 'Féminin', 'Afghanistan');
INSERT INTO p03_PrixCarriere (P_C_nom, P_C_anneeDeSortie) VALUES
    ('AURORA','2022') ;
INSERT INTO p03_recompenserlaureatcarriere(L_id, P_C_id, date) VALUES
    ((SELECT L_id FROM p03_Laureat WHERE L_nom = 'Jamila' AND L_prenom = 'Afghani'),(SELECT P_C_id FROM p03_PrixCarriere WHERE P_C_nom = 'AURORA'),'2023-05-11') ;
-- Aprés l'insertion :
SELECT * FROM p03_prixParPays ORDER BY L_pays;



--        Trigger pour l'ensemble des lignes éditées
-- On a déja créé une vue des Lauréats avec le Nombre de Livres Écrits PO3_VueLaureatsNombreLivres,
-- Création d'un trigger qui fera une incrémentation / décrémentation de NombreLivresEcrits pour insertion/suppression d'un livre

-- Avant l'insertion :

SELECT * FROM  PO3_VueLaureatsNombreLivres;

CREATE OR REPLACE FUNCTION p03_majNBLivres() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    -- Mettre à jour des statistiques pour l'ensemble des livres supprimés
    UPDATE PO3_VueLaureatsNombreLivres
    SET NombreLivresEcrits = (SELECT COUNT(*) FROM p03_Laureat L
LEFT JOIN
    p03_Ecrire E ON L.L_id = E.L_id
GROUP BY
    L.L_id, L.L_nom, L.L_prenom, L.L_pays);

    RETURN NULL; --  pour un trigger AFTER DELETE
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER p03_maj_livres_trigger
AFTER DELETE ON p03_Ecrire
FOR EACH STATEMENT
EXECUTE FUNCTION p03_majNBLivres();

-- pour le test d'insertion :
INSERT INTO p03_Livre (liv_titre, liv_editeur, liv_anneeedition, liv_nbpages) VALUES
    ('xxxxx','xxxxx','2023','200');
INSERT INTO p03_ecrire(Liv_id, l_id)VALUES
    ((SELECT Liv_id FROM p03_Livre WHERE liv_titre ='xxxxx') , (SELECT L_id FROM p03_laureat WHERE L_nom = 'Bonnie' AND L_prenom ='Julie')) ;
SELECT * FROM  pO3_VueLaureatsNombreLivres;

-- pour le test de suppression :
DELETE FROM p03_ecrire WHERE Liv_id = (SELECT Liv_id FROM p03_Livre WHERE liv_titre ='xxxxx');
DELETE FROM p03_livre WHERE liv_titre = 'xxxxx' ;

SELECT * FROM  pO3_VueLaureatsNombreLivres;
































