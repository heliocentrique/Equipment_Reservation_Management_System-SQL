--	Drops --
DROP VIEW IF EXISTS Employe;
DROP VIEW IF EXISTS Materiel;

DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Exemplaire;
DROP TABLE IF EXISTS Indisponibilite;
DROP TABLE IF EXISTS Materiel_base;
DROP TABLE IF EXISTS Categorie;
DROP TABLE IF EXISTS Employe_base;
DROP TABLE IF EXISTS SousCategorie;





--  Création des tables -- 
CREATE TABLE Employe_base (
  id_employe INTEGER NOT NULL,
  nom_employe TEXT NOT NULL,
  mail_employe TEXT NOT NULL,
  telephone_employe TEXT,
  CONSTRAINT pk_employe_base PRIMARY KEY (id_employe)
);



CREATE TABLE Categorie (
  id_categorie INTEGER NOT NULL,
  libelle_categorie TEXT NOT NULL UNIQUE,
  nbEmpruntsMax_categorie INTEGER NOT NULL,
  id_categorie_parent INTEGER,
  CONSTRAINT pk_categorie PRIMARY KEY (id_categorie),
  CONSTRAINT fk_categorie_id_categorie FOREIGN KEY (id_categorie_parent) REFERENCES Categorie(id_categorie)
);



CREATE TABLE Materiel_base (
  id_materiel INTEGER NOT NULL,
  libelle_materiel TEXT NOT NULL,
  id_categorie INTEGER NOT NULL,
  CONSTRAINT pk_material_base PRIMARY KEY (id_materiel),
  CONSTRAINT fk_materiel_base_id_categorie FOREIGN KEY (id_categorie) REFERENCES Categorie(id_categorie)
);



CREATE TABLE Indisponibilite (
    id_indisponibilite INTEGER NOT NULL,
    description TEXT NOT NULL,
	CONSTRAINT pk_indisponibilite_id_indisponibilite  PRIMARY KEY (id_indisponibilite),
	CONSTRAINT ch_indisponibilite CHECK(description IN ('panne', 'maintenance', 'perdu'))
);


CREATE TABLE Exemplaire (
  id_exemplaire INTEGER NOT NULL,
  etat_exemplaire TEXT NOT NULL,
  id_materiel INTEGER NOT NULL,
  id_indisponibilite INTEGER,
  CONSTRAINT pk_exemplaire  PRIMARY KEY (id_exemplaire),
  CONSTRAINT fk_exemplaire_id_materiel FOREIGN KEY (id_materiel) REFERENCES Materiel_base(id_materiel),
  CONSTRAINT fk_exemplaire_id_indisponibilite FOREIGN KEY (id_indisponibilite) REFERENCES Indisponibilite(id_indisponibilite),
  CONSTRAINT ch_exemplaire_etat_exemplaire CHECK (etat_exemplaire IN ('neuf', 'bon', 'moyen', 'defectueux'))
);



CREATE TABLE Reservation (
  id_reservation INTEGER PRIMARY KEY AUTOINCREMENT,
  dateDebut_reservation TEXT NOT NULL,
  dateFin_reservation TEXT NOT NULL,
  dateEmprunt_reservation TEXT,
  dateRetourEffective_reservation TEXT,
  id_exemplaire INTEGER NOT NULL,
  id_employe INTEGER NOT NULL,
  CONSTRAINT fk_reservation_id_exemplaire FOREIGN KEY (id_exemplaire) REFERENCES Exemplaire(id_exemplaire),
  CONSTRAINT fk_reservation_id_employe FOREIGN KEY (id_employe) REFERENCES Employe_base(id_employe),
  CONSTRAINT ch_reservation_1 CHECK (dateEmprunt_reservation >= dateDebut_reservation),
  CONSTRAINT ch_reservation_2 CHECK (dateEmprunt_reservation <= dateFin_reservation),
  CONSTRAINT ch_reservation_3 CHECK (dateRetourEffective_reservation >= dateEmprunt_reservation)
);



CREATE TABLE SousCategorie (
  id_sous_categorie INTEGER NOT NULL,
  id_categorie_parent INTEGER NOT NULL,
  CONSTRAINT pk_souscategorie_id_sous_categorie PRIMARY KEY (id_sous_categorie),
  CONSTRAINT fk_souscategorie_id_sous_categorie_categorie FOREIGN KEY (id_sous_categorie) REFERENCES Categorie(id_categorie),
  CONSTRAINT fk_souscategorie_id_sous_categorie_parent FOREIGN KEY (id_categorie_parent) REFERENCES Categorie(id_categorie)
);




 
-- vues --
CREATE VIEW Employe AS
SELECT e.id_employe, e.nom_employe, e.mail_employe, e.telephone_employe,
		(SELECT COUNT(*)
		FROM Reservation r
		WHERE r.id_employe = e.id_employe 
		AND r.dateEmprunt_reservation IS NOT NULL AND r.dateRetourEffective_reservation IS NULL) AS nbEmpruntsEnCours_employe
FROM Employe_base e; 
  
  

CREATE VIEW Materiel AS
SELECT m.id_materiel, m.libelle_materiel, m.id_categorie, 
		(SELECT COUNT(*)
		FROM Reservation 
		JOIN Exemplaire ex USING (id_exemplaire)
		WHERE ex.id_materiel = m.id_materiel 
		AND dateEmprunt_reservation IS NOT NULL 
		AND dateRetourEffective_reservation IS NULL ) AS nbEmpruntsEnCours_materiel
FROM Materiel_base m; 





-- Insertion --
INSERT INTO Categorie (id_categorie, libelle_categorie, nbEmpruntsMax_categorie)
SELECT id_categorie, MIN(libelle_categorie), MIN(nb_emprunt_max)
FROM Resa
WHERE id_categorie IS NOT NULL AND libelle_categorie IS NOT NULL AND nb_emprunt_max IS NOT NULL
GROUP BY id_categorie;



INSERT INTO Employe_base (id_employe, nom_employe, mail_employe, telephone_employe)
SELECT DISTINCT id_employe, nom_employe, mail, tel
FROM Resa
WHERE id_employe IS NOT NULL AND nom_employe IS NOT NULL;



INSERT INTO Materiel_base (id_materiel, libelle_materiel, id_categorie)
SELECT DISTINCT id_materiel, libelle_materiel, id_categorie
FROM Resa
WHERE id_materiel IS NOT NULL AND libelle_materiel IS NOT NULL AND id_categorie IS NOT NULL;



INSERT INTO Indisponibilite (id_indisponibilite, description)
SELECT DISTINCT id_indisponibilite, description_indisponibilite
FROM Resa 
WHERE id_indisponibilite IS NOT NULL AND description_indisponibilite IS NOT NULL;



INSERT INTO Exemplaire (id_exemplaire, id_materiel, etat_exemplaire)
SELECT DISTINCT id_exemplaire, id_materiel, etat 
FROM Resa 
WHERE id_exemplaire IS NOT NULL;


  
INSERT INTO Reservation ( dateDebut_reservation, dateFin_reservation, dateEmprunt_reservation, dateRetourEffective_reservation, id_exemplaire, id_employe)
SELECT date_debut, date_fin, date_emprunt, date_retour, id_exemplaire, id_employe
FROM Resa
WHERE date_debut IS NOT NULL AND date_fin IS NOT NULL AND id_exemplaire IS NOT NULL AND id_employe IS NOT NULL;




