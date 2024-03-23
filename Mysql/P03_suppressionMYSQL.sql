
-- -------------------///////////: Nettoyage et import de la base de données /////////////////// -------------------------

-- suppression des associations:
DROP TABLE IF EXISTS p03_RecompenserLaureatCarriere;
DROP TABLE IF EXISTS p03_RecompenserLaureatOeuvre;
DROP TABLE IF EXISTS p03_Ecrire;

-- suppression des tables :
DROP TABLE IF EXISTS p03_Livre;
DROP TABLE IF EXISTS p03_PrixCarriere;
DROP TABLE IF EXISTS p03_PrixOeuvre;
DROP TABLE IF EXISTS p03_Laureat;

-- suppression des vues:
DROP VIEW IF EXISTS PO3_VueLaureatsNombreLivres;
DROP VIEW IF EXISTS P03_vueLivresAuteurs;
DROP VIEW IF EXISTS P03_vueLaureatsDetailsPrix;
DROP VIEW IF EXISTS vue_livres_et_laureats ;

-- Test :
SHOW TABLES;