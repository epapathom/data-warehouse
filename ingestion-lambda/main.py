import os
import ast
import base64

from memorydb import MemoryDB
from redshift import Redshift

memorydb_host = os.environ["MEMORYDB_HOST"]

redshift_workgroup_name = os.environ["REDSHIFT_WORKGROUP_NAME"]
redshift_database_name = os.environ["REDSHIFT_DATABASE_NAME"]
redshift_table_name = os.environ["REDSHIFT_TABLE_NAME"]

memorydb = MemoryDB(memorydb_host=memorydb_host)
redshift = Redshift()


def handler(event, context) -> None:
    table_exists = redshift.check_table_exists(
        redshift_workgroup_name=redshift_workgroup_name,
        redshift_database_name=redshift_database_name,
        redshift_table_name=redshift_table_name,
    )

    if not table_exists:
        redshift.create_table(
            redshift_workgroup_name=redshift_workgroup_name,
            redshift_database_name=redshift_database_name,
            redshift_table_name=redshift_table_name,
        )

    for record in event["Records"]:
        record = record["kinesis"]["data"]
        record_decoded = base64.b64decode(record)
        record_decoded = record_decoded.decode("utf-8")
        record_decoded = ast.literal_eval(record_decoded)

        memorydb.ingest_data(record=record_decoded)

        redshift.ingest_data(
            record=record_decoded,
            redshift_workgroup_name=redshift_workgroup_name,
            redshift_database_name=redshift_database_name,
            redshift_table_name=redshift_table_name,
        )
