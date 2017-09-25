--
-- SCCSID: amd_l67_source.ctl  1.3  Modified: 04/04/02 09:43:00
--
-- Date      By   History
-- 01/17/00  FF   Initial
-- 04/03/02  FF   Added filename.
--

options (silent=feedback,errors=30000)
LOAD DATA

APPEND INTO TABLE amd_l67_source
when (doc_no != '00000000000000') and (doc_no != 'ZZZZZZZZZZZZZZ')
(
	filename char(50),
	dic char(3),
	ri char(3),
	nsn char(13),
	mmc char(2),
	nomenclature char(32),
	doc_no char(14),
	atc char(1),
	tric char(3),
	ttpc char(2),
	dmd_cd char(1),
	trans_date char(7) nullif (trans_date='0000000') "to_date(:trans_date,'YYYYDDD')",
	trans_ser char(5) "to_char(to_number(trim(:trans_ser)))",
	marked_for char(14),
	action_qty char(6),
	reason char(1),
	sran char(6),
	dofd char(7) nullif (dofd='0000000') "to_date(:dofd,'YYYYDDD')",
	dold char(7) nullif (dold='0000000') "to_date(:dold,'YYYYDDD')",
	ui char(2),
	supp_address char(6),
	erc char(3),
	mic char(1)
)
