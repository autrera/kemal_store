-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

ALTER TABLE products ADD COLUMN description TEXT DEFAULT NULL;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

ALTER TABLE products DROP COLUMN description RESTRICT;