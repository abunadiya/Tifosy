-- =============================================================================
-- Projet   : Tifosi — restaurant de street-food italien
-- Fichier  : 02_insert.sql
-- Objet    : peuplement de la base à partir des fichiers Excel fournis
--            (marque.xlsx, boisson.xlsx, ingredient.xlsx, focaccia.xlsx)
-- Préalable : exécuter 01_schema.sql
-- Exécution : mysql -u root -p tifosi < 02_insert.sql
-- =============================================================================

SET NAMES utf8mb4;
USE tifosi;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE achete;
TRUNCATE TABLE contient;
TRUNCATE TABLE comprend;
TRUNCATE TABLE menu;
TRUNCATE TABLE client;
TRUNCATE TABLE boisson;
TRUNCATE TABLE focaccia;
TRUNCATE TABLE ingredient;
TRUNCATE TABLE marque;
SET FOREIGN_KEY_CHECKS = 1;


-- -----------------------------------------------------------------------------
-- Marques (marque.xlsx)
-- -----------------------------------------------------------------------------
INSERT INTO marque (id_marque, nom) VALUES
    (1, 'Coca-cola'),
    (2, 'Cristalline'),
    (3, 'Monster'),
    (4, 'Pepsico');


-- -----------------------------------------------------------------------------
-- Boissons (boisson.xlsx) — id_marque issu de la colonne « marque »
-- -----------------------------------------------------------------------------
INSERT INTO boisson (id_boisson, nom, id_marque) VALUES
    (1,  'Coca-cola zéro',              1),
    (2,  'Coca-cola original',          1),
    (3,  'Fanta citron',                1),
    (4,  'Fanta orange',                1),
    (5,  'Capri-sun',                   1),
    (6,  'Pepsi',                       4),
    (7,  'Pepsi Max Zéro',              4),
    (8,  'Lipton zéro citron',          4),
    (9,  'Lipton Peach',                4),
    (10, 'Monster energy ultra gold',   3),
    (11, 'Monster energy ultra blue',   3),
    (12, 'Eau de source',               2);


-- -----------------------------------------------------------------------------
-- Ingrédients (ingredient.xlsx)
-- -----------------------------------------------------------------------------
INSERT INTO ingredient (id_ingredient, nom) VALUES
    (1,  'Ail'),
    (2,  'Ananas'),
    (3,  'Artichaut'),
    (4,  'Bacon'),
    (5,  'Base Tomate'),
    (6,  'Base crème'),
    (7,  'Champignon'),
    (8,  'Chevre'),
    (9,  'Cresson'),
    (10, 'Emmental'),
    (11, 'Gorgonzola'),
    (12, 'Jambon cuit'),
    (13, 'Jambon fumé'),
    (14, 'Oeuf'),
    (15, 'Oignon'),
    (16, 'Olive noire'),
    (17, 'Olive verte'),
    (18, 'Parmesan'),
    (19, 'Piment'),
    (20, 'Poivre'),
    (21, 'Pomme de terre'),
    (22, 'Raclette'),
    (23, 'Salami'),
    (24, 'Tomate cerise'),
    (25, 'Mozarella');


-- -----------------------------------------------------------------------------
-- Focaccias (focaccia.xlsx — colonnes id, nom, prix)
-- -----------------------------------------------------------------------------
INSERT INTO focaccia (id_focaccia, nom, prix) VALUES
    (1, 'Mozaccia',        9.80),
    (2, 'Gorgonzollaccia', 10.80),
    (3, 'Raclaccia',       8.90),
    (4, 'Emmentalaccia',   9.80),
    (5, 'Tradizione',      8.90),
    (6, 'Hawaienne',       11.20),
    (7, 'Américaine',      10.80),
    (8, 'Paysanne',        12.80);


-- -----------------------------------------------------------------------------
-- Composition des focaccias (table comprend)
-- Quantités par défaut (en grammes), sauf indication contraire dans focaccia.xlsx :
--   Ail 2, Ananas 40, Artichaut 20, Bacon 80, Base Tomate 200, Base crème 200,
--   Champignon 40, Chevre 50, Cresson 20, Emmental 50, Gorgonzola 50,
--   Jambon cuit 80, Jambon fumé 80, Oeuf 50, Oignon 20, Olive noire 20,
--   Olive verte 20, Parmesan 50, Piment 2, Poivre 1, Pomme de terre 80,
--   Raclette 50, Salami 80, Tomate cerise 40, Mozarella 50
-- Exceptions notées dans le fichier :
--   Tradizione  : Champignon 80 g, Olive noire 10 g, Olive verte 10 g
--   Américaine  : Pomme de terre 40 g
-- -----------------------------------------------------------------------------

-- 1. Mozaccia : Base tomate, Mozarella, cresson, jambon fumé, ail,
--               artichaut, champignon, parmesan, poivre, olive noire
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (1,  5, 200),
    (1, 25,  50),
    (1,  9,  20),
    (1, 13,  80),
    (1,  1,   2),
    (1,  3,  20),
    (1,  7,  40),
    (1, 18,  50),
    (1, 20,   1),
    (1, 16,  20);

