CREATE TABLE babel_cursor_t1 (i INT, d double precision, c varchar(10), u uniqueidentifier, v sql_variant);
INSERT INTO babel_cursor_t1 VALUES (1, 1.1, 'a', '1E984725-C51C-4BF4-9960-E1C80E27ABA0', 1);
INSERT INTO babel_cursor_t1 VALUES (2, 22.22, 'bb', '2E984725-C51C-4BF4-9960-E1C80E27ABA0', 22.22);
INSERT INTO babel_cursor_t1 VALUES (3, 333.333, 'cccc', '3E984725-C51C-4BF4-9960-E1C80E27ABA0', 'cccc');
INSERT INTO babel_cursor_t1 VALUES (4, 4444.4444, 'dddddd', '4E984725-C51C-4BF4-9960-E1C80E27ABA0', cast('4E984725-C51C-4BF4-9960-E1C80E27ABA0' as uniqueidentifier));
INSERT INTO babel_cursor_t1 VALUES (NULL, NULL, NULL, NULL, NULL);
GO

-- simple happy case
DECLARE @cursor_handle int;
EXEC sp_cursoropen @cursor_handle OUTPUT, 'select i, d, c, u from babel_cursor_t1', 2, 8193;
-- NEXT 1
EXEC sp_cursorfetch @cursor_handle, 2, 0, 1;
-- NEXT 1
EXEC sp_cursorfetch @cursor_handle, 2, 0, 1;
-- NEXT 1
EXEC sp_cursorfetch @cursor_handle, 2, 0, 1;
-- PREV 1
EXEC sp_cursorfetch @cursor_handle, 4, 0, 1;
-- FIRST 2
EXEC sp_cursorfetch @cursor_handle, 1, 0, 2;
-- LAST 3
EXEC sp_cursorfetch @cursor_handle, 8, 0, 3;
-- ABSOLUTE 2 2
EXEC sp_cursorfetch @cursor_handle, 16, 2, 2;
EXEC sp_cursorclose @cursor_handle;
GO

-- sp_cursor auto-close
DECLARE @cursor_handle int;
EXEC sp_cursoropen @cursor_handle OUTPUT, 'select i, d, c, u from babel_cursor_t1', 16400, 8193;
EXEC sp_cursorfetch @cursor_handle, 2, 0, 100;
DECLARE @num_opened_cursor int;
SELECT @num_opened_cursor = count(*) FROM pg_catalog.pg_cursors where statement not like '%num_opened_cursor%';
PRINT 'num_opened_cursor: ' + cast(@num_opened_cursor as varchar(10));
GO

-- sp_cursor auto-close (no fast-forward)
DECLARE @cursor_handle int;
EXEC sp_cursoropen @cursor_handle OUTPUT, 'select i, d, c, u from babel_cursor_t1', 16384, 8193;
EXEC sp_cursorfetch @cursor_handle, 2, 0, 100;
DECLARE @num_opened_cursor int;
SELECT @num_opened_cursor = count(*) FROM pg_catalog.pg_cursors where statement not like '%num_opened_cursor%';
PRINT 'num_opened_cursor: ' + cast(@num_opened_cursor as varchar(10));
GO

-- sp_cursor auto-close (BABEL-1812)
DECLARE @cursor_handle int;
EXEC sp_cursoropen @cursor_handle OUTPUT, 'select i, d, c, u from babel_cursor_t1', 16388, 8193;
EXEC sp_cursorfetch @cursor_handle, 2, 0, 100;
DECLARE @num_opened_cursor int;
SELECT @num_opened_cursor = count(*) FROM pg_catalog.pg_cursors where statement not like '%num_opened_cursor%';
PRINT 'num_opened_cursor: ' + cast(@num_opened_cursor as varchar(10));
GO


-- sp_cursoroption and sp_cursor (not meaningful without TDS implemenation)
DECLARE @cursor_handle int;
EXEC sp_cursoropen @cursor_handle OUTPUT, 'select i, d, c, u from babel_cursor_t1', 2, 1;
EXEC sp_cursorfetch @cursor_handle, 2, 0, 2;
-- TEXTPTR_ONLY 2
EXEC sp_cursoroption @cursor_handle, 1, 2;
EXEC sp_cursor @cursor_handle, 40, 1, '';
-- TEXTPTR_ONLY 4
EXEC sp_cursoroption @cursor_handle, 1, 4;
EXEC sp_cursor @cursor_handle, 40, 1, '';
-- TEXTPTR_ONLY 0
EXEC sp_cursoroption @cursor_handle, 1, 0;
EXEC sp_cursor @cursor_handle, 40, 1, '';
-- TEXTDATA 3
EXEC sp_cursoroption @cursor_handle, 3, 3;
EXEC sp_cursor @cursor_handle, 40, 1, '';
-- TEXTDATA 0
EXEC sp_cursoroption @cursor_handle, 3, 0;
EXEC sp_cursor @cursor_handle, 40, 1, '';
EXEC sp_cursorclose @cursor_handle;
GO

-- cursor prep/exec test
DECLARE @stmt_handle int;
DECLARE @cursor_handle int;
DECLARE @cursor_handle2 int;
EXEC sp_cursorprepare @stmt_handle OUTPUT, N'', 'select i, d, c, u from babel_cursor_t1', 0, 2, 1;
EXEC sp_cursorexecute @stmt_handle, @cursor_handle OUTPUT;
EXEC sp_cursorfetch @cursor_handle, 2, 0, 1;
EXEC sp_cursorclose @cursor_handle;
EXEC sp_cursorexecute @stmt_handle, @cursor_handle2 OUTPUT;
EXEC sp_cursorfetch @cursor_handle2, 2, 0, 4;
EXEC sp_cursorclose @cursor_handle2;
EXEC sp_cursorunprepare @stmt_handle;
GO

-- cursor prepexec test
DECLARE @stmt_handle int;
DECLARE @cursor_handle int;
DECLARE @cursor_handle2 int;
EXEC sp_cursorprepexec @stmt_handle OUTPUT, @cursor_handle OUTPUT, N'', 'select i+100 from babel_cursor_t1', 0, 16400, 1;
EXEC sp_cursorfetch @cursor_handle, 2, 0, 1;
EXEC sp_cursorclose @cursor_handle;
EXEC sp_cursorexecute @stmt_handle, @cursor_handle2 OUTPUT;
EXEC sp_cursorfetch @cursor_handle2, 2, 0, 4;
EXEC sp_cursorclose @cursor_handle2;
EXEC sp_cursorunprepare @stmt_handle;
GO

