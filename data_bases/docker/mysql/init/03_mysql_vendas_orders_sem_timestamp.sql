-- 03_mysql_vendas_orders.sql
-- MySQL init: database vendas + tabelas orders e order_items (50 pedidos + 50 itens)

CREATE DATABASE IF NOT EXISTS vendas;
USE vendas;

-- Para garantir a mudança de datatype (ambiente de laboratório):
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;

CREATE TABLE IF NOT EXISTS orders (
  order_id        INT NOT NULL AUTO_INCREMENT,
  customer_id     CHAR(36) NOT NULL,
  order_ts        VARCHAR(30) NOT NULL,
  status          VARCHAR(20) NOT NULL,
  total           DECIMAL(12,2) NOT NULL,
  currency        CHAR(3) NOT NULL DEFAULT 'BRL',
  payment_method  VARCHAR(30),
  sales_channel   VARCHAR(30),
  PRIMARY KEY (order_id),
  INDEX idx_orders_customer_ts (customer_id, order_ts)
);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id INT NOT NULL AUTO_INCREMENT,
  order_id      INT NOT NULL,
  sku           VARCHAR(40) NOT NULL,
  product_name  VARCHAR(160) NOT NULL,
  quantity      INT NOT NULL,
  unit_price    DECIMAL(12,2) NOT NULL,
  line_total    DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (order_item_id),
  INDEX idx_items_order (order_id)
);

-- Seed (50 pedidos) - customer_id repetindo (subset de 12 clientes) para facilitar JOIN no CURATED
INSERT INTO orders
  (order_id, customer_id, order_ts, status, total, currency, payment_method, sales_channel)
