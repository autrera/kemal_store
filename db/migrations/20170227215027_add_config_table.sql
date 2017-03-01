-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

CREATE TABLE config(
  id SERIAL PRIMARY KEY,
  store_name VARCHAR NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE config;
