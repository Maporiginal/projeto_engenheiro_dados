// seed_mongo_suporte_tickets.js (refeito)
// Objetivo: 50 tickets no Mongo (DB: suporte, collection: tickets)
// Coerência: customer_id repete (mesmos 12 customer_id usados em orders/ledger),
// e parte dos tickets referencia order_id para facilitar JOIN no CURATED.

const DB_NAME = "suporte";
const COL = "tickets";

const dbSuporte = db.getSiblingDB(DB_NAME);

dbSuporte[COL].drop();

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
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0002",
    "ticket_id": "T0002",
    "customer_id": "07d56c48-8dc2-5dd6-b2ca-6452586674c8",
    "order_id": 2,
    "created_at": "2025-07-03T12:00:00Z",
    "status": "RESOLVED",
    "priority": "HIGH",
    "channel": "WHATSAPP",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0003",
    "ticket_id": "T0003",
    "customer_id": "0ca444f2-f748-5fbe-be16-1c42fcfa2056",
    "order_id": 3,
    "created_at": "2025-07-04T13:00:00Z",
    "status": "CLOSED",
    "priority": "LOW",
    "channel": "PHONE",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0004",
    "ticket_id": "T0004",
    "customer_id": "0efe4e01-e7c7-512d-b45e-aded5fc9ebec",
    "order_id": 4,
    "created_at": "2025-07-05T14:00:00Z",
    "status": "OPEN",
    "priority": "MEDIUM",
    "channel": "EMAIL",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0005",
    "ticket_id": "T0005",
    "customer_id": "1525ca83-90fc-57f1-a4b9-c05fd0c79661",
    "order_id": 5,
    "created_at": "2025-07-06T15:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "HIGH",
    "channel": "CHAT",
    "subject": "Pedido incompleto",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0006",
    "ticket_id": "T0006",
    "customer_id": "190408ca-eb78-557c-a20b-dc28d3e7853f",
    "order_id": 6,
    "created_at": "2025-07-07T16:00:00Z",
    "status": "RESOLVED",
    "priority": "LOW",
    "channel": "WHATSAPP",
    "subject": "Entrega atrasada",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0007",
    "ticket_id": "T0007",
    "customer_id": "29b10156-7854-5679-899c-d8642c32e4d6",
    "order_id": 7,
    "created_at": "2025-07-08T17:00:00Z",
    "status": "CLOSED",
    "priority": "MEDIUM",
    "channel": "PHONE",
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0008",
    "ticket_id": "T0008",
    "customer_id": "2bd5796e-f218-55e0-92f7-f44888a5c97a",
    "order_id": 8,
    "created_at": "2025-07-09T10:00:00Z",
    "status": "OPEN",
    "priority": "HIGH",
    "channel": "EMAIL",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0009",
    "ticket_id": "T0009",
    "customer_id": "36ea566d-7fa3-5394-a4ff-894b2c121029",
    "order_id": 9,
    "created_at": "2025-07-10T11:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "LOW",
    "channel": "CHAT",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0010",
    "ticket_id": "T0010",
    "customer_id": "39485023-3f9c-5c5d-b88d-25aafe0879e1",
    "order_id": 10,
    "created_at": "2025-07-11T12:00:00Z",
    "status": "RESOLVED",
    "priority": "MEDIUM",
    "channel": "WHATSAPP",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0011",
    "ticket_id": "T0011",
    "customer_id": "3d20e1d0-8309-572e-9a6f-0de23c2e7d9e",
    "order_id": 11,
    "created_at": "2025-07-12T13:00:00Z",
    "status": "CLOSED",
    "priority": "HIGH",
    "channel": "PHONE",
    "subject": "Pedido incompleto",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0012",
    "ticket_id": "T0012",
    "customer_id": "5188b342-ea75-5956-91b2-e01a68e88acc",
    "order_id": 12,
    "created_at": "2025-07-13T14:00:00Z",
    "status": "OPEN",
    "priority": "LOW",
    "channel": "EMAIL",
    "subject": "Entrega atrasada",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0013",
    "ticket_id": "T0013",
    "customer_id": "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    "order_id": 13,
    "created_at": "2025-07-14T15:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "MEDIUM",
    "channel": "CHAT",
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0014",
    "ticket_id": "T0014",
    "customer_id": "07d56c48-8dc2-5dd6-b2ca-6452586674c8",
    "order_id": 14,
    "created_at": "2025-07-15T16:00:00Z",
    "status": "RESOLVED",
    "priority": "HIGH",
    "channel": "WHATSAPP",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0015",
    "ticket_id": "T0015",
    "customer_id": "0ca444f2-f748-5fbe-be16-1c42fcfa2056",
    "order_id": 15,
    "created_at": "2025-07-16T17:00:00Z",
    "status": "CLOSED",
    "priority": "LOW",
    "channel": "PHONE",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0016",
    "ticket_id": "T0016",
    "customer_id": "0efe4e01-e7c7-512d-b45e-aded5fc9ebec",
    "order_id": 16,
    "created_at": "2025-07-17T10:00:00Z",
    "status": "OPEN",
    "priority": "MEDIUM",
    "channel": "EMAIL",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0017",
    "ticket_id": "T0017",
    "customer_id": "1525ca83-90fc-57f1-a4b9-c05fd0c79661",
    "order_id": 17,
    "created_at": "2025-07-18T11:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "HIGH",
    "channel": "CHAT",
    "subject": "Pedido incompleto",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0018",
    "ticket_id": "T0018",
    "customer_id": "190408ca-eb78-557c-a20b-dc28d3e7853f",
    "order_id": 18,
    "created_at": "2025-07-19T12:00:00Z",
    "status": "RESOLVED",
    "priority": "LOW",
    "channel": "WHATSAPP",
    "subject": "Entrega atrasada",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0019",
    "ticket_id": "T0019",
    "customer_id": "29b10156-7854-5679-899c-d8642c32e4d6",
    "order_id": 19,
    "created_at": "2025-07-20T13:00:00Z",
    "status": "CLOSED",
    "priority": "MEDIUM",
    "channel": "PHONE",
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0020",
    "ticket_id": "T0020",
    "customer_id": "2bd5796e-f218-55e0-92f7-f44888a5c97a",
    "order_id": 20,
    "created_at": "2025-07-21T14:00:00Z",
    "status": "OPEN",
    "priority": "HIGH",
    "channel": "EMAIL",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0021",
    "ticket_id": "T0021",
    "customer_id": "36ea566d-7fa3-5394-a4ff-894b2c121029",
    "order_id": 21,
    "created_at": "2025-07-22T15:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "LOW",
    "channel": "CHAT",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0022",
    "ticket_id": "T0022",
    "customer_id": "39485023-3f9c-5c5d-b88d-25aafe0879e1",
    "order_id": 22,
    "created_at": "2025-07-23T16:00:00Z",
    "status": "RESOLVED",
    "priority": "MEDIUM",
    "channel": "WHATSAPP",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0023",
    "ticket_id": "T0023",
    "customer_id": "3d20e1d0-8309-572e-9a6f-0de23c2e7d9e",
    "order_id": 23,
    "created_at": "2025-07-24T17:00:00Z",
    "status": "CLOSED",
    "priority": "HIGH",
    "channel": "PHONE",
    "subject": "Pedido incompleto",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0024",
    "ticket_id": "T0024",
    "customer_id": "5188b342-ea75-5956-91b2-e01a68e88acc",
    "order_id": 24,
    "created_at": "2025-07-25T10:00:00Z",
    "status": "OPEN",
    "priority": "LOW",
    "channel": "EMAIL",
    "subject": "Entrega atrasada",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0025",
    "ticket_id": "T0025",
    "customer_id": "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    "order_id": 25,
    "created_at": "2025-07-26T11:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "MEDIUM",
    "channel": "CHAT",
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0026",
    "ticket_id": "T0026",
    "customer_id": "07d56c48-8dc2-5dd6-b2ca-6452586674c8",
    "order_id": 26,
    "created_at": "2025-07-27T12:00:00Z",
    "status": "RESOLVED",
    "priority": "HIGH",
    "channel": "WHATSAPP",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0027",
    "ticket_id": "T0027",
    "customer_id": "0ca444f2-f748-5fbe-be16-1c42fcfa2056",
    "order_id": 27,
    "created_at": "2025-07-28T13:00:00Z",
    "status": "CLOSED",
    "priority": "LOW",
    "channel": "PHONE",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0028",
    "ticket_id": "T0028",
    "customer_id": "0efe4e01-e7c7-512d-b45e-aded5fc9ebec",
    "order_id": 28,
    "created_at": "2025-07-29T14:00:00Z",
    "status": "OPEN",
    "priority": "MEDIUM",
    "channel": "EMAIL",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0029",
    "ticket_id": "T0029",
    "customer_id": "1525ca83-90fc-57f1-a4b9-c05fd0c79661",
    "order_id": 29,
    "created_at": "2025-07-30T15:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "HIGH",
    "channel": "CHAT",
    "subject": "Pedido incompleto",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0030",
    "ticket_id": "T0030",
    "customer_id": "190408ca-eb78-557c-a20b-dc28d3e7853f",
    "order_id": 30,
    "created_at": "2025-07-31T16:00:00Z",
    "status": "RESOLVED",
    "priority": "LOW",
    "channel": "WHATSAPP",
    "subject": "Entrega atrasada",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0031",
    "ticket_id": "T0031",
    "customer_id": "29b10156-7854-5679-899c-d8642c32e4d6",
    "order_id": 31,
    "created_at": "2025-08-01T17:00:00Z",
    "status": "CLOSED",
    "priority": "MEDIUM",
    "channel": "PHONE",
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0032",
    "ticket_id": "T0032",
    "customer_id": "2bd5796e-f218-55e0-92f7-f44888a5c97a",
    "order_id": 32,
    "created_at": "2025-08-02T10:00:00Z",
    "status": "OPEN",
    "priority": "HIGH",
    "channel": "EMAIL",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0033",
    "ticket_id": "T0033",
    "customer_id": "36ea566d-7fa3-5394-a4ff-894b2c121029",
    "order_id": 33,
    "created_at": "2025-08-03T11:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "LOW",
    "channel": "CHAT",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0034",
    "ticket_id": "T0034",
    "customer_id": "39485023-3f9c-5c5d-b88d-25aafe0879e1",
    "order_id": 34,
    "created_at": "2025-08-04T12:00:00Z",
    "status": "RESOLVED",
    "priority": "MEDIUM",
    "channel": "WHATSAPP",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0035",
    "ticket_id": "T0035",
    "customer_id": "3d20e1d0-8309-572e-9a6f-0de23c2e7d9e",
    "order_id": 35,
    "created_at": "2025-08-05T13:00:00Z",
    "status": "CLOSED",
    "priority": "HIGH",
    "channel": "PHONE",
    "subject": "Pedido incompleto",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0036",
    "ticket_id": "T0036",
    "customer_id": "5188b342-ea75-5956-91b2-e01a68e88acc",
    "order_id": 36,
    "created_at": "2025-08-06T14:00:00Z",
    "status": "OPEN",
    "priority": "LOW",
    "channel": "EMAIL",
    "subject": "Entrega atrasada",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0037",
    "ticket_id": "T0037",
    "customer_id": "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    "order_id": 37,
    "created_at": "2025-08-07T15:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "MEDIUM",
    "channel": "CHAT",
    "subject": "Dúvida sobre cobrança",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0038",
    "ticket_id": "T0038",
    "customer_id": "07d56c48-8dc2-5dd6-b2ca-6452586674c8",
    "order_id": 38,
    "created_at": "2025-08-08T16:00:00Z",
    "status": "RESOLVED",
    "priority": "HIGH",
    "channel": "WHATSAPP",
    "subject": "Troca/devolução",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0039",
    "ticket_id": "T0039",
    "customer_id": "0ca444f2-f748-5fbe-be16-1c42fcfa2056",
    "order_id": 39,
    "created_at": "2025-08-09T17:00:00Z",
    "status": "CLOSED",
    "priority": "LOW",
    "channel": "PHONE",
    "subject": "Problema no pagamento",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0040",
    "ticket_id": "T0040",
    "customer_id": "0efe4e01-e7c7-512d-b45e-aded5fc9ebec",
    "order_id": 40,
    "created_at": "2025-08-10T10:00:00Z",
    "status": "OPEN",
    "priority": "MEDIUM",
    "channel": "EMAIL",
    "subject": "Atualização de cadastro",
    "tags": [
      "curated_demo",
      "suporte"
    ]
  },
  {
    "_id": "T0041",
    "ticket_id": "T0041",
    "customer_id": "39485023-3f9c-5c5d-b88d-25aafe0879e1",
    "order_id": null,
    "created_at": "2026-01-17T10:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "HIGH",
    "channel": "CHAT",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0042",
    "ticket_id": "T0042",
    "customer_id": "3d20e1d0-8309-572e-9a6f-0de23c2e7d9e",
    "order_id": null,
    "created_at": "2026-01-18T11:00:00Z",
    "status": "CLOSED",
    "priority": "MEDIUM",
    "channel": "PHONE",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0043",
    "ticket_id": "T0043",
    "customer_id": "5188b342-ea75-5956-91b2-e01a68e88acc",
    "order_id": null,
    "created_at": "2026-01-19T12:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "LOW",
    "channel": "CHAT",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0044",
    "ticket_id": "T0044",
    "customer_id": "07d56c48-8dc2-5dd6-b2ca-6452586674c8",
    "order_id": null,
    "created_at": "2026-01-20T13:00:00Z",
    "status": "CLOSED",
    "priority": "HIGH",
    "channel": "PHONE",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0045",
    "ticket_id": "T0045",
    "customer_id": "0ca444f2-f748-5fbe-be16-1c42fcfa2056",
    "order_id": null,
    "created_at": "2026-01-21T14:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "MEDIUM",
    "channel": "CHAT",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0046",
    "ticket_id": "T0046",
    "customer_id": "29b10156-7854-5679-899c-d8642c32e4d6",
    "order_id": null,
    "created_at": "2026-01-22T15:00:00Z",
    "status": "CLOSED",
    "priority": "LOW",
    "channel": "PHONE",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0047",
    "ticket_id": "T0047",
    "customer_id": "0efe4e01-e7c7-512d-b45e-aded5fc9ebec",
    "order_id": null,
    "created_at": "2026-01-23T16:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "HIGH",
    "channel": "CHAT",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0048",
    "ticket_id": "T0048",
    "customer_id": "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    "order_id": null,
    "created_at": "2026-01-24T17:00:00Z",
    "status": "CLOSED",
    "priority": "MEDIUM",
    "channel": "PHONE",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0049",
    "ticket_id": "T0049",
    "customer_id": "190408ca-eb78-557c-a20b-dc28d3e7853f",
    "order_id": null,
    "created_at": "2026-01-25T18:00:00Z",
    "status": "IN_PROGRESS",
    "priority": "LOW",
    "channel": "CHAT",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  },
  {
    "_id": "T0050",
    "ticket_id": "T0050",
    "customer_id": "36ea566d-7fa3-5394-a4ff-894b2c121029",
    "order_id": null,
    "created_at": "2026-01-26T19:00:00Z",
    "status": "CLOSED",
    "priority": "HIGH",
    "channel": "PHONE",
    "subject": "Solicitação geral",
    "tags": [
      "curated_demo"
    ]
  }
]);

print(`OK - inseridos: ${dbSuporte[COL].countDocuments()} documentos em ${dbSuporte.getName()}.${COL}`);
