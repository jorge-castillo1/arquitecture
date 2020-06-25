using System;
using MongoDB.Driver;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using PopulateDatabase.Entities;

namespace PopulateDatabase
{
    class Program
    {
        private static string connection = "mongodb://localhost:27017";

        static void Main(string[] args)
        {
            MongoClient client = new MongoClient(connection);
            GetDataAndPopulate<EmailTemplate>(client, "customerportal", "emailtemplates");
            GetDataAndPopulate<WebTemplate>(client, "customerportal", "webtemplates");
            GetDataAndPopulate<DocumentTypes>(client, "signatures", "documenttypes");
        }

        private static void Populate<T>(MongoClient client, string databaseName, string collectionName, List<T> data) {
            IMongoDatabase database = client.GetDatabase(databaseName);
            database.DropCollection(collectionName);
            IMongoCollection<T> collection = database.GetCollection<T>(collectionName);
            if (data != null && data.Count > 0) collection.InsertMany(data);
        }

        private static List<T> GetData<T>(string fileName)
        {
            string path = Path.Combine(Environment.CurrentDirectory, @"..\..\..\Collections\" + fileName + ".json");
            string fileContent = File.ReadAllText(path);
            return JsonConvert.DeserializeObject<List<T>>(fileContent);
        }

        private static void GetDataAndPopulate<T>(MongoClient client, string databaseName, string collectionName)
        {
            List<T> data = GetData<T>(collectionName);
            Populate<T>(client, databaseName, collectionName, data); 
        }
    }
}
