-- 02_postgres_financeiro_ledger.sql
-- PostgreSQL init: schema financeiro + tabela ledger (50 linhas)
-- Observação: sem FK (por preferência de script), mas com índice para performance.

CREATE SCHEMA IF NOT EXISTS financeiro;

CREATE TABLE IF NOT EXISTS financeiro.ledger (
  ledger_id   SERIAL PRIMARY KEY,
  customer_id UUID NOT NULL,
  entry_ts    TIMESTAMPTZ NOT NULL,
  entry_type  VARCHAR(10) NOT NULL CHECK (entry_type IN ('CREDIT','DEBIT')),
  amount      NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  description VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_ledger_customer_ts
  ON financeiro.ledger (customer_id, entry_ts);

-- Seed (50 lançamentos) - 40 débitos espelhando pedidos (orders) + 10 lançamentos variados
INSERT INTO financeiro.ledger
  (customer_id, entry_ts, entry_type, amount, description)
VALUES
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-07-06T04:00:00Z', 'DEBIT', '165.54', 'Compra (order_id=1)'),
  ('07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-07-07T23:00:00Z', 'DEBIT', '2394.31', 'Compra (order_id=2)'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-07-10T17:00:00Z', 'DEBIT', '827.74', 'Compra (order_id=3)'),
  ('0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-07-16T04:00:00Z', 'DEBIT', '1943.70', 'Compra (order_id=4)'),
  ('1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-07-16T22:00:00Z', 'DEBIT', '102.23', 'Compra (order_id=5)'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-07-19T21:00:00Z', 'DEBIT', '816.37', 'Compra (order_id=6)'),
  ('29b10156-7854-5679-899c-d8642c32e4d6', '2025-07-25T10:00:00Z', 'DEBIT', '2978.43', 'Compra (order_id=7)'),
  ('2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-07-26T19:00:00Z', 'DEBIT', '3234.25', 'Compra (order_id=8)'),
  ('36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-07-31T10:00:00Z', 'DEBIT', '3027.04', 'Compra (order_id=9)'),
  ('39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-08-01T19:00:00Z', 'DEBIT', '2723.89', 'Compra (order_id=10)'),
  ('3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-08-04T04:00:00Z', 'DEBIT', '2254.04', 'Compra (order_id=11)'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', '2025-08-08T10:00:00Z', 'DEBIT', '993.06', 'Compra (order_id=12)'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-08-10T00:00:00Z', 'DEBIT', '638.84', 'Compra (order_id=13)'),
  ('07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-08-14T01:00:00Z', 'DEBIT', '2962.55', 'Compra (order_id=14)'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-08-17T09:00:00Z', 'DEBIT', '306.37', 'Compra (order_id=15)'),
  ('0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-08-20T00:00:00Z', 'DEBIT', '2278.55', 'Compra (order_id=16)'),
  ('1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-08-22T10:00:00Z', 'DEBIT', '1923.30', 'Compra (order_id=17)'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-08-27T00:00:00Z', 'DEBIT', '3491.58', 'Compra (order_id=18)'),
  ('29b10156-7854-5679-899c-d8642c32e4d6', '2025-08-30T15:00:00Z', 'DEBIT', '627.14', 'Compra (order_id=19)'),
  ('2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-09-01T00:00:00Z', 'DEBIT', '3486.74', 'Compra (order_id=20)'),
  ('36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-09-05T07:00:00Z', 'DEBIT', '2411.45', 'Compra (order_id=21)'),
  ('39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-09-05T15:00:00Z', 'DEBIT', '620.90', 'Compra (order_id=22)'),
  ('3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-09-11T14:00:00Z', 'DEBIT', '1816.27', 'Compra (order_id=23)'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', '2025-09-13T08:00:00Z', 'DEBIT', '760.28', 'Compra (order_id=24)'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-09-14T23:00:00Z', 'DEBIT', '2128.39', 'Compra (order_id=25)'),
  ('07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-09-18T05:00:00Z', 'DEBIT', '2924.30', 'Compra (order_id=26)'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-09-21T23:00:00Z', 'DEBIT', '3318.57', 'Compra (order_id=27)'),
  ('1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-09-27T08:00:00Z', 'DEBIT', '644.73', 'Compra (order_id=29)'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-09-29T23:00:00Z', 'DEBIT', '2518.29', 'Compra (order_id=30)'),
  ('29b10156-7854-5679-899c-d8642c32e4d6', '2025-10-05T10:00:00Z', 'DEBIT', '1624.08', 'Compra (order_id=31)'),
  ('2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-10-06T09:00:00Z', 'DEBIT', '1974.41', 'Compra (order_id=32)'),
  ('36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-10-10T02:00:00Z', 'DEBIT', '862.98', 'Compra (order_id=33)'),
  ('39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-10-13T06:00:00Z', 'DEBIT', '2367.90', 'Compra (order_id=34)'),
  ('3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-10-15T12:00:00Z', 'DEBIT', '2032.97', 'Compra (order_id=35)'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', '2025-10-19T07:00:00Z', 'DEBIT', '411.50', 'Compra (order_id=36)'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-10-21T16:00:00Z', 'DEBIT', '2573.44', 'Compra (order_id=37)'),
  ('07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-10-25T01:00:00Z', 'DEBIT', '3026.92', 'Compra (order_id=38)'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-10-29T10:00:00Z', 'DEBIT', '1522.84', 'Compra (order_id=39)'),
  ('0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-11-01T00:00:00Z', 'DEBIT', '3025.81', 'Compra (order_id=40)'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-11-05T22:00:00Z', 'DEBIT', '811.02', 'Compra (order_id=42)'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-07-12T10:21:00Z', 'CREDIT', '1064.70', 'Bônus fidelidade'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-11-20T08:27:00Z', 'DEBIT', '662.27', 'Transferência recebida'),
  ('36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-11-17T11:53:00Z', 'CREDIT', '197.36', 'Estorno parcial'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-07-11T19:23:00Z', 'DEBIT', '378.75', 'Pagamento de fatura'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-12-18T13:22:00Z', 'DEBIT', '533.09', 'Pagamento de fatura'),
  ('36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-08-30T15:51:00Z', 'DEBIT', '1021.88', 'Pagamento de fatura'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-10-15T07:55:00Z', 'DEBIT', '71.72', 'Transferência enviada'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', '2025-10-06T11:54:00Z', 'DEBIT', '674.35', 'Tarifa'),
  ('2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-09-28T19:52:00Z', 'CREDIT', '2043.30', 'Reembolso'),
  ('0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-09-23T18:55:00Z', 'CREDIT', '1653.48', 'Reembolso');
