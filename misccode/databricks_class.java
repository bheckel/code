Databricks

val betterDF = spark.read.parquet("/mnt/training/wikipedia/pagecounts/staging_parquet_en_only_clean/")
               .filter($"project".isNotNull &&
                       $"project" =!= "en.zero" && 
                       $"project" =!= "en.zero.n" && 
                       $"project" =!= "en.zero.s" && 
                       $"project" =!= "en.zero.d" && 
                       $"project" =!= "en.zero.voy" && 
                       $"project" =!= "en.zero.b" && 
                       $"project" =!= "en.zero.v" && 
                       $"project" =!= "en.zero.q")

printf("Final: %,d%n%n", betterDF.count)

betterDF.explain(true)



%fs ls "/mnt/training/wikipedia/pageviews/pageviews_by_second.parquet"



val tempD = initialDF
  .withColumnRenamed("timestamp", "capturedAt")
  .withColumn("capturedAt", unix_timestamp($"capturedAt", "yyyy-MM-dd'T'HH:mm:ss").cast("timestamp") )

tempD.printSchema()



pageviewsDF
  .filter("site = 'desktop'")
  .select( 
    format_number(sum($"requests"), 0), 
    format_number(count($"requests"), 0), 
    format_number(avg($"requests"), 2), 
    format_number(min($"requests"), 0), 
    format_number(max($"requests"), 0) 
  )
  .show()



import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

// I've already gone through the exercise to determine
// how many partitions I want and in this case it is...
val partitions = 8

// Make sure wide operations don't repartition to 200
spark.conf.set("spark.sql.shuffle.partitions", partitions.toString)

// The directory containing our parquet files.
val parquetFile = "/mnt/training/wikipedia/pageviews/pageviews_by_second.parquet/"

// Create our initial DataFrame. We can let it infer the 
// schema because the cost for parquet files is really low.
val pageviewsDF = spark.read
  .option("inferSchema", "true")                // The default, but not costly w/Parquet
  .parquet(parquetFile)                         // Read the data in
  .repartition(partitions)                      // From 7 >>> 8 partitions
  .withColumnRenamed("timestamp", "capturedAt") // rename and convert to timestamp datatype
  .withColumn("capturedAt", unix_timestamp($"capturedAt", "yyyy-MM-dd'T'HH:mm:ss").cast("timestamp") )
  .orderBy($"capturedAt", $"site")              // sort our records
  .cache()                                      // Cache the expensive operation

// materialize the cache
pageviewsDF.count()



display(dbutils.fs.ls(userhome))



val fileName = "/mnt/training/bikeSharing/data-001/hour.csv"

val initialDF = spark.read        // Our DataFrameReader
  .option("header", "true")       // Let Spark know we have a header
  .option("inferSchema", "true")  // Infering the schema (it is a small dataset)
  .csv(fileName)                  // Location of our data
  .cache()                        // Mark the DataFrame as cached.

initialDF.count()                 // Materialize the cache
//initialDF.printSchema()  
initialDF.show()  

val preprocessedDF = initialDF.drop("instant", "dteday", "season", "casual", "registered", "holiday", "weekday")

val Array(trainDF, testDF) = preprocessedDF.randomSplit( 
  Array(0.7, 0.3),  // 70-30 split
  seed=42)          // For reproducibility

println(s"We have ${trainDF.count} training examples and ${testDF.count} test examples.")
assert (trainDF.count() == 12197)

val weathersitStringIndexer = new StringIndexer()
  .setInputCol("weathersit")
  .setOutputCol("weathersitIndex")

weathersitStringIndexer.fit(trainDF).transform(trainDF).printSchema()

import org.apache.spark.ml.feature.VectorAssembler

val assemblerInputs  = Array(
  "mnth", "temp", "hr", "hum", "atemp", "windspeed", // Our numerical features
  "yrIndex", "workingdayIndex", "weathersitIndex")   // Our new categorical features

val vectorAssembler = new VectorAssembler()
  .setInputCols(assemblerInputs)
  .setOutputCol("features")

import org.apache.spark.ml.regression.RandomForestRegressor

val rfr = new RandomForestRegressor()
  .setLabelCol("cnt") // The column of our label
  .setSeed(27)        // Some seed value for consistency
  .setNumTrees(3)     // A guess at the number of trees
  .setMaxDepth(10)    // A guess at the depth of each tree

import org.apache.spark.ml.Pipeline

val pipeline = new Pipeline().setStages(Array(
  workingdayStringIndexer, // categorize workingday
  weathersitStringIndexer, // categorize weathersit
  yrStringIndexer,         // categorize yr
  vectorAssembler,         // assemble the feature vector for all columns
  rfr))

val pipelineModel = pipeline.fit(trainDF)

import org.apache.spark.ml.regression.RandomForestRegressionModel

val rfrm = pipelineModel.stages.last    // The RFRM is in the last stage of the model
  .asInstanceOf[RandomForestRegressionModel]

// Zip the list of features with their scores
val scores = assemblerInputs.zip(rfrm.featureImportances.toArray)

// And pretty print 'em
scores.foreach(x => println(f"${x._1}%-15s = ${x._2}"))

println("-"*80)

---

Databricks

%run "./Includes/Classroom-Setup"
%fs ls dbfs:/mnt/training/ssn/names-1880-2016.parquet/
val ssaDF = spark.read.parquet("/mnt/training/ssn/names-1880-2016.parquet/")
display(ssaDF)

val peopleDistinctNamesDF = peopleDF.select($"firstName").distinct
peopleDistinctNamesDF.count()
val ssaDistinctNamesDF = ssaDF.select($"firstName" as "ssaFirstName").distinct
ssaDistinctNamesDF.count()
val joinedDF = peopleDistinctNamesDF.join(ssaDistinctNamesDF, peopleDistinctNamesDF("firstName") === ssaDistinctNamesDF("ssaFirstName"))

// assert
dbTest("0", rowsLosAngeles, 217945)

val cityDataDF = spark.read.parquet("dbfs:/mnt/training/City-Data.parquet").withColumnRenamed("city", "cities")

---

import org.apache.spark.sql.functions.explode
val databricksBlog2DF = databricksBlogDF
  .select($"title",$"authors",explode($"authors") as "author", $"link")
  .filter(size($"authors") > 1)
  .orderBy($"title")
        
display(databricksBlogDF)

display(homicidesNewYorkDF.limit(5))

val homicidesBostonAndNewYorkDF = homicidesNewYorkDF.union(homicidesBostonDF)

display(homicidesBostonAndNewYorkDF.select($"month").orderBy($"month").groupBy($"month").count())

---
