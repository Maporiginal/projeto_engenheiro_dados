// seed_suporte.js
// Estrutura simplificada para evitar dor de cabeça no ingest
// Rodar dentro do container do mongo (mongosh)

const DB_NAME = "suporte";
const dbSuporte = db.getSiblingDB(DB_NAME);

dbSuporte.tickets.drop();

dbSuporte.tickets.createIndex({ customer_id: 1, created_at: 1 });
dbSuporte.tickets.createIndex({ "related.order_id": 1 });
dbSuporte.tickets.createIndex({ status: 1, updated_at: 1 });

dbSuporte.tickets.insertMany([
  {
    _id: "TICK-00001",
    ticket_id: "TICK-00001",
    customer_id: "072dcd5d-45f7-5587-94cc-0fa36325f9c8",
    status: "IN_PROGRESS",
    created_at: "2025-07-05T02:00:00Z",
    updated_at: "2025-07-06T20:00:00Z",
    related: { order_id: 1 },
    events: [
      { ts: "2025-07-05T02:00:00Z", type: "created", by: "customer", text: "Aberto pelo cliente." },
      { ts: "2025-07-06T20:00:00Z", type: "reply", by: "ana.suporte", text: "Em análise." }
    ]
  },
  {
    _id: "TICK-00002",
    ticket_id: "TICK-00002",
    customer_id: "00004cd4-45c2-519c-8214-f5d292944503",
    status: "RESOLVED",
    created_at: "2025-07-05T03:00:00Z",
    updated_at: "2025-07-05T09:10:00Z",
    related: { order_id: 2 },
    events: [
      { ts: "2025-07-05T03:00:00Z", type: "created", by: "customer", text: "Dúvida sobre entrega." },
      { ts: "2025-07-05T09:10:00Z", type: "resolved", by: "system", text: "Encerrado." }
    ]
  },
  {
    _id: "TICK-00003",
    ticket_id: "TICK-00003",
    customer_id: "0efe4e01-e7c7-512d-b45e-aded5fc9ebec",
    status: "OPEN",
    created_at: "2025-07-06T10:40:00Z",
    updated_at: "2025-07-06T10:40:00Z",
    related: { order_id: 3 },
    events: [
      { ts: "2025-07-06T10:40:00Z", type: "created", by: "customer", text: "Pedido não aparece no app." }
    ]
  },
  {
    _id: "TICK-00004",
    ticket_id: "TICK-00004",
    customer_id: "190408ca-eb78-557c-a20b-dc28d3e7853f",
    status: "IN_PROGRESS",
    created_at: "2025-07-07T08:00:00Z",
    updated_at: "2025-07-07T12:00:00Z",
    related: { order_id: 4 },
    events: [
      { ts: "2025-07-07T08:00:00Z", type: "created", by: "customer", text: "Cobrança duplicada." },
      { ts: "2025-07-07T12:00:00Z", type: "reply", by: "maria.suporte", text: "Solicitando comprovantes." }
    ]
  },
  {
    _id: "TICK-00005",
    ticket_id: "TICK-00005",
    customer_id: "7a556456-f424-5d9a-bac4-443dd7ac7ff3",
    status: "PENDING_CUSTOMER",
    created_at: "2025-07-08T14:30:00Z",
    updated_at: "2025-07-08T14:45:00Z",
    related: { order_id: 5 },
    events: [
      { ts: "2025-07-08T14:30:00Z", type: "created", by: "customer", text: "Endereço incompleto." },
      { ts: "2025-07-08T14:45:00Z", type: "reply", by: "ana.suporte", text: "Pode confirmar o complemento?" }
    ]
  },
  {
    _id: "TICK-00006",
    ticket_id: "TICK-00006",
    customer_id: "6e7f40e3-321b-576a-998c-132f6978fcca",
    status: "RESOLVED",
    created_at: "2025-07-09T09:20:00Z",
    updated_at: "2025-07-09T10:05:00Z",
    related: { order_id: 6 },
    events: [
      { ts: "2025-07-09T09:20:00Z", type: "created", by: "customer", text: "Cupom não aplicado." },
      { ts: "2025-07-09T10:05:00Z", type: "resolved", by: "system", text: "Ajuste aplicado." }
    ]
  },
  {
    _id: "TICK-00007",
    ticket_id: "TICK-00007",
    customer_id: "7fea6830-3ca8-50dd-a843-81af97bd3c3a",
    status: "IN_PROGRESS",
    created_at: "2025-07-10T18:00:00Z",
    updated_at: "2025-07-10T18:30:00Z",
    related: { order_id: 7 },
    events: [
      { ts: "2025-07-10T18:00:00Z", type: "created", by: "customer", text: "Produto veio errado." },
      { ts: "2025-07-10T18:30:00Z", type: "reply", by: "joao.suporte", text: "Pode enviar foto do item?" }
    ]
  },
  {
    _id: "TICK-00008",
    ticket_id: "TICK-00008",
    customer_id: "36ea566d-7fa3-5394-a4ff-894b2c121029",
    status: "OPEN",
    created_at: "2025-07-11T07:10:00Z",
    updated_at: "2025-07-11T07:10:00Z",
    related: { order_id: 8 },
    events: [
      { ts: "2025-07-11T07:10:00Z", type: "created", by: "customer", text: "Atraso na entrega." }
    ]
  },
  {
    _id: "TICK-00009",
    ticket_id: "TICK-00009",
    customer_id: "73dbb2b2-6cc0-5f55-a55b-34a2ed3910e1",
    status: "RESOLVED",
    created_at: "2025-07-12T11:00:00Z",
    updated_at: "2025-07-12T16:00:00Z",
    related: { order_id: 9 },
    events: [
      { ts: "2025-07-12T11:00:00Z", type: "created", by: "customer", text: "Pedido entregue parcialmente." },
      { ts: "2025-07-12T16:00:00Z", type: "resolved", by: "system", text: "Reembolso parcial efetuado." }
    ]
  },
  {
    _id: "TICK-00010",
    ticket_id: "TICK-00010",
    customer_id: "facf3687-dbe1-5ade-b6a9-aabce8511c18",
    status: "IN_PROGRESS",
    created_at: "2025-07-13T20:15:00Z",
    updated_at: "2025-07-13T21:40:00Z",
    related: { order_id: 10 },
    events: [
      { ts: "2025-07-13T20:15:00Z", type: "created", by: "customer", text: "Cartão recusado, mas cobrado." },
      { ts: "2025-07-13T21:40:00Z", type: "reply", by: "ana.suporte", text: "Estamos verificando com o financeiro." }
    ]
  },
  {
    _id: "TICK-00011",
    ticket_id: "TICK-00011",
    customer_id: "6331dd1f-82d1-5c0c-bc68-6239f5d2a2ef",
    status: "PENDING_CUSTOMER",
    created_at: "2025-07-14T09:00:00Z",
    updated_at: "2025-07-14T09:30:00Z",
    related: { order_id: 11 },
    events: [
      { ts: "2025-07-14T09:00:00Z", type: "created", by: "customer", text: "Preciso da nota fiscal." },
      { ts: "2025-07-14T09:30:00Z", type: "reply", by: "maria.suporte", text: "Pode confirmar o CPF para emissão?" }
    ]
  },
  {
    _id: "TICK-00012",
    ticket_id: "TICK-00012",
    customer_id: "ff5dd317-9906-5b24-8fae-139edbcae5ce",
    status: "RESOLVED",
    created_at: "2025-07-15T12:00:00Z",
    updated_at: "2025-07-15T12:35:00Z",
    related: { order_id: 12 },
    events: [
      { ts: "2025-07-15T12:00:00Z", type: "created", by: "customer", text: "Troca de endereço." },
      { ts: "2025-07-15T12:35:00Z", type: "resolved", by: "system", text: "Atualizado." }
    ]
  },
  {
    _id: "TICK-00013",
    ticket_id: "TICK-00013",
    customer_id: "d68478ae-b3c5-51eb-927f-8738928d6a11",
    status: "OPEN",
    created_at: "2025-07-16T06:30:00Z",
    updated_at: "2025-07-16T06:30:00Z",
    related: { order_id: 13 },
    events: [
      { ts: "2025-07-16T06:30:00Z", type: "created", by: "customer", text: "Problema no login." }
    ]
  },
  {
    _id: "TICK-00014",
    ticket_id: "TICK-00014",
    customer_id: "abef927e-091c-57c4-aa0d-316cadeac908",
    status: "IN_PROGRESS",
    created_at: "2025-07-17T17:45:00Z",
    updated_at: "2025-07-17T18:10:00Z",
    related: { order_id: 14 },
    events: [
      { ts: "2025-07-17T17:45:00Z", type: "created", by: "customer", text: "Pedido cancelado incorretamente." },
      { ts: "2025-07-17T18:10:00Z", type: "reply", by: "joao.suporte", text: "Estamos checando o status no sistema." }
    ]
  },
  {
    _id: "TICK-00015",
    ticket_id: "TICK-00015",
    customer_id: "26cb129a-b2b9-5b7b-9497-37afb473cb8d",
    status: "RESOLVED",
    created_at: "2025-07-18T10:00:00Z",
    updated_at: "2025-07-18T11:00:00Z",
    related: { order_id: 15 },
    events: [
      { ts: "2025-07-18T10:00:00Z", type: "created", by: "customer", text: "Solicitação de reembolso." },
      { ts: "2025-07-18T11:00:00Z", type: "resolved", by: "system", text: "Reembolso processado." }
    ]
  },
  {
    _id: "TICK-00016",
    ticket_id: "TICK-00016",
    customer_id: "87caccff-be5c-5876-96b6-f8d341b4ad06",
    status: "OPEN",
    created_at: "2025-07-19T09:15:00Z",
    updated_at: "2025-07-19T09:15:00Z",
    related: { order_id: 16 },
    events: [
      { ts: "2025-07-19T09:15:00Z", type: "created", by: "customer", text: "Produto danificado." }
    ]
  },
  {
    _id: "TICK-00017",
    ticket_id: "TICK-00017",
    customer_id: "5e650e72-894a-5f91-bccd-24d659e13a2a",
    status: "IN_PROGRESS",
    created_at: "2025-07-20T13:00:00Z",
    updated_at: "2025-07-20T14:20:00Z",
    related: { order_id: 17 },
    events: [
      { ts: "2025-07-20T13:00:00Z", type: "created", by: "customer", text: "Solicitar 2ª via de boleto." },
      { ts: "2025-07-20T14:20:00Z", type: "reply", by: "ana.suporte", text: "Vou te enviar por e-mail." }
    ]
  },
  {
    _id: "TICK-00018",
    ticket_id: "TICK-00018",
    customer_id: "346835d3-0c85-5a3c-8a75-0cd379aa1217",
    status: "RESOLVED",
    created_at: "2025-07-21T08:40:00Z",
    updated_at: "2025-07-21T10:00:00Z",
    related: { order_id: 18 },
    events: [
      { ts: "2025-07-21T08:40:00Z", type: "created", by: "customer", text: "Atualizar e-mail cadastrado." },
      { ts: "2025-07-21T10:00:00Z", type: "resolved", by: "system", text: "Atualizado." }
    ]
  },
  {
    _id: "TICK-00019",
    ticket_id: "TICK-00019",
    customer_id: "aad02bb1-f42a-5698-b012-381a4cbf27de",
    status: "PENDING_CUSTOMER",
    created_at: "2025-07-22T16:10:00Z",
    updated_at: "2025-07-22T16:35:00Z",
    related: { order_id: 19 },
    events: [
      { ts: "2025-07-22T16:10:00Z", type: "created", by: "customer", text: "Contestação de cobrança." },
      { ts: "2025-07-22T16:35:00Z", type: "reply", by: "maria.suporte", text: "Pode enviar o extrato?" }
    ]
  },
  {
    _id: "TICK-00020",
    ticket_id: "TICK-00020",
    customer_id: "0ca444f2-f748-5fbe-be16-1c42fcfa2056",
    status: "OPEN",
    created_at: "2025-07-23T11:55:00Z",
    updated_at: "2025-07-23T11:55:00Z",
    related: { order_id: 20 },
    events: [
      { ts: "2025-07-23T11:55:00Z", type: "created", by: "customer", text: "Pedido travado em processamento." }
    ]
  }
]);
