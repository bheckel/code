FUNCTION remove_table_suffix(
  p_table_name IN VARCHAR2,
  p_suffix     IN VARCHAR2 DEFAULT '_BASE')
RETURN VARCHAR2
IS
BEGIN
  RETURN REGEXP_REPLACE(UPPER(p_table_name), p_suffix||'$', '');
END;
