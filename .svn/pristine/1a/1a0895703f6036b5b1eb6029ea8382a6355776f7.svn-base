--
-- filename: amd_l67_source.ctl
-- Author: Douglas S. Elder
-- Date: 01 Oct 2012
-- Rev: 1.0
-- Desc: use a comma delimited file with quotes around
-- char fields to load amd_l67_source

options (skip=1,silent=feedback,errors=30000)
LOAD DATA
infile '/apps/CRON/AMD/data/amd_l67_source.csv'
Append INTO TABLE amd_l67_source
fields terminated by "," optionally enclosed by '"'
trailing nullcols
(
	dic,
	ri,
	nsn,
	mmc,
	nomenclature "replace(:nomenclature,'^','\"')",
	doc_no,
	atc,
	tric,
	ttpc,
	dmd_cd,
	trans_date,
	trans_ser,
	marked_for,
	action_qty,
	reason,
	sran,
	dofd,
	dold,
	ui,
	supp_address,
	erc,
	mic,
	filename
)
