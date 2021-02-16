SELECT 
    n.nspname AS schemaname
    ,c.relname AS viewname
    ,'--DROP VIEW ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ';\n'
    + CASE 
     	WHEN c.relnatts > 0 then 'CREATE OR REPLACE VIEW ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' AS\n' + COALESCE(pg_get_viewdef(c.oid, TRUE), '')
     	ELSE  COALESCE(pg_get_viewdef(c.oid, TRUE), '') END AS ddl
FROM 
    pg_catalog.pg_class AS c
INNER JOIN
    pg_catalog.pg_namespace AS n
    ON c.relnamespace = n.oid
WHERE relkind = 'v';
