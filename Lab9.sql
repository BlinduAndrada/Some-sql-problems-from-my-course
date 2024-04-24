set serveroutput on;
commit;

CREATE OR REPLACE VIEW profesori_prieteni AS 
    SELECT p1.nume AS "n1", p1.prenume AS "p1", p2.nume AS "n2", p2.prenume AS "p2", c.titlu_curs AS "titlu_curs"
    FROM profesori p1 
        JOIN didactic d1 ON p1.id = d1.id_profesor
        JOIN didactic d2 ON d1.id_curs = d2.id_curs
        JOIN profesori p2 ON d2.id_profesor = p2.id
        JOIN cursuri c ON c.id = d1.id_curs
    WHERE p1.id > p2.id;
        
SELECT * FROM profesori_prieteni;

CREATE OR REPLACE TRIGGER insert_profesori_prieteni_trigger INSTEAD OF INSERT ON profesori_prieteni
DECLARE
    id_prof1 profesori.id%TYPE;
    id_prof2 profesori.id%TYPE;
    max_id_prof NUMBER;
    v_nr_cursuri_comune NUMBER;
    v_curs_id cursuri.id%TYPE;
  
BEGIN
    --pentru profesor 1
    BEGIN
        SELECT id INTO id_prof1  FROM profesori  WHERE nume = :NEW.n1 AND prenume = :NEW.p1;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                id_prof1 := NULL;
    END;
    
    IF id_prof1 IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Inserting profesor');
        SELECT MAX(id) INTO max_id_prof FROM profesori;
        INSERT INTO profesori VALUES (max_id_prof+1, :NEW.n1, :NEW.p1);
        id_prof1 := max_id_prof + 1;
    END IF;
    
    
    --pentru profesor 2
    BEGIN
     SELECT id INTO id_prof2  FROM profesori  WHERE nume = :NEW.n2 AND prenume = :NEW.p2;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                id_prof2 := NULL;
                
        END;
         IF id_prof2 IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Inserting profesor');
        SELECT MAX(id) INTO max_id_prof FROM profesori;
        INSERT INTO profesori VALUES (max_id_prof+1, :NEW.n2, :NEW.p2);
        id_prof1 := max_id_prof + 1;
    END IF;
        
        --pentru cursuri comune
        BEGIN
        
    
    SELECT COUNT(*) INTO v_nr_cursuri_comune
    FROM didactic
    WHERE id_profesor = id_prof1 AND id_curs = :NEW.id_curs
    AND id_profesor = id_prof2 AND id_curs = :NEW.id_curs;
    
    IF v_nr_cursuri_comune > 1 THEN
    DBMS_OUTPUT.PUT_LINE('Profesorii ' || :NEW.n1 || ' ' || :NEW.p1 ||
                             ' si ' || :NEW.n2 || ' ' || :NEW.p2 || 
                             ' predau mai mult de un curs comun.');
        DBMS_OUTPUT.PUT_LINE('Cursurile comune sunt:');
        
        FOR curs_rec IN (SELECT c.titlu_curs
                         FROM cursuri c
                         JOIN didactic d ON c.id = d.id_curs
                         WHERE d.id_profesor = id_prof1 AND d.id_curs = :NEW.id_curs
                         AND d.id_profesor = id_prof2 AND d.id_curs = :NEW.id_curs)
        LOOP
            DBMS_OUTPUT.PUT_LINE(curs_rec.titlu_curs);
        END LOOP;
       END IF; 
    END;
   
END;
/

INSERT INTO profesori_prieteni (nume1, prenume1, nume2, prenume2, id_curs) VALUES ('Popescu', 'Ion', 'Ionescu', 'Maria', 1);
INSERT INTO profesori_prieteni (nume1, prenume1, nume2, prenume2, id_curs) VALUES ('Popescu', 'Ion', 'Georgescu', 'Alex', 2);
INSERT INTO profesori_prieteni (nume1, prenume1, nume2, prenume2, id_curs) VALUES ('Ionescu', 'Maria', 'Georgescu', 'Alex', 1);
/

SELECT * FROM profesori_prieteni;
/

rollback;