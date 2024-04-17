-- migrate:up
ALTER TABLE "song" ADD COLUMN songwhip TEXT;

-- migrate:down
ALTER TABLE "song" DROP COLUMN songwhip;
