set serveroutput on;

DECLARE 
   CURSOR cursor_new IS SELECT id FROM studenti FOR UPDATE OF note_distincte;
    total studenti.note_distincte%TYPE;
    cursor_empty BOOLEAN := TRUE;
    cursor_open_success BOOLEAN := FALSE;
BEGIN

BEGIN
OPEN cursor_new;
      cursor_open_success := TRUE;
      
   END;
  FOR linie in cursor_new LOOP
  cursor_empty := FALSE;
  total := NULL;
   SELECT DISTINCT valoare BULK COLLECT INTO total FROM note WHERE id_student=linie.id;
    IF total IS NULL THEN
     raise_application_error (-20001, 'Studentul ' || linie.id || ' nu are note distincte.');
      ELSE
    UPDATE studenti set note_distincte=total WHERE CURRENT OF cursor_new;
    END IF;
    end loop;
    IF NOT cursor_empty THEN
     CLOSE cursor_new;
     ELSE
      raise_application_error (-20002, 'Cursorul nu a returnat nicio inregistrare.');
   END IF;
   
   END IF;
   IF NOT cursor_open_success THEN
    raise_application_error(-20003, 'Eroare la deschiderea cursorului: ');
    EXCEPTION
WHEN no_data_found THEN
  raise_application_error (-20005, 'Nu s-au gasit note pentru un student.');

 
END;