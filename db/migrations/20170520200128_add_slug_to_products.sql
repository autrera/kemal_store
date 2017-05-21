-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE products ADD COLUMN slug TEXT;
UPDATE products SET slug = '';
ALTER TABLE products ALTER COLUMN slug SET NOT NULL;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE products DROP COLUMN slug RESTRICT;