-- 2. Gorgonzollaccia : Base tomate, Gorgonzola, cresson, ail,
--                      champignon, parmesan, poivre, olive noire
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (2,  5, 200),
    (2, 11,  50),
    (2,  9,  20),
    (2,  1,   2),
    (2,  7,  40),
    (2, 18,  50),
    (2, 20,   1),
    (2, 16,  20);

-- 3. Raclaccia : Base tomate, raclette, cresson, ail, champignon, parmesan, poivre
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (3,  5, 200),
    (3, 22,  50),
    (3,  9,  20),
    (3,  1,   2),
    (3,  7,  40),
    (3, 18,  50),
    (3, 20,   1);

-- 4. Emmentalaccia : Base crème, Emmental, cresson, champignon, parmesan, poivre, oignon
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (4,  6, 200),
    (4, 10,  50),
    (4,  9,  20),
    (4,  7,  40),
    (4, 18,  50),
    (4, 20,   1),
    (4, 15,  20);

-- 5. Tradizione : Base tomate, Mozarella, cresson, jambon cuit,
--                 champignon (80), parmesan, poivre, olive noire (10), olive verte (10)
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (5,  5, 200),
    (5, 25,  50),
    (5,  9,  20),
    (5, 12,  80),
    (5,  7,  80),
    (5, 18,  50),
    (5, 20,   1),
    (5, 16,  10),
    (5, 17,  10);

-- 6. Hawaienne : Base tomate, Mozarella, cresson, bacon, ananas, piment,
--                parmesan, poivre, olive noire
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (6,  5, 200),
    (6, 25,  50),
    (6,  9,  20),
    (6,  4,  80),
    (6,  2,  40),
    (6, 19,   2),
    (6, 18,  50),
    (6, 20,   1),
    (6, 16,  20);

-- 7. Américaine : Base tomate, Mozarella, cresson, bacon,
--                 pomme de terre (40), parmesan, poivre, olive noire
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (7,  5, 200),
    (7, 25,  50),
    (7,  9,  20),
    (7,  4,  80),
    (7, 21,  40),
    (7, 18,  50),
    (7, 20,   1),
    (7, 16,  20);

-- 8. Paysanne : Base crème, Chèvre, cresson, pomme de terre, jambon fumé, ail,
--               artichaut, champignon, parmesan, poivre, olive noire, œuf
INSERT INTO comprend (id_focaccia, id_ingredient, quantite) VALUES
    (8,  6, 200),
    (8,  8,  50),
    (8,  9,  20),
    (8, 21,  80),
    (8, 13,  80),
    (8,  1,   2),
    (8,  3,  20),
    (8,  7,  40),
    (8, 18,  50),
    (8, 20,   1),
    (8, 16,  20),
    (8, 14,  50);


-- -----------------------------------------------------------------------------
-- Données de démonstration pour client / menu / contient / achete
-- (absentes des fichiers Excel, nécessaires pour respecter le MCD)
-- Prix menu = prix focaccia + 2,00 € par boisson incluse.
-- -----------------------------------------------------------------------------
INSERT INTO client (id_client, nom, email, code_postal) VALUES
    (1, 'Alice Martin',   'alice.martin@email.fr',   75001),
    (2, 'Bruno Dupont',   'bruno.dupont@email.fr',   69002),
    (3, 'Chloé Bernard',  'chloe.bernard@email.fr',  13001);

INSERT INTO menu (id_menu, nom, prix, id_focaccia) VALUES
    (1, 'Menu Mozaccia',   11.80, 1),
    (2, 'Menu Raclaccia',  10.90, 3),
    (3, 'Menu Paysanne',   16.80, 8),
    (4, 'Menu Hawaienne',  13.20, 6);

-- Menu Paysanne : 2 boissons (cardinalité 1,n de « contient » côté menu)
INSERT INTO contient (id_menu, id_boisson) VALUES
    (1, 2),
    (2, 12),
    (3, 1),
    (3, 10),
    (4, 4);

INSERT INTO achete (id_client, id_menu, date_achat) VALUES
    (1, 1, '2026-09-01'),
    (2, 3, '2026-09-10'),
    (3, 2, '2026-09-12'),
    (3, 4, '2026-09-15');


-- Réalignement des AUTO_INCREMENT après insertion d'identifiants explicites
ALTER TABLE marque     AUTO_INCREMENT = 5;
ALTER TABLE boisson    AUTO_INCREMENT = 13;
ALTER TABLE ingredient AUTO_INCREMENT = 26;
ALTER TABLE focaccia   AUTO_INCREMENT = 9;
ALTER TABLE client     AUTO_INCREMENT = 4;
ALTER TABLE menu       AUTO_INCREMENT = 5;


-- =============================================================================
-- Fin du script d'insertion
-- =============================================================================
