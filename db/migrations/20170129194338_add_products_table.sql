-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE products(
  id INT PRIMARY KEY,
  organization_id INT NOT NULL,
  name VARCHAR NOT NULL,
  sku VARCHAR NOT NULL,
  stock INT NOT NULL,
  price INT NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE products;
