"""
Export Supabase tables to CSV or JSON files.

Exports data from specific schemas and tables to local files.
Uses environment variables from .env for database connection.

Environment variables required:
  - SUPABASE_DB_HOST
  - SUPABASE_DB_PORT
  - SUPABASE_DB_NAME
  - SUPABASE_USER
  - SUPABASE_PASSWORD
"""

import os
import sys
import csv
import json
from typing import Optional
from pathlib import Path
from dotenv import load_dotenv
import psycopg2
from psycopg2 import sql

# Load environment variables
load_dotenv()


class SupabaseTableExporter:
    def __init__(self):
        self.db_host = os.getenv("SUPABASE_DB_HOST", "").strip()
        self.db_port = os.getenv("SUPABASE_DB_PORT", "5432").strip()
        self.db_name = os.getenv("SUPABASE_DB_NAME", "postgres").strip()
        self.db_user = os.getenv("SUPABASE_USER", "").strip()
        self.db_password = os.getenv("SUPABASE_PASSWORD", "").strip()
        self.connection = None

    def validate_env(self) -> bool:
        """Validate environment variables."""
        print("=" * 70)
        print("ENVIRONMENT CHECK")
        print("=" * 70)

        required = ["SUPABASE_DB_HOST", "SUPABASE_DB_USER", "SUPABASE_PASSWORD"]
        for var in required:
            if var == "SUPABASE_DB_HOST" and not self.db_host:
                print(f"❌ {var} not set")
                return False
            elif var == "SUPABASE_DB_USER" and not self.db_user:
                print(f"❌ {var} not set")
                return False
            elif var == "SUPABASE_PASSWORD" and not self.db_password:
                print(f"❌ {var} not set")
                return False

        print(f"✓ Database connection parameters validated")
        return True

    def connect(self) -> bool:
        """Connect to database."""
        print("\n" + "=" * 70)
        print("DATABASE CONNECTION")
        print("=" * 70)

        try:
            print(f"Connecting to {self.db_user}@{self.db_host}...")
            self.connection = psycopg2.connect(
                host=self.db_host,
                port=int(self.db_port),
                database=self.db_name,
                user=self.db_user,
                password=self.db_password,
            )
            print("✓ Connected!")
            return True
        except psycopg2.Error as e:
            print(f"❌ Connection failed: {e}")
            return False

    def export_table_to_csv(self, schema: str, table: str, output_file: str) -> bool:
        """Export table to CSV file."""
        try:
            with self.connection.cursor() as cursor:
                # Get column names
                cursor.execute("""
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = %s AND table_name = %s
                    ORDER BY ordinal_position
                """, (schema, table))
                columns = [row[0] for row in cursor.fetchall()]

                # Get data
                cursor.execute(
                    sql.SQL("SELECT * FROM {}.{}").format(
                        sql.Identifier(schema), sql.Identifier(table)
                    )
                )
                rows = cursor.fetchall()

                # Write to CSV
                with open(output_file, 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow(columns)
                    writer.writerows(rows)

                print(f"✓ Exported {len(rows)} rows to {output_file}")
                return True
        except Exception as e:
            print(f"❌ Error exporting to CSV: {e}")
            return False

    def export_table_to_json(self, schema: str, table: str, output_file: str) -> bool:
        """Export table to JSON file."""
        try:
            with self.connection.cursor() as cursor:
                # Get column names
                cursor.execute("""
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = %s AND table_name = %s
                    ORDER BY ordinal_position
                """, (schema, table))
                columns = [row[0] for row in cursor.fetchall()]

                # Get data
                cursor.execute(
                    sql.SQL("SELECT * FROM {}.{}").format(
                        sql.Identifier(schema), sql.Identifier(table)
                    )
                )
                rows = cursor.fetchall()

                # Convert to list of dicts
                data = [dict(zip(columns, row)) for row in rows]

                # Write to JSON
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, default=str)

                print(f"✓ Exported {len(rows)} rows to {output_file}")
                return True
        except Exception as e:
            print(f"❌ Error exporting to JSON: {e}")
            return False

    def export_all_public_tables(self, output_dir: str = "exports", format: str = "csv") -> bool:
        """Export all tables from public schema."""
        print("\n" + "=" * 70)
        print(f"EXPORTING PUBLIC SCHEMA TABLES ({format.upper()})")
        print("=" * 70)

        # Create output directory
        Path(output_dir).mkdir(exist_ok=True)

        try:
            with self.connection.cursor() as cursor:
                # Get all tables in public schema
                cursor.execute("""
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    ORDER BY table_name
                """)
                tables = [row[0] for row in cursor.fetchall()]

                if not tables:
                    print("No tables found in public schema")
                    return True

                for table in tables:
                    output_file = os.path.join(output_dir, f"public_{table}.{format}")
                    
                    if format == "csv":
                        self.export_table_to_csv("public", table, output_file)
                    elif format == "json":
                        self.export_table_to_json("public", table, output_file)

                print(f"\n✓ Exported {len(tables)} tables to {output_dir}/")
                return True
        except Exception as e:
            print(f"❌ Error: {e}")
            return False

    def run(self):
        """Run exporter."""
        print("\n")
        print("📤 SUPABASE TABLE EXPORTER")
        print("=" * 70)

        if not self.validate_env():
            print("\n❌ Missing environment variables")
            return False

        if not self.connect():
            print("\n❌ Could not connect to database")
            return False

        # Export all public tables as CSV
        self.export_all_public_tables(output_dir="exports", format="csv")

        # Optionally also export as JSON
        print("\n" + "=" * 70)
        self.export_all_public_tables(output_dir="exports_json", format="json")

        print("\n" + "=" * 70)
        print("✓ Export completed!")
        print("=" * 70 + "\n")

        self.close()

    def close(self):
        """Close database connection."""
        if self.connection:
            self.connection.close()


if __name__ == "__main__":
    exporter = SupabaseTableExporter()
    exporter.run()
