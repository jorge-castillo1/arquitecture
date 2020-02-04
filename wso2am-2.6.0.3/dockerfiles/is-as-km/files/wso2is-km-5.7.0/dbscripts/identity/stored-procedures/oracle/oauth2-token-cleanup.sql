CREATE OR REPLACE PROCEDURE WSO2_TOKEN_CLEANUP_SP IS

-- ------------------------------------------
-- CONFIGURABLE ATTRIBUTES
-- ------------------------------------------

batchSize INT := 10000;
backupTables BOOLEAN := TRUE;  -- SET IF TOKEN TABLE NEEDS TO BACKUP BEFORE DELETE     [DEFAULT : TRUE]
sleepTime FLOAT :=10;  -- SET SLEEP TIME FOR AVOID TABLE LOCKS     [DEFAULT : 2]
safePeriod INT := 2; -- SET SLEEP TIME FOR AVOID TABLE LOCKS     [DEFAULT 2 in hours]
utcTime TIMESTAMP := sys_extract_utc(systimestamp);
deleteTimeLimit TIMESTAMP := utcTime-safePeriod/24; -- SET CURRENT TIME - safePeriod FOR BEGIN THE TOKEN DELETE
ROWCOUNT INT := 0;
enableLog BOOLEAN := FALSE ; -- ENABLE LOGGING [DEFAULT : FALSE]
logLevel VARCHAR(10) := 'TRACE'; -- SET LOG LEVELS : TRACE , DEBUG
enableAudit BOOLEAN := FALSE; -- SET TRUE FOR  KEEP TRACK OF ALL THE DELETED TOKENS USING A TABLE    [DEFAULT : FALSE]


BEGIN


IF (backupTables)
THEN
    DBMS_OUTPUT.PUT_LINE('TABLE BACKUP STARTED ... !');
-- ------------------------------------------------------
-- BACKUP IDN_OAUTH2_ACCESS_TOKEN TABLE
-- ------------------------------------------------------

 SELECT COUNT(1) INTO ROWCOUNT FROM USER_TABLES WHERE TABLE_NAME = UPPER('IDN_OAUTH2_ACCESS_TOKEN_BAK');
   if (ROWCOUNT = 1)
    THEN
       EXECUTE IMMEDIATE 'DROP TABLE IDN_OAUTH2_ACCESS_TOKEN_BAK';
       COMMIT;
   END if;


    IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
    THEN
    SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_ACCESS_TOKEN;
    DBMS_OUTPUT.PUT_LINE('DEBUG LOG << BACKING UP IDN_OAUTH2_ACCESS_TOKEN TOKENS :'|| ROWCOUNT);
    END IF;


    IF (enableLog AND logLevel IN ('TRACE') )
    THEN
     DBMS_OUTPUT.PUT_LINE('TRACE LOG << BACKING UP IDN_OAUTH2_ACCESS_TOKEN TOKENS INTO IDN_OAUTH2_ACCESS_TOKEN_BAK TABLE ...');
    END IF;

    EXECUTE IMMEDIATE 'CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN_BAK AS (SELECT * FROM IDN_OAUTH2_ACCESS_TOKEN)';
    COMMIT;

    IF (enableLog  AND logLevel IN ('TRACE') )
    THEN
     DBMS_OUTPUT.PUT_LINE('TRACE LOG << BACKING UP IDN_OAUTH2_ACCESS_TOKEN_BAK COMPLETED !');
    END IF;

-- ------------------------------------------------------
-- BACKUP IDN_OAUTH2_AUTHORIZATION_CODE TABLE
-- ------------------------------------------------------


 SELECT COUNT(*) INTO ROWCOUNT from user_tables where table_name = upper('IDN_OATH_AUTH_CODE_BAK');
   IF (ROWCOUNT = 1) then
       EXECUTE IMMEDIATE 'DROP TABLE IDN_OATH_AUTH_CODE_BAK';
        COMMIT;
   END if;


--
   IF (enableLog  AND logLevel IN ('DEBUG','TRACE') )
   THEN
   SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_AUTHORIZATION_CODE;
       DBMS_OUTPUT.PUT_LINE('DEBUG LOG <<  BACKING UP IDN_OAUTH2_AUTHORIZATION_CODE TOKENS :'|| ROWCOUNT);
   END IF;
--
   IF (enableLog  AND logLevel IN ('TRACE') )
   THEN
       DBMS_OUTPUT.PUT_LINE('TRACE LOG << BACKING UP IDN_OAUTH2_AUTHORIZATION_CODE TOKENS INTO IDN_OATH_AUTH_CODE_BAK TABLE ...');
   END IF;


  EXECUTE IMMEDIATE 'CREATE TABLE IDN_OATH_AUTH_CODE_BAK AS (SELECT * FROM IDN_OAUTH2_AUTHORIZATION_CODE)';
  COMMIT;

   IF (enableLog  AND logLevel IN ('TRACE') )
   THEN
        DBMS_OUTPUT.PUT_LINE('TRACE LOG << BACKING UP IDN_OATH_AUTH_CODE_BAK COMPLETED !');
   END IF;