VALUES
  (1, '072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-07-04 11:00:00', 'DELIVERED', '165.54', 'BRL', 'DEBIT_CARD', 'APP'),
  (2, '07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-07-07 13:00:00', 'SHIPPED', '2394.31', 'BRL', 'PIX', 'MARKETPLACE'),
  (3, '0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-07-10 15:00:00', 'PAID', '827.74', 'BRL', 'PIX', 'MARKETPLACE'),
  (4, '0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-07-13 17:00:00', 'DELIVERED', '1943.70', 'BRL', 'CREDIT_CARD', 'SITE'),
  (5, '1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-07-16 09:00:00', 'PROCESSING', '102.23', 'BRL', 'CREDIT_CARD', 'MARKETPLACE'),
  (6, '190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-07-19 11:00:00', 'PAID', '816.37', 'BRL', 'DEBIT_CARD', 'APP'),
  (7, '29b10156-7854-5679-899c-d8642c32e4d6', '2025-07-22 13:00:00', 'PAID', '2978.43', 'BRL', 'DEBIT_CARD', 'APP'),
  (8, '2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-07-25 15:00:00', 'PAID', '3234.25', 'BRL', 'PIX', 'MARKETPLACE'),
  (9, '36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-07-28 17:00:00', 'DELIVERED', '3027.04', 'BRL', 'CREDIT_CARD', 'MARKETPLACE'),
  (10, '39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-07-31 09:00:00', 'SHIPPED', '2723.89', 'BRL', 'PIX', 'APP'),
  (11, '3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-08-03 11:00:00', 'PAID', '2254.04', 'BRL', 'DEBIT_CARD', 'APP'),
  (12, '5188b342-ea75-5956-91b2-e01a68e88acc', '2025-08-06 13:00:00', 'PAID', '993.06', 'BRL', 'PIX', 'MARKETPLACE'),
  (13, '072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-08-09 15:00:00', 'SHIPPED', '638.84', 'BRL', 'BOLETO', 'SITE'),
  (14, '07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-08-12 17:00:00', 'SHIPPED', '2962.55', 'BRL', 'PIX', 'APP'),
  (15, '0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-08-15 09:00:00', 'DELIVERED', '306.37', 'BRL', 'DEBIT_CARD', 'APP'),
  (16, '0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-08-18 11:00:00', 'PROCESSING', '2278.55', 'BRL', 'CREDIT_CARD', 'SITE'),
  (17, '1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-08-21 13:00:00', 'SHIPPED', '1923.30', 'BRL', 'BOLETO', 'MARKETPLACE'),
  (18, '190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-08-24 15:00:00', 'PAID', '3491.58', 'BRL', 'BOLETO', 'APP'),
  (19, '29b10156-7854-5679-899c-d8642c32e4d6', '2025-08-27 17:00:00', 'PAID', '627.14', 'BRL', 'BOLETO', 'MARKETPLACE'),
  (20, '2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-08-30 09:00:00', 'PAID', '3486.74', 'BRL', 'DEBIT_CARD', 'MARKETPLACE'),
  (21, '36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-09-02 11:00:00', 'SHIPPED', '2411.45', 'BRL', 'DEBIT_CARD', 'MARKETPLACE'),
  (22, '39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-09-05 13:00:00', 'PAID', '620.90', 'BRL', 'PIX', 'MARKETPLACE'),
  (23, '3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-09-08 15:00:00', 'SHIPPED', '1816.27', 'BRL', 'PIX', 'MARKETPLACE'),
  (24, '5188b342-ea75-5956-91b2-e01a68e88acc', '2025-09-11 17:00:00', 'DELIVERED', '760.28', 'BRL', 'DEBIT_CARD', 'APP'),
  (25, '072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-09-14 09:00:00', 'PROCESSING', '2128.39', 'BRL', 'BOLETO', 'APP'),
  (26, '07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-09-17 11:00:00', 'PROCESSING', '2924.30', 'BRL', 'DEBIT_CARD', 'APP'),
  (27, '0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-09-20 13:00:00', 'PROCESSING', '3318.57', 'BRL', 'PIX', 'MARKETPLACE'),
  (28, '0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-09-23 15:00:00', 'CANCELED', '0.00', 'BRL', 'CREDIT_CARD', 'APP'),
  (29, '1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-09-26 17:00:00', 'PROCESSING', '644.73', 'BRL', 'BOLETO', 'APP'),
  (30, '190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-09-29 09:00:00', 'SHIPPED', '2518.29', 'BRL', 'BOLETO', 'MARKETPLACE'),
  (31, '29b10156-7854-5679-899c-d8642c32e4d6', '2025-10-02 11:00:00', 'PROCESSING', '1624.08', 'BRL', 'CREDIT_CARD', 'APP'),
  (32, '2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-10-05 13:00:00', 'PAID', '1974.41', 'BRL', 'CREDIT_CARD', 'APP'),
  (33, '36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-10-08 15:00:00', 'DELIVERED', '862.98', 'BRL', 'PIX', 'SITE'),
  (34, '39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-10-11 17:00:00', 'PAID', '2367.90', 'BRL', 'CREDIT_CARD', 'MARKETPLACE'),
  (35, '3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-10-14 09:00:00', 'PROCESSING', '2032.97', 'BRL', 'BOLETO', 'APP'),
  (36, '5188b342-ea75-5956-91b2-e01a68e88acc', '2025-10-17 11:00:00', 'PAID', '411.50', 'BRL', 'BOLETO', 'SITE'),
  (37, '072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-10-20 13:00:00', 'DELIVERED', '2573.44', 'BRL', 'PIX', 'APP'),
  (38, '07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-10-23 15:00:00', 'PAID', '3026.92', 'BRL', 'CREDIT_CARD', 'APP'),
  (39, '0ca444f2-f748-5fbe-be16-1c42fcfa2056', '2025-10-26 17:00:00', 'DELIVERED', '1522.84', 'BRL', 'DEBIT_CARD', 'SITE'),
  (40, '0efe4e01-e7c7-512d-b45e-aded5fc9ebec', '2025-10-29 09:00:00', 'DELIVERED', '3025.81', 'BRL', 'PIX', 'APP'),
  (41, '1525ca83-90fc-57f1-a4b9-c05fd0c79661', '2025-11-01 11:00:00', 'CANCELED', '0.00', 'BRL', 'CREDIT_CARD', 'APP'),
  (42, '190408ca-eb78-557c-a20b-dc28d3e7853f', '2025-11-04 13:00:00', 'DELIVERED', '811.02', 'BRL', 'BOLETO', 'APP'),
  (43, '29b10156-7854-5679-899c-d8642c32e4d6', '2025-11-07 15:00:00', 'PAID', '1415.24', 'BRL', 'BOLETO', 'SITE'),
  (44, '2bd5796e-f218-55e0-92f7-f44888a5c97a', '2025-11-10 17:00:00', 'CANCELED', '0.00', 'BRL', 'BOLETO', 'APP'),
  (45, '36ea566d-7fa3-5394-a4ff-894b2c121029', '2025-11-13 09:00:00', 'PAID', '3392.99', 'BRL', 'PIX', 'MARKETPLACE'),
  (46, '39485023-3f9c-5c5d-b88d-25aafe0879e1', '2025-11-16 11:00:00', 'PAID', '1710.62', 'BRL', 'CREDIT_CARD', 'APP'),
  (47, '3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', '2025-11-19 13:00:00', 'PROCESSING', '314.34', 'BRL', 'PIX', 'MARKETPLACE'),
  (48, '5188b342-ea75-5956-91b2-e01a68e88acc', '2025-11-22 15:00:00', 'PAID', '3124.78', 'BRL', 'CREDIT_CARD', 'MARKETPLACE'),
  (49, '072dcd5d-45f7-5587-94cc-0fa36325f9c8', '2025-11-25 17:00:00', 'DELIVERED', '1513.75', 'BRL', 'DEBIT_CARD', 'SITE'),
  (50, '07d56c48-8dc2-5dd6-b2ca-6452586674c8', '2025-11-28 09:00:00', 'SHIPPED', '896.31', 'BRL', 'BOLETO', 'APP')
ON DUPLICATE KEY UPDATE
  customer_id = VALUES(customer_id);

-- Seed (50 itens; 1 item por pedido)
INSERT INTO order_items
  (order_id, sku, product_name, quantity, unit_price, line_total)
