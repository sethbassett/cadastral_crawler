--modifications to be made to vm db
--ALTER TABLE parcels_2018 ADD COLUMN noname VARCHAR;
--UPDATE parcels_2018 SET noname = replace(oname, ' ', '');
--UPDATE parcels_2018 SET noname = replace(oname, '.', '');

DROP INDEX parcels_2018_nocat;
DROP INDEX parcels_2018_oname;

UPDATE parcels_2018
  SET oname = replace(oname, '''', '');

UPDATE parcels_2018
  SET nocat = replace(nocat, '''', '');

UPDATE parcels_2018
  SET nocat = replace(nocat, '.', '');

UPDATE parcels_2018
  SET nocat = replace(nocat, '#', '');

CREATE INDEX parcels_2018_nocat on parcels_2018 (nocat);
CREATE INDEX parcels_2018_oname ON parcels_2018 (oname);




SELECT regexp_replace(ocat, '\w', '') FROM parcels_2018 LIMIT 50;
