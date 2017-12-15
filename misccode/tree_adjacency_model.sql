-- $ sqlite3 -header <tree_adjacency_model.sql

CREATE TABLE tree (
  node INTEGER NOT NULL PRIMARY KEY,
  name TEXT,
  parent INTEGER REFERENCES tree
);

INSERT INTO tree VALUES ( 1, 'A', NULL );
INSERT INTO tree VALUES ( 2, 'A.1', 1 );
INSERT INTO tree VALUES ( 3, 'A.1.a', 2 );
INSERT INTO tree VALUES ( 4, 'A.2', 1 );
INSERT INTO tree VALUES ( 5, 'A.2.a', 4 );
INSERT INTO tree VALUES ( 6, 'A.2.b', 4 );
INSERT INTO tree VALUES ( 7, 'A.3', 1 );

SELECT p.name AS parent, n.name AS node
FROM tree AS n JOIN tree AS p ON n.parent = p.node;
