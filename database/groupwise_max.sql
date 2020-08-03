--TODO analytic function approach


-- http://jan.kneschke.de/projects/mysql/groupwise-max/

SELECT co1.continent, co1.name, co1.population
  FROM Country AS co1,

       (select continent, MAX(population) as maxpop
        from Country
        group by continent
			 ) AS co2

  WHERE co2.continent=co1.continent AND co1.population=co2.maxpop
	;

+---------------+----------------------------------------------+------------+
| continent     | name                                         | population |
+---------------+----------------------------------------------+------------+
| Oceania       | Australia                                    |   18886000 |
| South America | Brazil                                       |  170115000 |
| Asia          | China                                        | 1277558000 |
| Africa        | Nigeria                                      |  111506000 |
| Europe        | Russian Federation                           |  146934000 |
| North America | United States                                |  278357000 |
| Antarctica    | Antarctica                                   |          0 |
| Antarctica    | Bouvet Island                                |          0 |
+---------------+----------------------------------------------+------------+
