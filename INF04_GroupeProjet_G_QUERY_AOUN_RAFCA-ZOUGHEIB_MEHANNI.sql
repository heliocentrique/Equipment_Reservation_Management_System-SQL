-- Les Requetes (Question 5) --



-- Requete 1 : Quelles sont les catégories de matériel réservés par l’employé ’Martin’ ?
SELECT DISTINCT libelle_categorie
FROM Categorie 
JOIN Materiel  USING (id_categorie)
JOIN Exemplaire  USING (id_materiel)
JOIN Reservation  USING (id_exemplaire)
JOIN Employe  USING (id_employe)
WHERE nom_employe = 'Martin';



-- Requete 2 : Quels employés ont réservé l’appareil photo compact (id_materiel=37) ET l’appareil photo reflex (id_materiel=38) ?
SELECT nom_employe
FROM Employe 
JOIN Reservation  USING (id_employe)
JOIN Exemplaire  USING (id_exemplaire)
WHERE id_materiel = 37
INTERSECT 
SELECT nom_employe
FROM Employe 
JOIN Reservation  USING (id_employe)
JOIN Exemplaire  USING (id_exemplaire)
WHERE id_materiel = 38;



-- Requete 3 : Combien d’employés ont réservé l’un OU l’autre des appareils photo ?
SELECT COUNT(DISTINCT id_employe) AS nombre_employes
FROM Employe
JOIN Reservation  USING (id_employe)
JOIN Exemplaire  USING (id_exemplaire)
WHERE id_materiel IN (37, 38);



-- Requete 4 : Quels employés n’ont rien réservé ?
SELECT nom_employe
FROM Employe
WHERE id_employe IN ( SELECT id_employe FROM Employe_base
					EXCEPT 
					SELECT id_employe FROM Reservation);



-- Requete 5 : Employés ayant réservé au moins un matériel de chaque catégorie
SELECT nom_employe, id_employe
FROM Employe
JOIN Reservation USING (id_employe)
JOIN Exemplaire USING (id_exemplaire)
JOIN Materiel USING (id_materiel)
GROUP BY id_employe, nom_employe
HAVING COUNT(DISTINCT id_categorie) = (SELECT COUNT(*) FROM Categorie);



-- Requete 6 : Nombre d’exemplaires de chaque matériel
SELECT id_materiel, libelle_materiel, COUNT(id_exemplaire)  AS nombre_exemplaires
   FROM Materiel JOIN Exemplaire USING (id_materiel)
   GROUP BY id_materiel, libelle_materiel;


   
-- Requete 7 : Employés avec au moins 60 réservations
SELECT nom_employe, COUNT(id_reservation) AS nombre_reservations
FROM Employe 
JOIN Reservation USING (id_employe)
GROUP BY id_employe, nom_employe
HAVING COUNT(id_reservation) >= 60;



-- Requete 8 : Employés ayant emprunté la perceuse (id=20) au moins 2 fois
SELECT nom_employe, id_employe, COUNT(id_reservation) AS nombre_emprunts_perceuse
FROM Employe
JOIN Reservation USING (id_employe)
JOIN Exemplaire USING(id_exemplaire)
WHERE id_materiel = 20
  AND dateEmprunt_reservation IS NOT NULL 
GROUP BY id_employe, nom_employe
HAVING COUNT(id_reservation) >= 2;



-- Requete 9 : Matériel réservé le plus longtemps (en une seule réservation)
WITH DureesReservation AS (
    SELECT id_materiel, libelle_materiel,
        JULIANDAY(dateFin_reservation) - JULIANDAY(dateDebut_reservation) AS duree_jours
    FROM Reservation 
    JOIN Exemplaire  USING(id_exemplaire)
    JOIN Materiel  USING(id_materiel)
    WHERE dateDebut_reservation IS NOT NULL AND dateFin_reservation IS NOT NULL
      AND JULIANDAY(dateFin_reservation) IS NOT NULL
      AND JULIANDAY(dateDebut_reservation) IS NOT NULL)
SELECT DISTINCT libelle_materiel, duree_jours
FROM DureesReservation 
WHERE duree_jours = (SELECT MAX(duree_jours) FROM DureesReservation);



-- Requete 10 : Exemplaire le plus réservé (et son matériel)
WITH CompteReservationsExemplaire AS (
    SELECT id_exemplaire, COUNT(*) as nb_reservations
    FROM Reservation
    GROUP BY id_exemplaire)
SELECT id_exemplaire, libelle_materiel, nb_reservations
FROM CompteReservationsExemplaire 
JOIN Exemplaire USING(id_exemplaire)
JOIN Materiel USING (id_materiel)
WHERE nb_reservations = (SELECT MAX(nb_reservations) FROM CompteReservationsExemplaire);
  