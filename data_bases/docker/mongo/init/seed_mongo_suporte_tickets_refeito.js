// seed_mongo_suporte_tickets_sem_tags.js
// Insere tickets SEM o campo "tags" para evitar problemas na exportação para Parquet.

dbSuporte[COL].insertMany([
  {
    "_id": "T0001",
    "ticket_id": "T0001",
    "customer_id": "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    "order_id": 1,
    "created_at": "2025-07-02T11:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "MEDIUM",
    "channel": "CHAT",
    "subject": "Dúvida sobre cobrança"
  },
  {
    "_id": "T0002",
    "ticket_id": "T0002",
    "customer_id": "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    "order_id": 2,
    "created_at": "2025-07-03T09:30:00Z",
    "status": "OPEN",
    "priority": "HIGH",
    "channel": "EMAIL",
    "subject": "Pedido não chegou"
  },
  {
    "_id": "T0003",
    "ticket_id": "T0003",
    "customer_id": "6aaf58a5-92c1-5a55-9b8d-3d602f77a1c2",
    "order_id": 3,
    "created_at": "2025-07-04T15:10:00Z",
    "status": "RESOLVED",
    "priority": "LOW",
    "channel": "WHATSAPP",
    "subject": "Troca de produto"
  }
]);
