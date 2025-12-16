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

-- Seed (50 lançamentos)
INSERT INTO financeiro.ledger
  (customer_id, entry_ts, entry_type, amount, description)
VALUES
  ('193668ae-2f42-57a0-98a2-ecbd490e5887', '2025-08-30T05:26:31Z', 'CREDIT', '2423.11', 'Cashback'),
  ('abef927e-091c-57c4-aa0d-316cadeac908', '2025-08-12T12:00:24Z', 'DEBIT', '2258.06', 'Transferência recebida'),
  ('d7365ceb-114d-58ff-a89a-850e3db2bfca', '2025-11-20T21:45:31Z', 'DEBIT', '1069.06', 'Compra em loja'),
  ('d68478ae-b3c5-51eb-927f-8738928d6a11', '2025-07-15T18:47:34Z', 'DEBIT', '559.90', 'Pagamento de fatura'),
  ('5a00f1b7-1b60-56ff-9b8b-9d2d3e99d43d', '2025-11-27T15:32:58Z', 'DEBIT', '161.77', 'Compra em loja'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-07-18T19:04:43Z', 'CREDIT', '2131.33', 'Assinatura mensal'),
  ('42203d84-66ac-5ece-915c-8bad7b55f5ac', '2025-11-23T07:37:38Z', 'CREDIT', '2355.16', 'Pagamento de fatura'),
  ('1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-11-27T18:33:20Z', 'CREDIT', '1059.68', 'Transferência recebida'),
  ('abef927e-091c-57c4-aa0d-316cadeac908', '2025-10-10T04:42:41Z', 'DEBIT', '611.94', 'Transferência recebida'),
  ('d7365ceb-114d-58ff-a89a-850e3db2bfca', '2025-07-19T00:29:39Z', 'DEBIT', '2323.97', 'Estorno'),
  ('7a556456-f424-5d9a-bac4-443dd7ac7ff3', '2025-08-03T11:56:04Z', 'CREDIT', '1274.59', 'Assinatura mensal'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', '2025-11-17T22:19:39Z', 'DEBIT', '411.21', 'Pagamento de fatura'),
  ('c6039ea3-82c2-5671-aa6f-601b5cef58fd', '2025-07-27T04:16:07Z', 'DEBIT', '2330.75', 'Estorno'),
  ('5a00f1b7-1b60-56ff-9b8b-9d2d3e99d43d', '2025-12-02T06:45:21Z', 'CREDIT', '695.42', 'Assinatura mensal'),
  ('c932a17f-3343-5d42-9c13-8ec5f237bd8c', '2025-09-03T01:05:40Z', 'DEBIT', '1273.41', 'Taxa de serviço'),
  ('346835d3-0c85-5a3c-8a75-0cd379aa1217', '2025-08-03T20:16:10Z', 'CREDIT', '28.79', 'Cashback'),
  ('8ac6788a-c0c1-5dd0-88b2-2b9a628d7be1', '2025-07-29T02:56:44Z', 'DEBIT', '1411.05', 'Compra em loja'),
  ('08005c28-e6ba-516d-9c7a-5735efa27eb5', '2025-11-27T17:09:27Z', 'CREDIT', '2089.80', 'Compra em loja'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-07-11T11:13:43Z', 'DEBIT', '924.34', 'Assinatura mensal'),
  ('c6039ea3-82c2-5671-aa6f-601b5cef58fd', '2025-11-21T13:39:47Z', 'CREDIT', '897.12', 'Compra em loja'),
  ('87caccff-be5c-5876-96b6-f8d341b4ad06', '2025-08-15T13:01:11Z', 'CREDIT', '2440.99', 'Transferência enviada'),
  ('fd3b1473-b204-5c85-b3b0-b146f9734021', '2025-07-28T12:55:02Z', 'CREDIT', '681.68', 'Cashback'),
  ('26cb129a-b2b9-5b7b-9497-37afb473cb8d', '2025-10-26T11:19:52Z', 'CREDIT', '2045.13', 'Assinatura mensal'),
  ('26cb129a-b2b9-5b7b-9497-37afb473cb8d', '2025-10-11T10:17:55Z', 'CREDIT', '1656.88', 'Estorno'),
  ('e1353ad4-af1e-5650-af94-9c1ee0004d51', '2025-11-08T12:43:53Z', 'DEBIT', '890.84', 'Transferência enviada'),
  ('0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-09-05T05:37:16Z', 'CREDIT', '2195.06', 'Pagamento de fatura'),
  ('7fea6830-3ca8-50dd-a843-81af97bd3c3a', '2025-09-19T13:38:32Z', 'DEBIT', '877.30', 'Estorno'),
  ('bf329c1d-7ccf-59ea-8e10-2ebcc65ad553', '2025-10-20T00:33:59Z', 'CREDIT', '651.71', 'Assinatura mensal'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', '2025-09-23T19:20:42Z', 'DEBIT', '193.54', 'Estorno'),
  ('39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-10-13T10:25:44Z', 'DEBIT', '1277.66', 'Transferência recebida'),
  ('8ac6788a-c0c1-5dd0-88b2-2b9a628d7be1', '2025-10-06T21:47:57Z', 'CREDIT', '495.76', 'Compra em loja'),
  ('1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-07-01T09:18:13Z', 'DEBIT', '1027.07', 'Taxa de serviço'),
  ('278043af-65c0-5bed-81c7-da7de17318e4', '2025-10-22T21:13:32Z', 'DEBIT', '1173.17', 'Cashback'),
  ('5a00f1b7-1b60-56ff-9b8b-9d2d3e99d43d', '2025-09-11T16:42:40Z', 'CREDIT', '1653.95', 'Transferência enviada'),
  ('6e7f40e3-321b-576a-998c-132f6978fcca', '2025-08-27T06:09:01Z', 'CREDIT', '1688.53', 'Pagamento de fatura'),
  ('87caccff-be5c-5876-96b6-f8d341b4ad06', '2025-07-19T14:26:56Z', 'DEBIT', '1535.96', 'Assinatura mensal'),
  ('f788dae8-3f5c-562f-9cf1-9dedcfc1f27b', '2025-09-01T04:41:44Z', 'DEBIT', '1246.06', 'Pagamento de fatura'),
  ('537e6ec7-ce6e-541c-a617-79277c9e4e8d', '2025-08-26T05:51:44Z', 'CREDIT', '1950.48', 'Cashback'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-08-01T14:08:51Z', 'CREDIT', '2295.33', 'Cashback'),
  ('c6039ea3-82c2-5671-aa6f-601b5cef58fd', '2025-10-22T19:52:46Z', 'DEBIT', '2376.10', 'Taxa de serviço'),
  ('8ac6788a-c0c1-5dd0-88b2-2b9a628d7be1', '2025-10-30T14:16:48Z', 'DEBIT', '2245.08', 'Assinatura mensal'),
  ('dbf91a13-df0c-5e29-8fab-aabab9a574b2', '2025-11-11T15:40:15Z', 'DEBIT', '1919.22', 'Transferência recebida'),
  ('bce98c5a-b632-522d-a654-68c70a00dc1e', '2025-08-30T08:21:20Z', 'CREDIT', '1789.59', 'Estorno'),
  ('73dbb2b2-6cc0-5f55-a55b-34a2ed3910e1', '2025-08-09T22:13:04Z', 'CREDIT', '593.53', 'Taxa de serviço'),
  ('fd3b1473-b204-5c85-b3b0-b146f9734021', '2025-10-15T01:13:53Z', 'DEBIT', '1365.68', 'Taxa de serviço'),
  ('bf329c1d-7ccf-59ea-8e10-2ebcc65ad553', '2025-11-25T12:30:00Z', 'CREDIT', '2144.70', 'Transferência enviada'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-10-16T17:47:47Z', 'DEBIT', '2136.55', 'Assinatura mensal'),
  ('2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-11-02T00:24:21Z', 'CREDIT', '696.88', 'Taxa de serviço'),
  ('39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-08-02T19:34:01Z', 'CREDIT', '2104.45', 'Taxa de serviço'),
  ('278043af-65c0-5bed-81c7-da7de17318e4', '2025-10-18T04:55:29Z', 'CREDIT', '228.19', 'Compra em loja');
