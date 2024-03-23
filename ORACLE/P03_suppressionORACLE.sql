
-- -------------------///////////: Nettoyage et import de la base de données /////////////////// -------------------------

-- suppression des associations:
DROP TABLE  p03_RecompenserLaureatCarriere;
DROP TABLE  p03_RecompenserLaureatOeuvre;
DROP TABLE  p03_Ecrire;

-- suppression des tables :
DROP TABLE  p03_Livre;
DROP TABLE  p03_PrixCarriere;
DROP TABLE  p03_PrixOeuvre;
DROP TABLE  p03_Laureat;

-- suppression des vues:
DROP VIEW   PO3_VueLaureatsNombreLivres;
DROP VIEW   P03_vueLivresAuteurs;
DROP VIEW   P03_vueLaureatsDetailsPrix;
DROP VIEW   vue_livres_et_laureats ;

-- suppression des séquences existantes
DROP sequence seq_PrixCarriere;
DROP sequence seq_PrixOeuvre;
DROP sequence seq_Livre;
DROP sequence seq_Laureat;


-- suppression des fonctions et des procédures:
DROP PROCEDURE p03_ModifierPaysLaureat ;
DROP FUNCTION  p03_AuteurAGagnePrix ;
DROP FUNCTION  p03_AuteursParPays ;
DROP FUNCTION  p03_AuteursLivre;


-- Suppression du déclencheur after_insert_p03_RecompenserLaureatOeuvre
DROP TRIGGER after_insert_p03_RecompenserLaureatOeuvre;

-- Suppression de la fonction p03_updateNombrePrixParPays
DROP PROCEDURE p03_updateNombrePrixParPays;

-- Suppression du déclencheur maj_livres_trigger
DROP TRIGGER p03_maj_livres_trigger;

-- Suppression de la fonction p03_majNBLivres
DROP PROCEDURE p03_majNBLivres;

-- pour tester :
SELECT table_name FROM user_tables
