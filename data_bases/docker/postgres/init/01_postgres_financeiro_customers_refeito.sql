-- 01_postgres_financeiro_customers.sql
-- PostgreSQL init: schema financeiro + tabela customers (50 linhas)

CREATE SCHEMA IF NOT EXISTS financeiro;

CREATE TABLE IF NOT EXISTS financeiro.customers (
  customer_id UUID PRIMARY KEY,
  full_name   VARCHAR(120) NOT NULL,
  email       VARCHAR(200) NOT NULL UNIQUE,
  phone       VARCHAR(30),
  city        VARCHAR(80),
  state       CHAR(2),
  created_at  DATE NOT NULL
);

-- Seed (50 clientes) - IDs compatíveis com MySQL (orders) + Mongo (tickets)
INSERT INTO financeiro.customers
  (customer_id, full_name, email, phone, city, state, created_at)
VALUES
  ('00004cd4-45c2-519c-8214-f5d292944503', 'Ana Souza', 'ana.souza01@exemplo.com.br', '+55 31 95012-4657', 'Belo Horizonte', 'MG', '2025-09-09'),
  ('0efe4e01-e7c7-512d-b45e-aded5fc9ebec', 'Bruno Lima', 'bruno.lima02@exemplo.com.br', '+55 31 99935-2424', 'Florianópolis', 'SC', '2025-07-27'),
  ('190408ca-eb78-557c-a20b-dc28d3e7853f', 'Carla Melo', 'carla.melo03@exemplo.com.br', '+55 31 91488-2535', 'Recife', 'PE', '2025-07-09'),
  ('072dcd5d-45f7-5587-94cc-0fa36325f9c8', 'Daniel Almeida', 'daniel.almeida04@exemplo.com.br', '+55 31 91434-4257', 'Curitiba', 'PR', '2025-11-07'),
  ('7a556456-f424-5d9a-bac4-443dd7ac7ff3', 'Eduarda Pereira', 'eduarda.pereira05@exemplo.com.br', '+55 31 98359-5557', 'Recife', 'PE', '2025-08-26'),
  ('6e7f40e3-321b-576a-998c-132f6978fcca', 'Felipe Silva', 'felipe.silva06@exemplo.com.br', '+55 31 96574-5552', 'Rio de Janeiro', 'RJ', '2025-10-17'),
  ('7fea6830-3ca8-50dd-a843-81af97bd3c3a', 'Gabriela Lima', 'gabriela.lima07@exemplo.com.br', '+55 31 92674-2519', 'Curitiba', 'PR', '2025-09-25'),
  ('36ea566d-7fa3-5394-a4ff-894b2c121029', 'Henrique Rocha', 'henrique.rocha08@exemplo.com.br', '+55 31 96635-5333', 'São Paulo', 'SP', '2025-09-30'),
  ('73dbb2b2-6cc0-5f55-a55b-34a2ed3910e1', 'Isabela Santos', 'isabela.santos09@exemplo.com.br', '+55 31 99785-3045', 'Florianópolis', 'SC', '2025-10-26'),
  ('facf3687-dbe1-5ade-b6a9-aabce8511c18', 'João Rocha', 'joao.rocha10@exemplo.com.br', '+55 31 95803-6925', 'São Paulo', 'SP', '2025-11-19'),
  ('6331dd1f-82d1-5c0c-bc68-6239f5d2a2ef', 'Kamila Melo', 'kamila.melo11@exemplo.com.br', '+55 31 91750-4733', 'Curitiba', 'PR', '2025-07-18'),
  ('ff5dd317-9906-5b24-8fae-139edbcae5ce', 'Lucas Carvalho', 'lucas.carvalho12@exemplo.com.br', '+55 31 92654-7227', 'São Paulo', 'SP', '2025-08-29'),
  ('d68478ae-b3c5-51eb-927f-8738928d6a11', 'Mariana Ribeiro', 'mariana.ribeiro13@exemplo.com.br', '+55 31 96977-3664', 'Fortaleza', 'CE', '2025-12-10'),
  ('abef927e-091c-57c4-aa0d-316cadeac908', 'Nicolas Martins', 'nicolas.martins14@exemplo.com.br', '+55 31 95374-2169', 'Salvador', 'BA', '2025-08-23'),
  ('26cb129a-b2b9-5b7b-9497-37afb473cb8d', 'Olívia Freitas', 'olivia.freitas15@exemplo.com.br', '+55 31 99751-5010', 'Goiânia', 'GO', '2025-08-13'),
  ('87caccff-be5c-5876-96b6-f8d341b4ad06', 'Pedro Ferreira', 'pedro.ferreira16@exemplo.com.br', '+55 31 95422-4598', 'Fortaleza', 'CE', '2025-10-06'),
  ('5e650e72-894a-5f91-bccd-24d659e13a2a', 'Quésia Gomes', 'quesia.gomes17@exemplo.com.br', '+55 31 91525-6168', 'Belo Horizonte', 'MG', '2025-08-28'),
  ('346835d3-0c85-5a3c-8a75-0cd379aa1217', 'Rafael Rocha', 'rafael.rocha18@exemplo.com.br', '+55 31 94456-6155', 'Porto Alegre', 'RS', '2025-07-17'),
  ('aad02bb1-f42a-5698-b012-381a4cbf27de', 'Sofia Almeida', 'sofia.almeida19@exemplo.com.br', '+55 31 97482-8517', 'Goiânia', 'GO', '2025-11-05'),
  ('0ca444f2-f748-5fbe-be16-1c42fcfa2056', 'Tiago Lima', 'tiago.lima20@exemplo.com.br', '+55 31 95040-9830', 'Porto Alegre', 'RS', '2025-08-05'),
  ('794e140c-d76f-5300-90af-925a6f0304b5', 'Ursula Ribeiro', 'ursula.ribeiro21@exemplo.com.br', '+55 31 98019-7543', 'Florianópolis', 'SC', '2025-11-27'),
  ('29b10156-7854-5679-899c-d8642c32e4d6', 'Victor Martins', 'victor.martins22@exemplo.com.br', '+55 31 99348-9085', 'Curitiba', 'PR', '2025-08-05'),
  ('a6297394-0650-538f-a073-9f9b47d567de', 'Wesley Oliveira', 'wesley.oliveira23@exemplo.com.br', '+55 31 93504-3621', 'Belo Horizonte', 'MG', '2025-07-29'),
  ('5188b342-ea75-5956-91b2-e01a68e88acc', 'Ximena Barbosa', 'ximena.barbosa24@exemplo.com.br', '+55 31 97304-7252', 'Campinas', 'SP', '2025-07-17'),
  ('bf329c1d-7ccf-59ea-8e10-2ebcc65ad553', 'Yasmin Freitas', 'yasmin.freitas25@exemplo.com.br', '+55 31 95119-1188', 'Fortaleza', 'CE', '2025-11-13'),
  ('42203d84-66ac-5ece-915c-8bad7b55f5ac', 'Zeca Souza', 'zeca.souza26@exemplo.com.br', '+55 31 95371-6573', 'Goiânia', 'GO', '2025-11-15'),
  ('fd3b1473-b204-5c85-b3b0-b146f9734021', 'Aline Souza', 'aline.souza27@exemplo.com.br', '+55 31 93591-8433', 'Porto Alegre', 'RS', '2025-10-20'),
  ('ddd81c75-d827-52a5-9e57-12343178bf24', 'Beatriz Silva', 'beatriz.silva28@exemplo.com.br', '+55 31 99201-3927', 'Florianópolis', 'SC', '2025-09-06'),
  ('bce98c5a-b632-522d-a654-68c70a00dc1e', 'Caio Araujo', 'caio.araujo29@exemplo.com.br', '+55 31 95889-9317', 'São Paulo', 'SP', '2025-12-08'),
  ('d7365ceb-114d-58ff-a89a-850e3db2bfca', 'Diego Freitas', 'diego.freitas30@exemplo.com.br', '+55 31 97126-3646', 'Curitiba', 'PR', '2025-08-09'),
  ('07d56c48-8dc2-5dd6-b2ca-6452586674c8', 'Elaine Pereira', 'elaine.pereira31@exemplo.com.br', '+55 31 96310-9005', 'Brasília', 'DF', '2025-07-01'),
  ('2bd5796e-f218-55e0-92f7-f44888a5c97a', 'Fábio Silva', 'fabio.silva32@exemplo.com.br', '+55 31 96038-4923', 'São Paulo', 'SP', '2025-10-01'),
  ('a1e74943-5f01-5bbb-a1e3-9ef3875d837f', 'Giovana Santos', 'giovana.santos33@exemplo.com.br', '+55 31 92290-2403', 'Curitiba', 'PR', '2025-11-23'),
  ('d5be045e-5916-5db6-9738-2cba8ff02417', 'Heitor Teixeira', 'heitor.teixeira34@exemplo.com.br', '+55 31 93060-3103', 'São Paulo', 'SP', '2025-11-14'),
  ('08005c28-e6ba-516d-9c7a-5735efa27eb5', 'Ícaro Teixeira', 'icaro.teixeira35@exemplo.com.br', '+55 31 95342-9645', 'Brasília', 'DF', '2025-08-12'),
  ('8ac6788a-c0c1-5dd0-88b2-2b9a628d7be1', 'Juliana Freitas', 'juliana.freitas36@exemplo.com.br', '+55 31 99835-4295', 'Recife', 'PE', '2025-08-24'),
  ('e3d53058-358c-5e1d-8bfc-2a62adb0a896', 'Kelly Carvalho', 'kelly.carvalho37@exemplo.com.br', '+55 31 97118-8177', 'Recife', 'PE', '2025-12-14'),
  ('278043af-65c0-5bed-81c7-da7de17318e4', 'Leandro Araujo', 'leandro.araujo38@exemplo.com.br', '+55 31 95061-4681', 'Fortaleza', 'CE', '2025-07-31'),
  ('3d20e1d0-8309-572e-9a6f-0de23c2e7d9e', 'Mônica Oliveira', 'mônica.oliveira39@exemplo.com.br', '+55 31 94770-4608', 'Salvador', 'BA', '2025-07-06'),
  ('1525ca83-90fc-57f1-a4b9-c05fd0c79661', 'Natália Silva', 'natalia.silva40@exemplo.com.br', '+55 31 91964-4750', 'São Paulo', 'SP', '2025-12-09'),
  ('dbf91a13-df0c-5e29-8fab-aabab9a574b2', 'Otávio Oliveira', 'otavio.oliveira41@exemplo.com.br', '+55 31 92160-9423', 'Belo Horizonte', 'MG', '2025-09-23'),
  ('193668ae-2f42-57a0-98a2-ecbd490e5887', 'Patrícia Costa', 'patricia.costa42@exemplo.com.br', '+55 31 94510-9834', 'Porto Alegre', 'RS', '2025-11-02'),
  ('c6039ea3-82c2-5671-aa6f-601b5cef58fd', 'Renato Lima', 'renato.lima43@exemplo.com.br', '+55 31 98744-4981', 'Florianópolis', 'SC', '2025-11-24'),
  ('c932a17f-3343-5d42-9c13-8ec5f237bd8c', 'Simone Teixeira', 'simone.teixeira44@exemplo.com.br', '+55 31 92545-2588', 'Recife', 'PE', '2025-08-18'),
  ('a95cc9e3-0e00-5382-86bd-8762b5743521', 'Tatiane Barbosa', 'tatiane.barbosa45@exemplo.com.br', '+55 31 97735-8651', 'Salvador', 'BA', '2025-10-17'),
  ('f788dae8-3f5c-562f-9cf1-9dedcfc1f27b', 'Vitor Santos', 'vitor.santos46@exemplo.com.br', '+55 31 92612-1993', 'Goiânia', 'GO', '2025-12-15'),
  ('39485023-3f9c-5c5d-b88d-25aafe0879e1', 'William Rocha', 'william.rocha47@exemplo.com.br', '+55 31 92790-5073', 'Florianópolis', 'SC', '2025-09-25'),
  ('5a00f1b7-1b60-56ff-9b8b-9d2d3e99d43d', 'Xavier Almeida', 'xavier.almeida48@exemplo.com.br', '+55 31 98350-3296', 'Curitiba', 'PR', '2025-11-15'),
  ('537e6ec7-ce6e-541c-a617-79277c9e4e8d', 'Yuri Barbosa', 'yuri.barbosa49@exemplo.com.br', '+55 31 98579-5092', 'Rio de Janeiro', 'RJ', '2025-09-10'),
  ('e1353ad4-af1e-5650-af94-9c1ee0004d51', 'Zuleica Oliveira', 'zuleica.oliveira50@exemplo.com.br', '+55 31 92604-1828', 'Fortaleza', 'CE', '2025-11-18')
ON CONFLICT (customer_id) DO NOTHING;
