"""
Test Supabase connection and display database schemas and tables.

Environment variables required:
  - SUPABASE_DB_HOST: Postgres host
  - SUPABASE_DB_PORT: Postgres port (default: 5432)
  - SUPABASE_DB_NAME: Postgres database (default: postgres)
  - SUPABASE_USER: Postgres database user
  - SUPABASE_PASSWORD: Postgres database password
"""

import os
import sys
from typing import Optional
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv

# Load environment variables from .env file if it exists
load_dotenv()


class SupabaseConnectionTester:
    def __init__(self):
        self.supabase_user = os.getenv("SUPABASE_USER", "postgres")
        self.supabase_password = os.getenv("SUPABASE_PASSWORD")
        self.supabase_db_host = os.getenv("SUPABASE_DB_HOST")
        self.supabase_db_port = os.getenv("SUPABASE_DB_PORT", "5432")
        self.supabase_db_name = os.getenv("SUPABASE_DB_NAME", "postgres")
        self.target_schema = os.getenv("SUPABASE_SCHEMA", "stauff_clamps")
        self.connection = None

    def validate_env_variables(self) -> bool:
        """Check if required environment variables are set."""
        print("=" * 70)
        print("ENVIRONMENT VARIABLES CHECK")
        print("=" * 70)

        if not self.supabase_db_host:
            print("❌ SUPABASE_DB_HOST not set")
            return False

        print(f"✓ SUPABASE_DB_HOST: {self.supabase_db_host}")
        print(f"✓ SUPABASE_DB_PORT: {self.supabase_db_port}")
        print(f"✓ SUPABASE_DB_NAME: {self.supabase_db_name}")
        print(f"✓ SUPABASE_USER: {self.supabase_user}")

        if not self.supabase_password:
            print("❌ SUPABASE_PASSWORD not set")
            return False
        print(f"✓ SUPABASE_PASSWORD: set")

        return True

    def extract_db_connection_string(self) -> Optional[dict]:
        """Build connection parameters for Supabase Postgres."""
        try:
            try:
                port = int(self.supabase_db_port)
            except ValueError:
                print("❌ SUPABASE_DB_PORT must be a number")
                return None

            connection_params = {
                "host": self.supabase_db_host,
                "database": self.supabase_db_name,
                "user": self.supabase_user,
                "password": self.supabase_password,
                "port": port,
                "sslmode": "require",
                "connect_timeout": 10,
            }
            return connection_params
        except Exception as e:
            print(f"❌ Error building database connection: {e}")
            return None

    def connect_to_database(self) -> bool:
        """Establish connection to Supabase Postgres database."""
        print("\n" + "=" * 70)
        print("DATABASE CONNECTION")
        print("=" * 70)

        try:
            params = self.extract_db_connection_string()
            if not params:
                return False

            print(f"Connecting to {params['host']}...")
            self.connection = psycopg2.connect(**params)
            print("✓ Connection successful!")
            return True
        except psycopg2.Error as e:
            print(f"❌ Connection failed: {e}")
            return False

    def get_schemas(self) -> list:
        """Get list of all schemas in the database."""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("""
                    SELECT schema_name
                    FROM information_schema.schemata
                    WHERE schema_name NOT LIKE 'pg_%'
                    AND schema_name != 'information_schema'
                    ORDER BY schema_name;
                """)
                return [row[0] for row in cursor.fetchall()]
        except psycopg2.Error as e:
            print(f"❌ Error fetching schemas: {e}")
            return []

    def get_tables_in_schema(self, schema: str) -> list:
        """Get list of tables in a specific schema."""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = %s
                    ORDER BY table_name;
                """, (schema,))
                return [row[0] for row in cursor.fetchall()]
        except psycopg2.Error as e:
            print(f"❌ Error fetching tables for schema {schema}: {e}")
            return []

    def get_table_columns(self, schema: str, table: str) -> list:
        """Get columns and their types for a specific table."""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute("""
                    SELECT column_name, data_type, is_nullable
                    FROM information_schema.columns
                    WHERE table_schema = %s AND table_name = %s
                    ORDER BY ordinal_position;
                """, (schema, table))
                columns = []
                for row in cursor.fetchall():
                    col_name, col_type, nullable = row
                    nullable_str = "NULL" if nullable == "YES" else "NOT NULL"
                    columns.append(f"  • {col_name}: {col_type} ({nullable_str})")
                return columns
        except psycopg2.Error as e:
            print(f"❌ Error fetching columns for {schema}.{table}: {e}")
            return []

    def get_row_count(self, schema: str, table: str) -> Optional[int]:
        """Get row count for a specific table."""
        try:
            with self.connection.cursor() as cursor:
                # Use quoted identifiers to handle table names with special characters
                cursor.execute(
                    sql.SQL("SELECT COUNT(*) FROM {}.{}").format(
                        sql.Identifier(schema), sql.Identifier(table)
                    )
                )
                return cursor.fetchone()[0]
        except psycopg2.Error as e:
            print(f"❌ Error getting row count for {schema}.{table}: {e}")
            return None

    def display_schemas_and_target_tables(self):
        """Display all schema names and only the target schema's tables."""
        print("\n" + "=" * 70)
        print("SCHEMAS")
        print("=" * 70)

        schemas = self.get_schemas()

        if not schemas:
            print("No schemas found.")
            return

        for schema in schemas:
            print(f"  • {schema}")

        print("\n" + "=" * 70)
        print(f"TABLES IN SCHEMA: {self.target_schema}")
        print("=" * 70)

        if self.target_schema not in schemas:
            print(f"Schema not found: {self.target_schema}")
            return

        tables = self.get_tables_in_schema(self.target_schema)
        if not tables:
            print("  (no tables)")
            return

        for table in tables:
            print(f"  • {table}")

    def run(self):
        """Run the full test suite."""
        print("\n")
        print("🔍 SUPABASE CONNECTION TEST")
        print("=" * 70)

        # Check environment variables
        if not self.validate_env_variables():
            print("\n❌ Missing required environment variables.")
            print("\nPlease set the following in a .env file or environment:")
            print("  SUPABASE_DB_HOST=<postgres-host>")
            print("  SUPABASE_DB_PORT=5432")
            print("  SUPABASE_DB_NAME=postgres")
            print("  SUPABASE_USER=<postgres-user>")
            print("  SUPABASE_PASSWORD=<your-postgres-password>")
            return False

        # Connect to database
        if not self.connect_to_database():
            print("\n❌ Could not connect to Supabase database.")
            print("\nTroubleshooting tips:")
            print("  • Verify SUPABASE_DB_HOST and SUPABASE_DB_PORT are correct")
            print("  • Verify SUPABASE_USER is correct")
            print("  • Verify SUPABASE_PASSWORD is correct (use database password, not API key)")
            print("  • Check that your Supabase project is active")
            print("  • Ensure your IP is whitelisted (if applicable)")
            return False

        # Display schema names and details for the requested schema only
        self.display_schemas_and_target_tables()

        print("\n" + "=" * 70)
        print("✓ Test completed successfully!")
        print("=" * 70 + "\n")

        self.close_connection()
        return True

    def close_connection(self):
        """Close database connection."""
        if self.connection:
            self.connection.close()


if __name__ == "__main__":
    tester = SupabaseConnectionTester()
    success = tester.run()
    sys.exit(0 if success else 1)
