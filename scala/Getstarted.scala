package com.start

import scala.collection.immutable.IndexedSeq
import org.mongodb.scala._
import org.mongodb.scala.model.Aggregates._
import org.mongodb.scala.model.Accumulators._
import org.mongodb.scala.model.Filters._
import org.mongodb.scala.model.Projections._
import org.mongodb.scala.model.Sorts._
import org.mongodb.scala.model.Updates._
import org.mongodb.scala.model._
import scala.collection.JavaConverters._
import com.start.Helpers._

object Getstarted {

  def main(args: Array[String]): Unit = {
    
    val mongoClient: MongoClient = MongoClient(sys.env("MONGODB_URI"))

    // get handle to a database
    val database: MongoDatabase = mongoClient.getDatabase("getstarted")

    // get a handle of a collection
    val collection: MongoCollection[Document] = database.getCollection("scala")

    collection.drop().results()

    // make a document and insert it
    val doc: Document = Document("_id" -> 0, 
                                 "name" -> "MongoDB", 
                                 "type" -> "database",
                                 "count" -> 1, 
                                 "info" -> Document("x" -> 203, "y" -> 102))

    collection.insertOne(doc).results()

    // find the inserted document
    collection.find.first().printResults()

    // insert many
    val documents: IndexedSeq[Document] = (1 to 10) map { i: Int => Document("i" -> i) }
    val insertObservable = collection.insertMany(documents)

    val insertAndCount = for {
      insertResult <- insertObservable
      countResult <- collection.countDocuments()
    } yield countResult

    println(s"total # of documents :  ${insertAndCount.headResult()}")

    // Query Filters
    // now use a query to get 1 document out
    collection.find(equal("i", 7)).first().printHeadResult()

    // Sorting
    collection.find(exists("i")).sort(descending("i")).first().printHeadResult()

    // Projection
    collection.find().projection(excludeId()).first().printHeadResult()

    // Update One
    collection.updateOne(equal("i", 10), set("i", 110)).printHeadResult("Update Result: ")

    // Delete One
    collection.deleteOne(equal("i", 2)).printHeadResult("Delete Result: ")

    collection.drop().results()

    // ordered bulk writes
    val writes: List[WriteModel[_ <: Document]] = List(
      InsertOneModel(Document("_id" -> 4)),
      InsertOneModel(Document("_id"-> 5)),
      InsertOneModel(Document("_id" -> 6)),
      UpdateOneModel(Document("_id" -> 1), set("x", 2)),
      DeleteOneModel(Document("_id" -> 2)),
      ReplaceOneModel(Document("_id" -> 3), Document("_id" -> 3, "x" -> 4))
    )

    collection.bulkWrite(writes).printHeadResult("Bulk write results: ")

    // Clean up
    collection.drop().results()

    //Aggregation
    collection.aggregate(Seq(
      group(null, sum("total", "$i")),
    )).printResults()

    // release resources
    mongoClient.close()

    println("Finished.")

  }

}
