set serveroutput on;

CREATE OR REPLACE TYPE noteDistincteTip AS TABLE OF NUMBER;
/
set serveroutput on;
ALTER TABLE studenti
  ADD notedistincte noteDistincteTip NESTED TABLE notedistincte STORE AS tabela_note_distincte;
/
set serveroutput on;

DECLARE 
   CURSOR cursor_new IS SELECT id FROM studenti FOR UPDATE OF notedistincte;
    total studenti.notedistincte%TYPE;
BEGIN
  FOR linie in cursor_new LOOP
   SELECT DISTINCT valoare BULK COLLECT INTO total FROM note WHERE id_student=linie.id;
    UPDATE studenti set notedistincte=total WHERE CURRENT OF cursor_new;
    end loop;
END;