/* Formatted on 12/5/2016 11:52:17 AM (QP5 v5.287) */
/*
  vim: ts=2:sw=2:sts=2:expandtab:autoindent:smartindent:
  
       loadTurn.sql
       Author:   Doublas S. Elder
     Revision:   1.0
         Date:   05 Dec 2016
**/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SET SQLBLANKLINES ON
SET TIME ON
SET TIMING ON
SET ECHO ON

EXEC amd_owner.mta_truncate_table('turn','reuse storage');

DEFINE link=&1


INSERT INTO turn (VOUCHER,
                  SC,
                  PART,
                  SERIAL,
                  REF,
                  STATUS,
                  DATE_TURNIN,
                  DATE_ISSUE,
                  DATE_REF,
                  DATE_EXP,
                  DATE_STRM,
                  DATE_SHIP,
                  DATE_SHIP_CYCLE,
                  QTY_TURNIN,
                  QTY_ISSUE,
                  ORDER_NO,
                  SHIP_VOUCHER,
                  SHIP_REF,
                  REMARKS,
                  REASON_CODE,
                  OTHER_PART,
                  OTHER_VOUCHER,
                  LAST_CHANGED_DATETIME,
                  LAST_CHANGED_USERID,
                  CREATED_DATETIME,
                  CREATED_USERID,
                  CANCELLED_DATETIME,
                  CANCELLED_DOCDATE,
                  REQUESTED_USERID_TURNIN,
                  REQUESTED_USERID_ISSUE)
   SELECT VOUCHER,
          SC,
          PART,
          SERIAL,
          REF,
          STATUS,
          DATE_TURNIN,
          DATE_ISSUE,
          DATE_REF,
          DATE_EXP,
          DATE_STRM,
          DATE_SHIP,
          DATE_SHIP_CYCLE,
          QTY_TURNIN,
          QTY_ISSUE,
          ORDER_NO,
          SHIP_VOUCHER,
          SHIP_REF,
          REMARKS,
          REASON_CODE,
          OTHER_PART,
          OTHER_VOUCHER,
          LAST_CHANGED_DATETIME,
          LAST_CHANGED_USERID,
          CREATED_DATETIME,
          CREATED_USERID,
          CANCELLED_DATETIME,
          CANCELLED_DOCDATE,
          REQUESTED_USERID_TURNIN,
          REQUESTED_USERID_ISSUE
     FROM turn@&link;

QUIT