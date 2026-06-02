"""
Test Supabase connection using REST API credentials (old env format).

This script uses the Supabase Python client to connect via REST API.
It requires these environment variables from the old format:
  - SUPABASE_URL: Your Supabase project URL
  - SUPABASE_KEY: Your Supabase API key
  - SUPABASE_PASSWORD: Your Postgres database password

The REST API approach works without needing the database host.
For direct Postgres access, the SUPABASE_DB_HOST can be optionally added to .env.
"""

import os
import sys
from dotenv import load_dotenv
from supabase import create_client, Client
import psycopg2
from psycopg2 import sql

# Load environment variables from .env file if it exists
load_dotenv()


class SupabaseRestAPITester:
    def __init__(self):
        self.supabase_url = os.getenv("SUPABASE_URL", "").strip()
        self.supabase_key = os.getenv("SUPABASE_KEY", "").strip()
        self.db_password = os.getenv("SUPABASE_PASSWORD", "").strip()
        self.db_user = os.getenv("SUPABASE_USER", "postgres").strip()
        self.db_host = os.getenv("SUPABASE_DB_HOST", "").strip()
        self.db_port = os.getenv("SUPABASE_DB_PORT", "5432").strip()
        self.db_name = os.getenv("SUPABASE_DB_NAME", "postgres").strip()
        self.supabase_client: Client = None
        self.postgres_connection = None

    def validate_env_variables(self) -> bool:
        """Check if required environment variables are set."""
        print("=" * 70)
        print("ENVIRONMENT VARIABLES CHECK")
        print("=" * 70)

        if not self.supabase_url:
            print("❌ SUPABASE_URL not set")
            return False
        print(f"✓ SUPABASE_URL: {self.supabase_url}")

        if not self.supabase_key:
            print("❌ SUPABASE_KEY not set")
            return False
        print(f"✓ SUPABASE_KEY: {self.supabase_key[:20]}...")

        if not self.db_password:
            print("❌ SUPABASE_PASSWORD not set")
            return False
        print(f"✓ SUPABASE_PASSWORD: set")

        print(f"✓ SUPABASE_USER: {self.db_user}")

        if self.db_host:
            print(f"✓ SUPABASE_DB_HOST: {self.db_host}")

        return True

    def connect_rest_api(self) -> bool:
        """Connect to Supabase using REST API."""
        print("\n" + "=" * 70)
        print("REST API CONNECTION")
        print("=" * 70)

        try:
            print(f"Connecting to {self.supabase_url}...")
            self.supabase_client = create_client(self.supabase_url, self.supabase_key)
            print("✓ REST API connection established!")
            return True
        except Exception as e:
            print(f"❌ REST API connection failed: {e}")
            return False

    def connect_direct_postgres(self) -> bool:
        """Try direct Postgres connection."""
        if not self.db_password:
            print("\n⚠ SUPABASE_PASSWORD not set, skipping direct Postgres connection")
            return False

        if not self.db_host:
            print("\n⚠ SUPABASE_DB_HOST not set, cannot connect directly to Postgres")
            return False

        print("\n" + "=" * 70)
        print("DIRECT POSTGRES CONNECTION")
        print("=" * 70)

        try:
            print(f"Connecting to {self.db_user}@{self.db_host}:{self.db_port}/{self.db_name}...")
            self.postgres_connection = psycopg2.connect(
                host=self.db_host,
                port=int(self.db_port),
                database=self.db_name,
                user=self.db_user,
                password=self.db_password,
                connect_timeout=5,
            )
            print("✓ Postgres connection established!")
            return True
        except psycopg2.Error as e:
            print(f"❌ Postgres connection failed: {e}")
            return False

    def get_schemas_via_postgres(self) -> list:
        """Get schemas via direct Postgres connection."""
        try:
            with self.postgres_connection.cursor() as cursor:
                cursor.execute("""
                    SELECT schema_name
                    FROM information_schema.schemata
                    WHERE schema_name NOT LIKE 'pg_%'
                    AND schema_name != 'information_schema'
                    ORDER BY schema_name;
                """)
                return [row[0] for row in cursor.fetchall()]
        except Exception as e:
            print(f"❌ Error fetching schemas: {e}")
            return []

    def get_tables_in_schema(self, schema: str) -> list:
        """Get tables in a schema."""
        try:
            with self.postgres_connection.cursor() as cursor:
                cursor.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = %s
                    ORDER BY table_name;
                """, (schema,))
                return [row[0] for row in cursor.fetchall()]
        except Exception as e:
            return []

    def get_table_columns(self, schema: str, table: str) -> list:
        """Get columns for a table."""
        try:
            with self.postgres_connection.cursor() as cursor:
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
        except Exception as e:
            return []

    def get_row_count(self, schema: str, table: str):
        """Get row count for a table."""
        try:
            with self.postgres_connection.cursor() as cursor:
                cursor.execute(
                    sql.SQL("SELECT COUNT(*) FROM {}.{}").format(
                        sql.Identifier(schema), sql.Identifier(table)
                    )
                )
                return cursor.fetchone()[0]
        except Exception:
            return None

    def display_schemas_and_tables(self):
        """Display all schemas and tables."""
        print("\n" + "=" * 70)
        print("SCHEMAS AND TABLES")
        print("=" * 70)

        schemas = self.get_schemas_via_postgres()

        if not schemas:
            print("No schemas found.")
            return

        for schema in schemas:
            print(f"\n📦 Schema: {schema}")
            print("-" * 70)

            tables = self.get_tables_in_schema(schema)
            if not tables:
                print("  (no tables)")
                continue

            for table in tables:
                row_count = self.get_row_count(schema, table)
                row_str = f" [{row_count} rows]" if row_count is not None else ""
                print(f"\n  📋 Table: {table}{row_str}")

                columns = self.get_table_columns(schema, table)
                if columns:
                    for col in columns:
                        print(col)

    def run(self):
        """Run the full test suite."""
        print("\n")
        print("🔍 SUPABASE CONNECTION TEST (Old ENV Format)")
        print("=" * 70)

        # Check environment variables
        if not self.validate_env_variables():
            print("\n❌ Missing required environment variables.")
            return False

        # Try REST API connection
        if not self.connect_rest_api():
            print("\n❌ REST API connection failed")
            return False

        # Try direct Postgres connection
        if self.connect_direct_postgres():
            self.display_schemas_and_tables()
        else:
            print("\n⚠ Direct Postgres connection not available")
            print("   To enable database schema/table access, add to .env:")
            print("   SUPABASE_DB_HOST=<your-database-host>")
            print("   SUPABASE_DB_PORT=5432")
            print("   SUPABASE_DB_NAME=postgres")

        print("\n" + "=" * 70)
        print("✓ Test completed successfully!")
        print("=" * 70 + "\n")

        self.close_connections()
        return True

    def close_connections(self):
        """Close all connections."""
        if self.postgres_connection:
            self.postgres_connection.close()


if __name__ == "__main__":
    tester = SupabaseRestAPITester()
    success = tester.run()
    sys.exit(0 if success else 1)
