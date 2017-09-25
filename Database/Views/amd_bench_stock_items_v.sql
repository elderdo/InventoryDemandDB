SET DEFINE OFF;
DROP VIEW AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V;

/* Formatted on 2008/08/14 12:43 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW amd_owner.amd_bench_stock_items_v (nsn,
                                                                prime_part_no
                                                               )
AS
   SELECT DISTINCT n.nsn, prime_part_no
              FROM amd_demands d, amd_national_stock_items n
             WHERE d.doc_no LIKE 'B%'
               AND d.nsi_sid = n.nsi_sid
               AND n.action_code <> 'D';


DROP PUBLIC SYNONYM AMD_BENCH_STOCK_ITEMS_V;

CREATE PUBLIC SYNONYM AMD_BENCH_STOCK_ITEMS_V FOR AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V;


GRANT SELECT ON AMD_OWNER.AMD_BENCH_STOCK_ITEMS_V TO AMD_READER_ROLE;