--
   DBMS_OUTPUT.PUT_LINE('INFO LOG << TABLE BACKUP COMPLETED !');

END IF;


-- ------------------------------------------------------
-- CREATING IDN_OAUTH2_ACCESS_TOK_AUDIT FOR DELETING TOKENS
-- ------------------------------------------------------
IF (enableAudit)
THEN

SELECT count(1) into ROWCOUNT FROM user_tables where table_name = 'IDN_OAUTH2_ACCESS_TOK_AUDIT';
  IF (ROWCOUNT =0 )
  THEN
        EXECUTE IMMEDIATE 'CREATE TABLE IDN_OAUTH2_ACCESS_TOK_AUDIT as (SELECT * FROM IDN_OAUTH2_ACCESS_TOKEN WHERE 1 = 2)';
         COMMIT;
  END IF;

SELECT count(1) into ROWCOUNT FROM user_tables where table_name = 'IDN_OAUTH2_AUTH_CODE_AUDIT';
  IF (ROWCOUNT = 0)
  THEN
       EXECUTE IMMEDIATE 'CREATE TABLE IDN_OAUTH2_AUTH_CODE_AUDIT as (SELECT * FROM IDN_OAUTH2_AUTHORIZATION_CODE WHERE 1 = 2)';
        COMMIT;
  END IF;

END IF;
--
--
---- ------------------------------------------------------
---- BATCH DELETE IDN_OAUTH2_ACCESS_TOKEN
---- ------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('BATCH DELETE ON IDN_OAUTH2_ACCESS_TOKEN STARTED .... !');

IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
   SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_ACCESS_TOKEN;
   DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS ON IDN_OAUTH2_ACCESS_TOKEN TABLE BEFORE DELETE : '||ROWCOUNT);
END IF;
--
IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
  SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_ACCESS_TOKEN WHERE TOKEN_STATE IN ('EXPIRED','INACTIVE','REVOKED') OR 
    (TOKEN_STATE = 'ACTIVE' AND 
          VALIDITY_PERIOD < 99999999999000 AND
        REFRESH_TOKEN_VALIDITY_PERIOD < 99999999999000 AND
        (deleteTimeLimit > (TIME_CREATED +  NUMTODSINTERVAL( VALIDITY_PERIOD / 60000, 'MINUTE' ))  ) AND 
        (deleteTimeLimit > (REFRESH_TOKEN_TIME_CREATED +  NUMTODSINTERVAL( REFRESH_TOKEN_VALIDITY_PERIOD / 60000, 'MINUTE' )))
    );

   DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS SHOULD BE DELETED FROM IDN_OAUTH2_ACCESS_TOKEN : '||ROWCOUNT);
END IF;
----
IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
  SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_ACCESS_TOKEN WHERE TOKEN_STATE = 'ACTIVE' AND
  VALIDITY_PERIOD < 99999999999000 AND
    REFRESH_TOKEN_VALIDITY_PERIOD < 99999999999000 AND
  (
    (deleteTimeLimit < (TIME_CREATED +  NUMTODSINTERVAL( VALIDITY_PERIOD / 60000, 'MINUTE' )))  OR 
    (deleteTimeLimit < (REFRESH_TOKEN_TIME_CREATED +  NUMTODSINTERVAL( REFRESH_TOKEN_VALIDITY_PERIOD / 60000, 'MINUTE' )))
  );
  DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS SHOULD BE RETAIN IN IDN_OAUTH2_ACCESS_TOKEN : '||ROWCOUNT);
END IF;
----
----
----
ROWCOUNT:= 1;

LOOP
IF ((ROWCOUNT > 0))
THEN
  DBMS_LOCK.SLEEP(sleepTime);
DBMS_OUTPUT.PUT_LINE('INFO LOG  << SLEEPING .... !');
END IF;
DELETE FROM IDN_OAUTH2_ACCESS_TOKEN WHERE rownum <=  batchSize AND (TOKEN_STATE IN ('EXPIRED','INACTIVE','REVOKED') OR 
    (TOKEN_STATE = 'ACTIVE' AND 
        VALIDITY_PERIOD < 99999999999000 AND
        REFRESH_TOKEN_VALIDITY_PERIOD < 99999999999000 AND
        (deleteTimeLimit > (TIME_CREATED + NUMTODSINTERVAL( VALIDITY_PERIOD / 60000, 'MINUTE' ) )) AND 
        (deleteTimeLimit > (REFRESH_TOKEN_TIME_CREATED + NUMTODSINTERVAL( REFRESH_TOKEN_VALIDITY_PERIOD / 60000, 'MINUTE' ) ))
    ));
  ROWCOUNT:= sql%rowcount;
   COMMIT;
IF (enableLog AND logLevel IN ('TRACE'))
THEN
   DBMS_OUTPUT.PUT_LINE('TRACE LOG << BATCH DELETE ON IDN_OAUTH2_ACCESS_TOKEN :'||ROWCOUNT);
