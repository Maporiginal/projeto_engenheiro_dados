CREATE DATABASE IF NOT EXISTS vendas
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vendas;

CREATE TABLE IF NOT EXISTS orders (
  order_id    CHAR(36) PRIMARY KEY,
  customer_id CHAR(36) NOT NULL,
  status      VARCHAR(20) NOT NULL,
  total       DECIMAL(12,2) NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX ix_orders_customer_time (customer_id, created_at)
);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id      CHAR(36) NOT NULL,
  sku           VARCHAR(50) NOT NULL,
  qty           INT NOT NULL,
  unit_price    DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  INDEX ix_items_order (order_id)
);

-- Seed (customer_id casa com o Postgres/Mongo)
INSERT IGNORE INTO orders (order_id, customer_id, status, total)
VALUES
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'PAID',    349.80),
  ('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '22222222-2222-2222-2222-222222222222', 'PENDING', 129.90);

INSERT INTO order_items (order_id, sku, qty, unit_price)
VALUES
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'SKU-001', 1, 299.90),
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'SKU-002', 1,  49.90),
  ('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'SKU-003', 1, 129.90);