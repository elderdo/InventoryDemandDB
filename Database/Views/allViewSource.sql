CREATE OR REPLACE
TYPE view_line AS OBJECT
( TEXT  VARCHAR2(4000)
, LINE NUMBER
)
/
CREATE OR REPLACE
TYPE view_source AS TABLE OF view_line
/
CREATE OR REPLACE FUNCTION Get_View_Line
( p_vname  IN VARCHAR2
, p_schema IN VARCHAR2 DEFAULT USER )
   RETURN view_source AUTHID CURRENT_USER PIPELINED
AS
-- *******************************************************
--  Purpose:    Shred LONG VIEW TEXT into separate lines
--              ( like xxx_SOURCE )
-- 
--  http://tinyurl.com/5b2a8s
-- 
-- *******************************************************
   l_cursor     INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
   l_n          NUMBER;
   l_long_val   LONG;
   l_long_len   NUMBER;
   l_buflen     NUMBER  := 4000;
   l_curpos     NUMBER  := 0;
   l_leftover   LONG;
   n            NUMBER;
   l_line       NUMBER  := 0;
   select_txt   VARCHAR2(100) := 'select text from all_views where ';
BEGIN
   select_txt := select_txt||'owner = '''||p_schema||''' AND view_name = :x';
   DBMS_SQL.PARSE (l_cursor
                 , select_txt
                 , DBMS_SQL.native
                  );
   DBMS_SQL.BIND_VARIABLE (l_cursor, ':x', p_vname);
   DBMS_SQL.DEFINE_COLUMN_LONG (l_cursor, 1);
   l_n := DBMS_SQL.EXECUTE (l_cursor);
   IF (DBMS_SQL.FETCH_ROWS (l_cursor) > 0)
   THEN
      LOOP
         DBMS_SQL.COLUMN_VALUE_LONG (l_cursor
                                   , 1
                                   , l_buflen
                                   , l_curpos
                                   , l_long_val
                                   , l_long_len
                                    );
         EXIT WHEN (NVL (l_long_len, 0) = 0);
         IF (    l_long_len < l_buflen
             AND SUBSTR (l_long_val, l_long_len, 1) != CHR (10)
            )
         THEN
            l_long_val := l_long_val || CHR (10);
         END IF;
         l_long_val := l_leftover || l_long_val;
         LOOP
            n := LEAST( INSTR(l_long_val, CHR (10))
                      , 4000); -- up to 4000 chars
            EXIT WHEN (NVL (n, 0) = 0);
            l_line := l_line+1;
            PIPE ROW ( view_line
                       ( SUBSTR (l_long_val, 1, n - 1)
                       , l_line)
                      );
            l_long_val := SUBSTR (l_long_val, n + 1);
         END LOOP;
         l_leftover := l_long_val;
         l_curpos := l_curpos + l_long_len;
      END LOOP;
   END IF;
   DBMS_SQL.CLOSE_CURSOR (l_cursor);
   RETURN;
END Get_View_Line;
/

CREATE OR REPLACE VIEW ALL_VIEW_SOURCE
(OWNER, NAME, TYPE, LINE, TEXT)
AS 
SELECT 
-- ********************************************************
--  Purpose:    Provide VIEW lines like xxx_SOURCE
-- 
--  http://tinyurl.com/5b2a8s
-- ********************************************************
       av.owner
     , av.view_name AS "NAME"
     , 'VIEW'       AS "TYPE"
     , l."LINE"
     , l."TEXT"
  FROM ALL_VIEWS av
     , TABLE (Get_View_Line (av.view_name, av.owner)) l
/


with views_and_links as (
select  name view_name, trim(upper(substr(text,instr(text,'@')+1, instr(text,' ',instr(text,'@')) - (instr(text,'@')+1)))) db_link from all_view_source where owner = 'AMD_OWNER' and text like '%@%'
and upper(substr(text,instr(text,'@')+1, instr(text,' ',instr(text,'@')) - (instr(text,'@')+1))) is not null
order by 2
) 
select distinct vl.db_link, username, host from views_and_links vl, all_db_links a
where A.DB_LINK like '%' || vl.db_link || '%'
order by 2

select  text, case 
                 instr(text,'@') > 0 then
           case instr(text,' ',instr(text,'@')) > 0 then
              '>'
           else
              length(text)
           end
         end stuff     from all_view_source where owner = 'AMD_OWNER' and text like '%@%'

select instr('stuff','x') from dual


select * from all_db_links
