-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE categories_products(
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL,
  product_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE categories_products;
