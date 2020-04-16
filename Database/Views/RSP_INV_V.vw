DROP VIEW AMD_OWNER.RSP_INV_V;

/* Formatted on 4/16/2020 4:38:01 PM (QP5 v5.294) */
CREATE OR REPLACE FORCE VIEW AMD_OWNER.RSP_INV_V
(
   PART_NO,
   LOC_SID,
   RSP_INV,
   RSP_LEVEL
)
   BEQUEATH DEFINER
AS
   SELECT ri.part_no,
          ri.loc_sid,
          ri.rsp_inv,
          w.rsp_level rsp_level
     FROM rsp_ramp_item_v ri, rsp_whse_inv_v w
    WHERE     ri.part_no = w.part_no
          AND ri.loc_sid = w.loc_sid
          AND (ri.rsp_inv > 0 OR w.rsp_level > 0)
   UNION
   SELECT ri.part_no,
          ri.loc_sid,
          ri.rsp_inv,
          ri.rsp_level rsp_level
     FROM rsp_ramp_item_v ri
    WHERE     NOT EXISTS
                 (SELECT NULL
                    FROM rsp_whse_inv_v
                   WHERE part_no = ri.part_no AND loc_sid = ri.loc_sid)
          AND (ri.rsp_inv > 0 OR ri.rsp_level > 0)
   UNION
   SELECT part_no,
          loc_sid,
          0 rsp_inv,
          rsp_level
     FROM rsp_whse_inv_v w
    WHERE NOT EXISTS
             (SELECT NULL
                FROM rsp_ramp_item_v
               WHERE part_no = w.part_no AND loc_sid = w.loc_sid);


DROP PUBLIC SYNONYM RSP_INV_V;

CREATE PUBLIC SYNONYM RSP_INV_V FOR AMD_OWNER.RSP_INV_V;


GRANT SELECT ON AMD_OWNER.RSP_INV_V TO AMD_READER_ROLE;
