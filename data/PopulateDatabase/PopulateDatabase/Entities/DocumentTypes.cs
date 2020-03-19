using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.Collections.Generic;

namespace PopulateDatabase.Entities
{
    public class DocumentTypes
    {
        [BsonRepresentation(BsonType.ObjectId)]
        public string _id { get; set; }

        [BsonElement("documenttype")]
        public int DocumentType { get; set; }

        [BsonElement("documentname")]
        public string DocumentName { get; set; }

        [BsonElement("templateid")]
        public string TemplateId { get; set; }

        [BsonElement("fields")]
        public Dictionary<string, string> Fields { get; set; } = new Dictionary<string, string>();
    }
}