END IF;
EXIT WHEN ROWCOUNT = 0 ;
END LOOP;
----
DBMS_OUTPUT.PUT_LINE('INFO LOG  << BATCH DELETE ON IDN_OAUTH2_ACCESS_TOKEN COMPLETED .... !');
--
---- ------------------------------------------------------
--
---- ------------------------------------------------------
---- BATCH DELETE IDN_OAUTH2_AUTHORIZATION_CODE
---- ------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('INFO LOG  << BATCH DELETE ON IDN_OAUTH2_AUTHORIZATION_CODE STARTED .... !');
----
IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
  SELECT count(1) into ROWCOUNT FROM IDN_OAUTH2_AUTHORIZATION_CODE;
  DBMS_OUTPUT.PUT_LINE('TRACE LOG << TOTAL TOKENS ON IDN_OAUTH2_AUTHORIZATION_CODE TABLE BEFORE DELETE :'||ROWCOUNT);
END IF;
----
IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
  SELECT COUNT(1) into ROWCOUNT FROM IDN_OAUTH2_AUTHORIZATION_CODE code WHERE NOT EXISTS (SELECT * FROM IDN_OAUTH2_ACCESS_TOKEN token WHERE token.TOKEN_ID = code.TOKEN_ID) OR 
  STATE NOT IN ('ACTIVE') OR (
  VALIDITY_PERIOD < 99999999999000 AND
  deleteTimeLimit > (TIME_CREATED + NUMTODSINTERVAL( VALIDITY_PERIOD / 60000, 'MINUTE' ))) OR TOKEN_ID IS NULL;
  DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS ON SHOULD BE DELETED FROM IDN_OAUTH2_AUTHORIZATION_CODE : '||ROWCOUNT);
END IF;
----
IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
  SELECT COUNT(1) into ROWCOUNT FROM IDN_OAUTH2_AUTHORIZATION_CODE code WHERE EXISTS (
    SELECT * FROM IDN_OAUTH2_ACCESS_TOKEN token WHERE token.TOKEN_ID = code.TOKEN_ID
    ) AND 
    STATE IN ('ACTIVE') AND 
    VALIDITY_PERIOD < 99999999999000 AND
    deleteTimeLimit <  (TIME_CREATED + NUMTODSINTERVAL( VALIDITY_PERIOD / 60000, 'MINUTE' ));
   DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS ON SHOULD BE RETAIN IN IDN_OAUTH2_AUTHORIZATION_CODE : '||ROWCOUNT);
END IF;
----

----
ROWCOUNT:= 1;

LOOP
IF ((ROWCOUNT > 0))
THEN
  DBMS_LOCK.SLEEP(sleepTime);
DBMS_OUTPUT.PUT_LINE('INFO LOG  << SLEEPING .... !');
END IF;
DELETE FROM IDN_OAUTH2_AUTHORIZATION_CODE where rownum <= batchSize AND CODE_ID in ( SELECT * FROM ( select CODE_ID FROM
    IDN_OAUTH2_AUTHORIZATION_CODE code WHERE NOT EXISTS ( SELECT * FROM IDN_OAUTH2_ACCESS_TOKEN token WHERE token.TOKEN_ID = code.TOKEN_ID AND token.TOKEN_STATE = 'ACTIVE') AND 
    code.STATE NOT IN ( 'ACTIVE' ) ) x) OR  (
    VALIDITY_PERIOD < 99999999999000 AND
    deleteTimeLimit >  ( time_created + NUMTODSINTERVAL( VALIDITY_PERIOD / 60000, 'MINUTE' ) ) );

ROWCOUNT:= sql%rowcount;
COMMIT;

IF (enableLog AND logLevel IN ('TRACE'))
THEN
  DBMS_OUTPUT.PUT_LINE('TRACE LOG << BATCH DELETE ON IDN_OAUTH2_AUTHORIZATION_CODE:' || ROWCOUNT);
END IF;
EXIT WHEN ROWCOUNT = 0;
END LOOP;
--
 DBMS_OUTPUT.PUT_LINE('INFO LOG << BATCH DELETE ON IDN_OAUTH2_AUTHORIZATION_CODE COMPLETED .... !');

IF (enableLog AND logLevel IN ('DEBUG','TRACE'))
THEN
  SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_ACCESS_TOKEN;
   DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS ON IDN_OAUTH2_ACCESS_TOKEN TABLE AFTER DELETE : ' ||ROWCOUNT);
END IF;

IF (enableLog AND LogLevel IN ('DEBUG','TRACE'))
THEN
  SELECT COUNT(1) INTO ROWCOUNT FROM IDN_OAUTH2_AUTHORIZATION_CODE;
  DBMS_OUTPUT.PUT_LINE('DEBUG LOG << TOTAL TOKENS ON IDN_OAUTH2_AUTHORIZATION_CODE TABLE AFTER DELETE : ' || ROWCOUNT);
END IF;

DBMS_OUTPUT.PUT_LINE('INFO LOG << TOKEN_CLEANUP_SP COMPLETED .... !');


END;
