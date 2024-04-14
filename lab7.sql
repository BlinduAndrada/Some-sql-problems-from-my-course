CREATE OR REPLACE TYPE profesor_facultate AS OBJECT
(nume varchar2(10),
 prenume varchar2(10),
 gradul_didactic varchar2(10),

 MEMBER FUNCTION media_notelor return NUMBER,
 map member function compare_nume return NUMBER,
 
CONSTRUCTOR FUNCTION profesor_facultate(nume varchar2, prenume varchar2, gradul_didactic varchar2)
    RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY profesor_facultate AS
   MEMBER function media_notelor return number is media number;
   BEGIN
      SELECT AVG(valoare) INTO media FROM profesori p JOIN didactic d ON p.id=d.id_profesor JOIN note n ON d.id_curs=n.id_curs WHERE UPPER(SELF.nume)=UPPER(p.nume) AND UPPER(SELF.prenume)=UPPER(p.prenume);
      RETURN media; 
      END media_notelor;


map member function compare_nume return number is 
BEGIN
 
        RETURN LENGTH(SELF.nume);

END;


CONSTRUCTOR FUNCTION profesor_facultate(nume varchar2, prenume varchar2, gradul_didactic varchar2)RETURN SELF AS RESULT AS
    BEGIN
        SELF.nume := nume;
        SELF.prenume := prenume;
        SELF.gradul_didactic := gradul_didactic;
        RETURN;
        END;
END;

drop table profesori1;
create table profesori1 (obiect profesor_facultate);

DECLARE
    v_profesor1 PROFESOR_FACULTATE;
    v_profesor2 PROFESOR_FACULTATE;
    v_profesor3 PROFESOR_FACULTATE;
BEGIN
    v_profesor1 := PROFESOR_FACULTATE('Hostiuc', 'Valeriu', 'Colab');
    v_profesor2 := PROFESOR_FACULTATE('Motrescu', 'Stefaniaa', 'Asistent');
    v_profesor3 := PROFESOR_FACULTATE('Matei','Alexandra','Profesor');
    dbms_output.put_line(v_profesor1.nume);
    dbms_output.put_line(v_profesor2.media_notelor);
    insert into profesori1 values (v_profesor1);
    insert into profesori1 values (v_profesor2);
    insert into profesori1 values (v_profesor3);
END;

/


/

set serveroutput on; 

SELECT TREAT(obiect AS profesor_facultate).nume, TREAT(obiect AS profesor_facultate).prenume, TREAT(obiect AS profesor_facultate).media_notelor(), (SELECT COUNT(*) FROM profesori p JOIN didactic d ON p.id=d.id_profesor WHERE TREAT(obiect AS profesor_facultate).nume=p.nume) AS materii_predate FROM profesori1 ORDER BY obiect;