VALUES
  (1, 'SKU-2001', 'Camiseta básica', 1, '165.54', '165.54'),
  (2, 'SKU-3002', 'Mochila urbana', 1, '2394.31', '2394.31'),
  (3, 'SKU-2001', 'Camiseta básica', 1, '827.74', '827.74'),
  (4, 'SKU-6001', 'Monitor 24 pol', 1, '1943.70', '1943.70'),
  (5, 'SKU-3002', 'Mochila urbana', 1, '102.23', '102.23'),
  (6, 'SKU-1002', 'Teclado mecânico', 1, '816.37', '816.37'),
  (7, 'SKU-4001', 'Livro técnico', 3, '992.81', '2978.43'),
  (8, 'SKU-2002', 'Tênis esportivo', 1, '3234.25', '3234.25'),
  (9, 'SKU-1002', 'Teclado mecânico', 1, '3027.04', '3027.04'),
  (10, 'SKU-1002', 'Teclado mecânico', 1, '2723.89', '2723.89'),
  (11, 'SKU-3001', 'Garrafa térmica', 1, '2254.04', '2254.04'),
  (12, 'SKU-1003', 'Headset gamer', 3, '331.02', '993.06'),
  (13, 'SKU-5001', 'Café especial 1kg', 1, '638.84', '638.84'),
  (14, 'SKU-1001', 'Mouse sem fio', 1, '2962.55', '2962.55'),
  (15, 'SKU-4001', 'Livro técnico', 1, '306.37', '306.37'),
  (16, 'SKU-1003', 'Headset gamer', 1, '2278.55', '2278.55'),
  (17, 'SKU-3002', 'Mochila urbana', 1, '1923.30', '1923.30'),
  (18, 'SKU-1001', 'Mouse sem fio', 1, '3491.58', '3491.58'),
  (19, 'SKU-1002', 'Teclado mecânico', 2, '313.57', '627.14'),
  (20, 'SKU-1001', 'Mouse sem fio', 1, '3486.74', '3486.74'),
  (21, 'SKU-3001', 'Garrafa térmica', 1, '2411.45', '2411.45'),
  (22, 'SKU-2002', 'Tênis esportivo', 1, '620.90', '620.90'),
  (23, 'SKU-2002', 'Tênis esportivo', 1, '1816.27', '1816.27'),
  (24, 'SKU-5001', 'Café especial 1kg', 1, '760.28', '760.28'),
  (25, 'SKU-1002', 'Teclado mecânico', 1, '2128.39', '2128.39'),
  (26, 'SKU-1001', 'Mouse sem fio', 1, '2924.30', '2924.30'),
  (27, 'SKU-4001', 'Livro técnico', 1, '3318.57', '3318.57'),
  (28, 'SKU-4001', 'Livro técnico', 1, '0.00', '0.00'),
  (29, 'SKU-5001', 'Café especial 1kg', 1, '644.73', '644.73'),
  (30, 'SKU-3001', 'Garrafa térmica', 1, '2518.29', '2518.29'),
  (31, 'SKU-1002', 'Teclado mecânico', 1, '1624.08', '1624.08'),
  (32, 'SKU-1002', 'Teclado mecânico', 1, '1974.41', '1974.41'),
  (33, 'SKU-1002', 'Teclado mecânico', 3, '287.66', '862.98'),
  (34, 'SKU-1003', 'Headset gamer', 1, '2367.90', '2367.90'),
  (35, 'SKU-4001', 'Livro técnico', 1, '2032.97', '2032.97'),
  (36, 'SKU-3002', 'Mochila urbana', 2, '205.75', '411.50'),
  (37, 'SKU-3002', 'Mochila urbana', 4, '643.36', '2573.44'),
  (38, 'SKU-2001', 'Camiseta básica', 1, '3026.92', '3026.92'),
  (39, 'SKU-2001', 'Camiseta básica', 1, '1522.84', '1522.84'),
  (40, 'SKU-5001', 'Café especial 1kg', 1, '3025.81', '3025.81'),
  (41, 'SKU-3002', 'Mochila urbana', 1, '0.00', '0.00'),
  (42, 'SKU-1003', 'Headset gamer', 2, '405.51', '811.02'),
  (43, 'SKU-3002', 'Mochila urbana', 4, '353.81', '1415.24'),
  (44, 'SKU-2001', 'Camiseta básica', 1, '0.00', '0.00'),
  (45, 'SKU-3001', 'Garrafa térmica', 1, '3392.99', '3392.99'),
  (46, 'SKU-5001', 'Café especial 1kg', 1, '1710.62', '1710.62'),
  (47, 'SKU-2001', 'Camiseta básica', 2, '157.17', '314.34'),
  (48, 'SKU-6001', 'Monitor 24 pol', 1, '3124.78', '3124.78'),
  (49, 'SKU-2001', 'Camiseta básica', 1, '1513.75', '1513.75'),
  (50, 'SKU-2002', 'Tênis esportivo', 1, '896.31', '896.31');
