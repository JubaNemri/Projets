
-- -------------------///////////: Nettoyage et import de la base de données /////////////////// -------------------------

-- suppression des associations:
    -- suppression des vues :
    DROP VIEW IF EXISTS p03_vueLaureatsDetailsPrix;
    DROP VIEW IF EXISTS vue_livres_et_laureats ;
DROP TABLE IF EXISTS p03_RecompenserLaureatCarriere;
DROP TABLE IF EXISTS p03_RecompenserLaureatOeuvre;
DROP  TABLE  IF EXISTS p03_Ecrire CASCADE;

-- suppression des tables :
DROP TABLE IF EXISTS p03_Livre;
DROP TABLE IF EXISTS p03_PrixCarriere;
DROP TABLE IF EXISTS p03_PrixOeuvre;
DROP TABLE IF EXISTS p03_Laureat;

-- suppression des vues:
DROP VIEW IF EXISTS pO3_VueLaureatsNombreLivres;
DROP VIEW IF EXISTS p03_vueLivresAuteurs;
DROP TABLE IF EXISTS p03_prixParPays;

-- suppression des fonctions et des procédures:
DROP PROCEDURE IF EXISTS p03_ModifierPaysLaureat ;
DROP FUNCTION IF EXISTS p03_AuteurAGagnePrix ;
DROP FUNCTION IF EXISTS p03_AuteursParPays ;
DROP FUNCTION IF EXISTS p03_LivresParAuteur;


-- suppression des triggers
DROP TRIGGER IF EXISTS after_insert_p03_RecompenserLaureatOeuvre ON p03_laureat;
        -- suppression de la table updateNombrePrixParPays
        DROP FUNCTION IF EXISTS  updateNombrePrixParPays;
DROP TRIGGER IF EXISTS  maj_livres_trigger ON p03_ecrire ;
        -- suppression de la table p03_majNBLivres
        DROP FUNCTION IF EXISTS  p03_majNBLivres;



