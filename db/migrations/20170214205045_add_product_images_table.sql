-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE product_images(
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  url TEXT NOT NULL,
  relevance INT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE product_images;
