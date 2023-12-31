import * as Knex from 'knex';

export async function up(knex: Knex): Promise<void> {
  return knex.schema.createTable('url', function (table) {
    table.string('short_url', 16).primary();
    table.string('original_url', 1024).notNullable().index();
    table.timestamp('created_at').notNullable();
    table.timestamp('expire_at').notNullable();
  });
}

export async function down(knex: Knex): Promise<void> {
  return knex.schema.dropTable('url');
}
