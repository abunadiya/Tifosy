-- =============================================================================
-- Projet   : Tifosi — restaurant de street-food italien
-- Fichier  : 03_requetes.sql
-- Objet    : 10 requêtes de vérification du schéma et des données
-- Préalable : exécuter 01_schema.sql puis 02_insert.sql
-- Exécution : mysql -u root -p tifosi < 03_requetes.sql
--
-- Pour chaque requête :
--   - numéro et objectif
--   - code SQL
--   - résultat attendu (calculé à partir des fichiers Excel)
--   - résultat obtenu (identique après exécution de 02_insert.sql)
--   - commentaire d'écart s'il y a lieu
-- =============================================================================

SET NAMES utf8mb4;
USE tifosi;


-- -----------------------------------------------------------------------------
-- Requête 1
-- But : afficher la liste des noms des focaccias par ordre alphabétique croissant
-- -----------------------------------------------------------------------------
SELECT nom
FROM focaccia
ORDER BY nom ASC;

-- Résultat attendu (8 lignes) :
--   Américaine
--   Emmentalaccia
--   Gorgonzollaccia
--   Hawaienne
--   Mozaccia
--   Paysanne
--   Raclaccia
--   Tradizione
-- Résultat obtenu : identique
-- Écart : aucun


-- -----------------------------------------------------------------------------
-- Requête 2
-- But : afficher le nombre total d'ingrédients
-- -----------------------------------------------------------------------------
SELECT COUNT(*) AS nb_ingredients
FROM ingredient;

-- Résultat attendu : 25
-- Résultat obtenu : 25
-- Écart : aucun


-- -----------------------------------------------------------------------------
-- Requête 3
-- But : afficher le prix moyen des focaccias
-- -----------------------------------------------------------------------------
SELECT ROUND(AVG(prix), 2) AS prix_moyen
FROM focaccia;

-- Résultat attendu : 10.38
--   (9.80 + 10.80 + 8.90 + 9.80 + 8.90 + 11.20 + 10.80 + 12.80) / 8 = 10.375
--   arrondi à 2 décimales → 10.38
-- Résultat obtenu : 10.38
-- Écart : aucun
-- Note : sans ROUND(), MySQL renvoie 10.375000


-- -----------------------------------------------------------------------------
-- Requête 4
-- But : afficher la liste des boissons avec leur marque, triée par nom de boisson
-- -----------------------------------------------------------------------------
SELECT b.nom AS nom_boisson,
       m.nom AS nom_marque
FROM boisson AS b
INNER JOIN marque AS m ON m.id_marque = b.id_marque
ORDER BY b.nom ASC;

-- Résultat attendu (12 lignes) :
--   Capri-sun                   | Coca-cola
--   Coca-cola original          | Coca-cola
--   Coca-cola zéro              | Coca-cola
--   Eau de source               | Cristalline
--   Fanta citron                | Coca-cola
--   Fanta orange                | Coca-cola
--   Lipton Peach                | Pepsico
--   Lipton zéro citron          | Pepsico
--   Monster energy ultra blue   | Monster
--   Monster energy ultra gold   | Monster
--   Pepsi                       | Pepsico
--   Pepsi Max Zéro              | Pepsico
-- Résultat obtenu : identique
-- Écart : aucun


-- -----------------------------------------------------------------------------
-- Requête 5
-- But : afficher la liste des ingrédients pour une Raclaccia
-- -----------------------------------------------------------------------------
SELECT i.nom AS ingredient,
       c.quantite
FROM focaccia AS f
INNER JOIN comprend AS c ON c.id_focaccia = f.id_focaccia
INNER JOIN ingredient AS i ON i.id_ingredient = c.id_ingredient
WHERE f.nom = 'Raclaccia'
ORDER BY i.nom ASC;

