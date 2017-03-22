-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE products ADD COLUMN featured BOOLEAN;
UPDATE products SET featured = 'f';
ALTER TABLE products ALTER COLUMN featured SET NOT NULL;
ALTER TABLE products ALTER COLUMN featured SET DEFAULT FALSE;

ALTER TABLE products ADD COLUMN in_home BOOLEAN;
UPDATE products SET in_home = 'f';
ALTER TABLE products ALTER COLUMN in_home SET NOT NULL;
ALTER TABLE products ALTER COLUMN in_home SET DEFAULT FALSE;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE products DROP COLUMN featured RESTRICT;
ALTER TABLE products DROP COLUMN in_home RESTRICT;
