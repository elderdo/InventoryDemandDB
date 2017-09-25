DROP FUNCTION AMD_OWNER.GETCOSTTOREPAIROFFBASE;

CREATE OR REPLACE FUNCTION AMD_OWNER.getCostToRepairOffBase (
   nsi_sid IN NUMBER)
   RETURN NUMBER
IS
   /*
         $Author:   zf297a  $
       $Revision:   1.3 $
           $Date:   07  Dec 2011 10:15:44  $
       $Workfile:   GETCOSTTOREPAIROFFBASE.fnc  $

           Rev 1.3  15 Feb 2012 used new amd_repair_cost_detail to calc avg cost  to repair off base zf297a

           Rev 1.2  07 Dec 2011 made ccn_prefix query more flexible by using the length of the ccn_prefix in the substr of the existential subquery

   /*      Rev 1.1   24 Aug 2009 10:15:44   zf297a
   /*   activate PVCS VM keyword expansion
   */
   cost_to_repair_off_base   amd_national_stock_items.cost_to_repair_off_base%TYPE;
BEGIN
     SELECT AVG (cost.unit_price * pricing_factor) avg_cost
       INTO cost_to_repair_off_base
       FROM amd_repair_cost_detail cost,
            amd_national_stock_items items,
            amd_spare_parts parts,
            amd_ccn_prefix,
            amd_pricing_factors factors
      WHERE     items.nsi_sid = getCostToRepairOffBase.nsi_sid
            AND items.action_code <> 'D'
            AND items.nsn = parts.nsn
            AND parts.part_no = cost.part_no
            AND factors.fiscal_year = cost.fiscal_year
            AND factors.fiscal_year > (SELECT MAX (fiscal_year) - 4
                                          FROM amd_repair_cost_detail
                                         WHERE part_no = cost.part_no)
            AND SUBSTR (activity_id, 1, LENGTH (AMD_CCN_PREFIX.CCN_PREFIX)) =
                   AMD_CCN_PREFIX.CCN_PREFIX
   GROUP BY items.nsn;

   RETURN cost_to_repair_off_base;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
END getCostToRepairOffBase;
/


DROP PUBLIC SYNONYM GETCOSTTOREPAIROFFBASE;

CREATE OR REPLACE PUBLIC SYNONYM GETCOSTTOREPAIROFFBASE FOR AMD_OWNER.GETCOSTTOREPAIROFFBASE;


GRANT EXECUTE ON AMD_OWNER.GETCOSTTOREPAIROFFBASE TO AMD_WRITER_ROLE;

GRANT EXECUTE ON AMD_OWNER.GETCOSTTOREPAIROFFBASE TO BSRM_LOADER;

