CREATE OR REPLACE PROCEDURE plch_change_table
   AUTHID DEFINER
IS
BEGIN
   EXECUTE IMMEDIATE 'alter table plch_trees modify tree_name varchar2(10)';
   EXECUTE IMMEDIATE
      q'[
   BEGIN
      INSERT INTO plch_trees (id, tree_name, tree_location)
           VALUES (100, 'Black Oak', 'Eastern US');
      INSERT INTO plch_trees (id, tree_name, tree_location)
           VALUES (200, 'Tamarack', 'Europe');
      COMMIT;
   END;]';
END;
/
