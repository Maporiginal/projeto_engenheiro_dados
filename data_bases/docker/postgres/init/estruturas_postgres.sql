CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS financeiro;
SET search_path TO financeiro;

-- Clientes (base do customer_360)
CREATE TABLE IF NOT EXISTS customers (
  customer_id UUID PRIMARY KEY,
  full_name   TEXT NOT NULL,
  email       TEXT UNIQUE NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lançamentos financeiros (super simples)
CREATE TABLE IF NOT EXISTS ledger (
  ledger_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(customer_id),
  kind        TEXT NOT NULL CHECK (kind IN ('INVOICE','PAYMENT')),
  amount      NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  ref         TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_ledger_customer_time
  ON ledger (customer_id, created_at DESC);

-- Seed (UUID fixo pra casar com MySQL e Mongo)
INSERT INTO customers (customer_id, full_name, email)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Ana Souza',   'ana@demo.com'),
  ('22222222-2222-2222-2222-222222222222', 'Bruno Lima',  'bruno@demo.com'),
  ('33333333-3333-3333-3333-333333333333', 'Carla Rocha', 'carla@demo.com')
ON CONFLICT DO NOTHING;

INSERT INTO ledger (customer_id, kind, amount, ref)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'INVOICE', 199.90, 'FAT-0001'),
  ('11111111-1111-1111-1111-111111111111', 'PAYMENT', 199.90, 'PIX-ANA-01'),
  ('22222222-2222-2222-2222-222222222222', 'INVOICE',  89.90, 'FAT-0002')
ON CONFLICT DO NOTHING;