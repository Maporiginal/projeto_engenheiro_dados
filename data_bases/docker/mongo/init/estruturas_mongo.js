db = db.getSiblingDB("suporte");

// (Opcional) criar usuário da aplicação no DB suporte
try {
  db.createUser({
    user: "mongo_user",
    pwd:  "mongo_user",
    roles: [{ role: "readWrite", db: "suporte" }]
  });
} catch (e) {
  // se já existir, ignora
}

db.createCollection("tickets");

db.tickets.createIndex({ customer_id: 1, created_at: -1 });
db.tickets.createIndex({ status: 1, created_at: -1 });

db.tickets.insertMany([
  {
    ticket_id: "bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1",
    customer_id: "11111111-1111-1111-1111-111111111111",
    subject: "Cobrança duplicada",
    status: "OPEN",
    created_at: new Date(),
    interactions: [
      { at: new Date(), from: "customer", message: "Vi duas cobranças, pode verificar?" }
    ]
  },
  {
    ticket_id: "bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2",
    customer_id: "22222222-2222-2222-2222-222222222222",
    subject: "Pedido não atualiza",
    status: "IN_PROGRESS",
    created_at: new Date(),
    interactions: [
      { at: new Date(), from: "customer", message: "Paguei e segue PENDING." }
    ]
  }
]);