-- Résultat attendu (7 lignes) :
--   Ail           | 2
--   Base Tomate   | 200
--   Champignon    | 40
--   Cresson       | 20
--   Parmesan      | 50
--   Poivre        | 1
--   Raclette      | 50
-- Résultat obtenu : identique
-- Écart : aucun


-- -----------------------------------------------------------------------------
-- Requête 6
-- But : afficher le nom et le nombre d'ingrédients pour chaque focaccia
-- -----------------------------------------------------------------------------
SELECT f.nom,
       COUNT(c.id_ingredient) AS nb_ingredients
FROM focaccia AS f
INNER JOIN comprend AS c ON c.id_focaccia = f.id_focaccia
GROUP BY f.id_focaccia, f.nom
ORDER BY f.nom ASC;

-- Résultat attendu (8 lignes) :
--   Américaine        | 8
--   Emmentalaccia     | 7
--   Gorgonzollaccia   | 8
--   Hawaienne         | 9
--   Mozaccia          | 10
--   Paysanne          | 12
--   Raclaccia         | 7
--   Tradizione        | 9
-- Résultat obtenu : identique
-- Écart : aucun


-- -----------------------------------------------------------------------------
-- Requête 7
-- But : afficher le nom de la focaccia qui a le plus d'ingrédients
-- -----------------------------------------------------------------------------
SELECT f.nom,
       COUNT(c.id_ingredient) AS nb_ingredients
FROM focaccia AS f
INNER JOIN comprend AS c ON c.id_focaccia = f.id_focaccia
GROUP BY f.id_focaccia, f.nom
ORDER BY nb_ingredients DESC
LIMIT 1;

-- Résultat attendu : Paysanne | 12
-- Résultat obtenu : Paysanne | 12
-- Écart : aucun
-- Note : en cas d'égalité, LIMIT 1 n'en retournerait qu'une ; ici le maximum
--        est unique, donc pas d'ambiguïté.


-- -----------------------------------------------------------------------------
-- Requête 8
-- But : afficher la liste des focaccias qui contiennent de l'ail
-- -----------------------------------------------------------------------------
SELECT DISTINCT f.nom
FROM focaccia AS f
INNER JOIN comprend AS c ON c.id_focaccia = f.id_focaccia
INNER JOIN ingredient AS i ON i.id_ingredient = c.id_ingredient
WHERE i.nom = 'Ail'
ORDER BY f.nom ASC;

-- Résultat attendu (4 lignes) :
--   Gorgonzollaccia
--   Mozaccia
--   Paysanne
--   Raclaccia
-- Résultat obtenu : identique
-- Écart : aucun


-- -----------------------------------------------------------------------------
-- Requête 9
-- But : afficher la liste des ingrédients inutilisés
-- -----------------------------------------------------------------------------
SELECT i.nom
FROM ingredient AS i
LEFT JOIN comprend AS c ON c.id_ingredient = i.id_ingredient
WHERE c.id_focaccia IS NULL
ORDER BY i.nom ASC;

-- Résultat attendu (2 lignes) :
--   Salami
--   Tomate cerise
-- Résultat obtenu : identique
-- Écart : aucun
-- Ces deux ingrédients figurent dans ingredient.xlsx mais dans aucune recette.


-- -----------------------------------------------------------------------------
-- Requête 10
-- But : afficher la liste des focaccias qui n'ont pas de champignons
-- -----------------------------------------------------------------------------
SELECT f.nom
FROM focaccia AS f
WHERE f.id_focaccia NOT IN (
    SELECT c.id_focaccia
    FROM comprend AS c
    INNER JOIN ingredient AS i ON i.id_ingredient = c.id_ingredient
    WHERE i.nom = 'Champignon'
)
ORDER BY f.nom ASC;

-- Résultat attendu (2 lignes) :
--   Américaine
--   Hawaienne
-- Résultat obtenu : identique
-- Écart : aucun


-- =============================================================================
-- Fin des requêtes de test
-- =============================================================================
