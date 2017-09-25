/* Formatted on 7/14/2016 10:51:32 AM (QP5 v5.256.13226.35538) */
CREATE OR REPLACE PACKAGE BODY AMD_OWNER.amd_default_effectivity_pkg
AS
    /*
       $Author:   Douglas S. Elder
     $Revision:   1.3  $
         $Date:   14 Jul 2016
     $Workfile:   amd_default_effectivity_pkg.pkb  $
        Rev 1.3 14 Jul 2016 added ErrorMsg function and procedure, invoked errorMsg
                   for newGroup and setNsiEffects when there is an EXCEPTION
/*      Rev 1.2  04 Nov 2013 explicity retrieved the nextval for newGroup
/*      Rev 1.1   15 May 2002 10:12:24   c970183
/*   eliminated select of nextval and added select of currval for the sequence.

      SCCSID:    amd_default_effectivity_pkg.sql    1.2    Modified: 05/15/02  10:20:46
          */

   debug   BOOLEAN;

   FUNCTION ErrorMsg (
      pSourceName       IN amd_load_status.SOURCE%TYPE,
      pTableName        IN amd_load_status.TABLE_NAME%TYPE,
      pError_location   IN amd_load_details.DATA_LINE_NO%TYPE,
      pReturn_code      IN NUMBER,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
      RETURN NUMBER
   IS
   BEGIN
      ROLLBACK; -- rollback may not be complete if running with mDebug set to true
      amd_utils.InsertErrorMsg (
         pLoad_no        => amd_utils.GetLoadNo (pSourceName   => pSourceName,
                                                 pTableName    => pTableName),
         pData_line_no   => pError_location,
         pData_line      => pData,
         pKey_1          => SUBSTR (pKey1, 1, 50),
         pKey_2          => SUBSTR (pKey2, 1, 50),
         pKey_3          => pKey3,
         pKey_4          => TO_CHAR (pReturn_code),
         pKey_5          => TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MM:SS'),
         pComments       =>    'sqlcode('
                            || SQLCODE
                            || ') sqlerrm('
                            || SQLERRM
                            || ') '
                            || pComments);
      COMMIT;
      RETURN pReturn_code;
   END;

   PROCEDURE ErrorMsg (
      pSqlfunction         IN AMD_LOAD_STATUS.SOURCE%TYPE := 'errorMsg',
      pTableName           IN AMD_LOAD_STATUS.TABLE_NAME%TYPE := 'noname',
      pError_location         AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE := -100,
      pKey_1               IN AMD_LOAD_DETAILS.KEY_1%TYPE := '',
      pKey_2               IN AMD_LOAD_DETAILS.KEY_2%TYPE := '',
      pKey_3               IN AMD_LOAD_DETAILS.KEY_3%TYPE := '',
      pKey_4               IN AMD_LOAD_DETAILS.KEY_4%TYPE := '',
      pKeywordValuePairs   IN VARCHAR2 := '')
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      key5          AMD_LOAD_DETAILS.KEY_5%TYPE
                       := SUBSTR (pKeywordValuePairs, 1, 50);
      saveSqlCode   NUMBER := SQLCODE;
   BEGIN
      IF key5 = '' OR key5 IS NULL
      THEN
         key5 := pSqlFunction || '/' || pTableName;
      ELSE
         IF key5 IS NOT NULL
         THEN
            IF   LENGTH (key5)
               + LENGTH ('' || pSqlFunction || '/' || pTablename) < 50
            THEN
               key5 := key5 || ' ' || pSqlFunction || '/' || pTableName;
            END IF;
         END IF;
      END IF;

      -- use substr's to make sure that the input parameters for InsertErrorMsg and GetLoadNo
      -- do not exceed the length of the column's that the data gets inserted into
      -- This is for debugging and logging, so efforts to make it not be the source of more
      -- errors is VERY important

      DBMS_OUTPUT.put_line ('insertError@' || pError_location);

      Amd_Utils.InsertErrorMsg (
         pLoad_no        => Amd_Utils.GetLoadNo (
                              pSourceName   => SUBSTR (pSqlfunction, 1, 20),
                              pTableName    => SUBSTR (pTableName, 1, 20)),
         pData_line_no   => pError_location,
         pData_line      => 'amd_part_factors_pkg.',
         pKey_1          => SUBSTR (pKey_1, 1, 50),
         pKey_2          => SUBSTR (pKey_2, 1, 50),
         pKey_3          => SUBSTR (pKey_3, 1, 50),
         pKey_4          => SUBSTR (pKey_4, 1, 50),
         pKey_5          => SUBSTR (key5, 1, 50),
         pComments       => SUBSTR (
                                 'sqlcode('
                              || saveSQLCODE
                              || ') sqlerrm('
                              || SQLERRM
                              || ')',
                              1,
                              2000));

      IF SQLCODE <> -4092
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.enable (10000);
         DBMS_OUTPUT.put_line ('sql error=' || SQLCODE || ' ' || SQLERRM);

         IF pSqlFunction IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pSqlFunction=' || pSqlfunction);
         END IF;

         IF pTableName IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pTableName=' || pTableName);
         END IF;

         IF pError_location IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('pError_location=' || pError_location);
         END IF;

         IF pKey_1 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key1=' || pKey_1);
         END IF;

         IF pkey_2 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key2=' || pKey_2);
         END IF;

         IF pKey_3 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key3=' || pKey_3);
         END IF;

         IF pKey_4 IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line ('key4=' || pKey_4);
         END IF;

         IF pKeywordValuePairs IS NOT NULL
         THEN
            DBMS_OUTPUT.put_line (
               'pKeywordValuePairs=' || pKeywordValuePairs);
         END IF;

         IF SQLCODE <> -4092
         THEN
            raise_application_error (
               -20030,
               SUBSTR (
                     'amd_part_factors_pkg '
                  || SQLCODE
                  || ' '
                  || pError_location
                  || ' '
                  || pSqlFunction
                  || ' '
                  || pTableName
                  || ' '
                  || pKey_1
                  || ' '
                  || pKey_2
                  || ' '
                  || pKey_3
                  || ' '
                  || pKey_4
                  || ' '
                  || pKeywordValuePairs,
                  1,
                  2000));
         END IF;
   END ErrorMsg;

   PROCEDURE debugMsg (msg               IN AMD_LOAD_DETAILS.DATA_LINE%TYPE,
                       pError_Location   IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF debug
      THEN
         Amd_Utils.debugMsg (pMsg        => msg,
                             pPackage    => 'amd_part_factors_pkg',
                             pLocation   => pError_location);
         COMMIT;                                -- make sure the trace is kept
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF SQLCODE = -14551 OR SQLCODE = -14552
         THEN
            NULL;    -- cannot do a commit inside a query, so ignore the error
         ELSE
            RAISE;
         END IF;
   END debugMsg;

   PROCEDURE writeMsg (
      pTableName        IN AMD_LOAD_STATUS.TABLE_NAME%TYPE,
      pError_location   IN AMD_LOAD_DETAILS.DATA_LINE_NO%TYPE,
      pKey1             IN VARCHAR2 := '',
      pKey2             IN VARCHAR2 := '',
      pKey3             IN VARCHAR2 := '',
      pKey4             IN VARCHAR2 := '',
      pData             IN VARCHAR2 := '',
      pComments         IN VARCHAR2 := '')
   IS
   BEGIN
      Amd_Utils.writeMsg (pSourceName       => 'amd_part_factors_pkg',
                          pTableName        => pTableName,
                          pError_location   => pError_location,
                          pKey1             => pKey1,
                          pKey2             => pKey2,
                          pKey3             => pKey3,
                          pKey4             => pKey4,
                          pData             => pData,
                          pComments         => pComments);
   EXCEPTION
      WHEN OTHERS
      THEN
         --  ignoretrying to rollback or commit from trigger
         IF SQLCODE <> -4092
         THEN
            raise_application_error (
               -20010,
               SUBSTR (
                     'amd_part_factors_pkg '
                  || SQLCODE
                  || ' '
                  || pError_Location
                  || ' '
                  || pTableName
                  || ' '
                  || pKey1
                  || ' '
                  || pKey2
                  || ' '
                  || pKey3
                  || ' '
                  || pKey4
                  || ' '
                  || pData,
                  1,
                  2000));
         END IF;
   END writeMsg;

   FUNCTION newGroup
      RETURN NUMBER
   IS
      nsiGroupSid   NUMBER := NULL;
   BEGIN
      SELECT amd_nsi_group_sid_seq.NEXTVAL INTO nsiGroupSid FROM DUAL;

      INSERT
        INTO amd_nsi_groups (nsi_group_sid, fleet_size_name, split_effect)
      VALUES (nsiGroupSid, 'All Aircraft', 'N');

      SELECT amd_nsi_group_sid_seq.CURRVAL INTO nsiGroupSid FROM DUAL;

      RETURN nsiGroupSid;
   EXCEPTION
      WHEN OTHERS
      THEN
         ErrorMsg (
            pSqlfunction      => 'newGroup',
            pTableName        => 'amd_nsi_groups',
            pError_location   => 10,
            pKey_1            => TO_CHAR (nsiGroupSid),
            pKey_2            => 'All Aircraft',
            pKey_3            => 'N',
            pKey_4            =>    'nsi_group_sid: '
                                 || TO_CHAR (nsiGroupSid)
                                 || ' All Aircraft');
         RAISE;
   END;

   PROCEDURE setNsiEffects (pNsiSid NUMBER)
   IS
      CURSOR cur_sel_tail_no
      IS
         SELECT tail_no
           FROM amd_aircrafts
          WHERE tail_no != 'DUMMY';

      cnt   NUMBER := 0;
   BEGIN
      FOR rec IN cur_sel_tail_no
      LOOP
        <<insert_effects>>
         BEGIN
            INSERT INTO amd_nsi_effects (nsi_sid,
                                         tail_no,
                                         effect_type,
                                         user_defined,
                                         derived)
                 VALUES (pNsiSid,
                         rec.tail_no,
                         'B',
                         'S',
                         '');

            cnt := cnt + 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               ErrorMsg (pSqlfunction      => 'newGroup',
                         pTableName        => 'amd_nsi_effects',
                         pError_location   => 20,
                         pKey_1            => TO_CHAR (pNsiSid),
                         pKey_2            => TO_CHAR (rec.tail_no),
                         pKey_3            => 'cnt: ' || cnt);
               RAISE;
         END insert_effects;
      END LOOP;
   END;
END amd_default_effectivity_pkg;
/