-- we need this to be done to our db first by user 'postgres':  create extension "uuid-ossp";
-- if that didnt work, we may need to install this first:  apt-get install postgresql-contrib-9.5


ALTER TABLE "MARKEDINDIVIDUAL" ADD COLUMN "LEGACYINDIVIDUALID" VARCHAR(100) UNIQUE;
ALTER TABLE "MARKEDINDIVIDUAL" ALTER COLUMN "INDIVIDUALID" SET DEFAULT uuid_generate_v4();

-- now we "store" legacy values in LEGACYINDIVIDUALID
UPDATE "MARKEDINDIVIDUAL" SET "LEGACYINDIVIDUALID" = "INDIVIDUALID";

-- this allows us to alter individualid primary key on markedindividual
BEGIN;
ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" DROP CONSTRAINT "SHARK_ENCOUNTERS_FK1";
ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" ADD CONSTRAINT "SHARK_ENCOUNTERS_FK1" FOREIGN KEY ("INDIVIDUALID_OID") REFERENCES "MARKEDINDIVIDUAL"("INDIVIDUALID") ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;
END;

-- h/t  https://gist.github.com/scaryguy/6269293

-- we cant straight up drop the primary key constraint on MARKEDINDIVIDUAL due to foreign key constraints...

--ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" DROP CONSTRAINT "SHARK_ENCOUNTERS_pkey";
--ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" DROP CONSTRAINT "SHARK_ENCOUNTERS_FK1";

-- this table seems to only appear on some (ancient?) wildbooks... i think the functionality is gone, so we dont
--  do any other cleanup of id-mapping etc here.  dont worry if you get an error about this
ALTER TABLE "MARKEDINDIVIDUAL_UNIDENTIFIABLEENCOUNTERS" DROP CONSTRAINT "SHARK_LOGENCOUNTERS_FK1";


UPDATE "MARKEDINDIVIDUAL" SET "INDIVIDUALID" = uuid_generate_v4();
-- ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" ADD COLUMN "ID_OID" VARCHAR(36);
-- CREATE INDEX "MARKEDINDIVIDUAL_ENCOUNTERS_ID_idx" ON "MARKEDINDIVIDUAL_ENCOUNTERS" ("ID_OID");

-- now this updates the join table to have the new ID_OID populated based on corresponding MARKEDINDIVIDUAL
-- h/t  https://stackoverflow.com/a/2766766
--UPDATE "MARKEDINDIVIDUAL_ENCOUNTERS" AS b SET "ID_OID" = a."ID" FROM "MARKEDINDIVIDUAL" AS a WHERE a."INDIVIDUALID" = b."INDIVIDUALID_OID";

-- remove old primary key, and add new
--ALTER TABLE "MARKEDINDIVIDUAL" DROP CONSTRAINT "MARKEDINDIVIDUAL_pkey";
--ALTER TABLE "MARKEDINDIVIDUAL" ADD PRIMARY KEY ("ID");

-- now add in the new primary key on join table, based on ID & IDX
--ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" ADD PRIMARY KEY ("ID_OID", "IDX");

-- with this populated from above, we can now build a foreign key constraint
--ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" ADD CONSTRAINT "MARKEDINDIVIDUAL_ENCOUNTERS_FK3" FOREIGN KEY ("ID_OID") REFERENCES "MARKEDINDIVIDUAL"("ID") DEFERRABLE INITIALLY DEFERRED;


-- drop not null constraint on this column in join table since it will be empty going forward
--  (technically we sh/could drop it altogether)
--ALTER TABLE "MARKEDINDIVIDUAL_ENCOUNTERS" ALTER COLUMN "INDIVIDUALID_OID" DROP NOT NULL;


-- now lets update other places that need to know our new ids
-- NOTE: these fields should probably (or are) be deprecated, in favor of propery obj reference
UPDATE "ENCOUNTER" AS b SET "INDIVIDUALID" = a."INDIVIDUALID" FROM "MARKEDINDIVIDUAL" AS a WHERE a."LEGACYINDIVIDUALID" = b."INDIVIDUALID";
UPDATE "ADOPTION" AS b SET "INDIVIDUAL" = a."INDIVIDUALID" FROM "MARKEDINDIVIDUAL" AS a WHERE a."LEGACYINDIVIDUALID" = b."INDIVIDUAL";


-- this one "would be nice", except fails if (when) there is a bunk indiv id on an encounter.  add after manual cleanup
-- ALTER TABLE "ENCOUNTER" ADD CONSTRAINT "ENCOUNTER_INDIVIDUALID_FK_NEW" FOREIGN KEY ("INDIVIDUALID") REFERENCES "MARKEDINDIVIDUAL"("ID") DEFERRABLE INITIALLY DEFERRED;



--- TODO migrate the old INDIVIDUALID and ALTERNATEID(s) TO NAMES (MultiValue) !!!!!!!!!!!!!!  FIXME
---  note: this is now done via appadmin/migrateMarkedIndividualNames.jsp



--update RELATIONSHIP to point instead to indiv uuids
UPDATE "RELATIONSHIP" AS b SET "MARKEDINDIVIDUALNAME1" = a."INDIVIDUALID" FROM "MARKEDINDIVIDUAL" AS a WHERE a."LEGACYINDIVIDUALID" = b."MARKEDINDIVIDUALNAME1";
UPDATE "RELATIONSHIP" AS b SET "MARKEDINDIVIDUALNAME2" = a."INDIVIDUALID" FROM "MARKEDINDIVIDUAL" AS a WHERE a."LEGACYINDIVIDUALID" = b."MARKEDINDIVIDUALNAME2";


-- cuz we probably should have these.
CREATE INDEX "RELATIONSHIP_MARKEDINDIVIDUALNAME1_idx" ON "RELATIONSHIP" ("MARKEDINDIVIDUALNAME1");
CREATE INDEX "RELATIONSHIP_MARKEDINDIVIDUALNAME2_idx" ON "RELATIONSHIP" ("MARKEDINDIVIDUALNAME2");
CREATE INDEX "RELATIONSHIP_MARKEDINDIVIDUALROLE1_idx" ON "RELATIONSHIP" ("MARKEDINDIVIDUALROLE1");
CREATE INDEX "RELATIONSHIP_MARKEDINDIVIDUALROLE2_idx" ON "RELATIONSHIP" ("MARKEDINDIVIDUALROLE2");
CREATE INDEX "RELATIONSHIP_TYPE_idx" ON "RELATIONSHIP" ("TYPE");



-- flukebook had a single RELATIONSHIP with an empty-string id in it, which fubared the constraints (below)
--  use this under your own discretion  etc.   (might want to do NULL as well?)
DELETE FROM "RELATIONSHIP" WHERE "MARKEDINDIVIDUALNAME1" = '' OR "MARKEDINDIVIDUALNAME2" ='';

-- these foreign key constraints would be nice, provided they dont fail.... sigh
ALTER TABLE "RELATIONSHIP" ADD CONSTRAINT "RELATIONSHIP_FK1" FOREIGN KEY ("MARKEDINDIVIDUALNAME1") REFERENCES "MARKEDINDIVIDUAL"("INDIVIDUALID") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "RELATIONSHIP" ADD CONSTRAINT "RELATIONSHIP_FK2" FOREIGN KEY ("MARKEDINDIVIDUALNAME2") REFERENCES "MARKEDINDIVIDUAL"("INDIVIDUALID") DEFERRABLE INITIALLY DEFERRED;


