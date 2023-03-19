import boto3
import botocore

from exceptions import (
    BotoClientException,
    RedshiftDataConnectionException,
    TableCreationException,
    IngestionException,
)


class Redshift:
    def __init__(self) -> None:
        self.redshift_data_client = boto3.client("redshift-data")

    def check_table_exists(
        self,
        redshift_workgroup_name: str,
        redshift_database_name: str,
        redshift_table_name: str,
    ) -> bool:
        """This function checks if a specific table exists in an AWS Redshift Serverlesss database.

        Args:
            redshift_workgroup_name (str): the Redshift Serverless workgroup.
            redshift_database_name (str): the Redshift Serverless database.
            redshift_table_name (str): the Redshift Serverless table.

        Raises:
            RedshiftDataConnectionException: raised when there is Redshift Data API connection error.
            BotoClientException: raised when there is a boto3 client error.

        Returns:
            bool: true when the table exists, false when it does not.
        """
        try:
            response = self.redshift_data_client.list_tables(
                Database=redshift_database_name,
                TablePattern=redshift_table_name,
                WorkgroupName=redshift_workgroup_name,
            )
        except botocore.exceptions.ClientError as e:
            if isinstance(e, botocore.exceptions.EndpointConnectionError):
                raise RedshiftDataConnectionException(
                    "Could not connect to the Redshift Data API endpoint."
                )
            else:
                raise BotoClientException(f"An error occurred: {e}")

        for table in response["Tables"]:
            if redshift_table_name == table["name"]:
                return True

        return False

    def create_table(
        self,
        redshift_workgroup_name: str,
        redshift_database_name: str,
        redshift_table_name: str,
    ) -> None:
        """This function creates a table in an Amazon Redshift Serverless database.

        Args:
            redshift_workgroup_name (str): the Redshift Serverless workgroup.
            redshift_database_name (str): the Redshift Serverless database.
            redshift_table_name (str): the Redshift Serverless table.

        Raises:
            RedshiftDataConnectionException: raised when there is Redshift Data API connection error.
            TableCreationException: raised when a redis error occurs during table creation.
            BotoClientException: raised when there is a boto3 client error.
        """
        columns = "device_id integer not null, timestamp timestamp, value integer not null, primary key(device_id)"
        sql_query = f'CREATE TABLE "{redshift_table_name}" ({columns});'

        try:
            self.redshift_data_client.execute_statement(
                Database=redshift_database_name,
                Sql=sql_query,
                WorkgroupName=redshift_workgroup_name,
            )
        except botocore.exceptions.ClientError as e:
            if isinstance(e, botocore.exceptions.EndpointConnectionError):
                raise RedshiftDataConnectionException(
                    "Could not connect to the Redshift Data API endpoint."
                )
            elif isinstance(
                e, self.redshift_data_client.exceptions.ExecuteStatementException
            ):
                raise TableCreationException(
                    f"An error occurred while executing the query: {e}"
                )
            else:
                raise BotoClientException(f"An error occurred: {e}")

    def ingest_data(
        self,
        record: dict[str, int],
        redshift_workgroup_name: str,
        redshift_database_name: str,
        redshift_table_name: str,
    ) -> None:
        """This function ingests time series data to an Amazon Redshift Serverless database table.

        Args:
            record (dict[str, int]): the Kinesis record to ingest.
            redshift_workgroup_name (str): the Redshift Serverless workgroup.
            redshift_database_name (str): the Redshift Serverless database.
            redshift_table_name (str): the Redshift Serverless table.

        Raises:
            RedshiftDataConnectionException: raised when there is Redshift Data API connection error.
            IngestionException: raised when a redis error occurs during ingestion.
            BotoClientException: raised when there is a boto3 client error.
        """
        device_id = record["device_id"]
        timestamp = record["timestamp"]
        value = record["value"]

        values = f"{device_id}, DATEADD(s, {timestamp}, '1970-01-01'), {value}"

        sql_query = f'INSERT INTO "{redshift_table_name}" VALUES ({values});'

        try:
            self.redshift_data_client.execute_statement(
                Database=redshift_database_name,
                Sql=sql_query,
                WorkgroupName=redshift_workgroup_name,
            )
        except botocore.exceptions.ClientError as e:
            if isinstance(e, botocore.exceptions.EndpointConnectionError):
                raise RedshiftDataConnectionException(
                    "Could not connect to the Redshift Data API endpoint."
                )
            elif isinstance(
                e, self.redshift_data_client.exceptions.ExecuteStatementException
            ):
                raise IngestionException(
                    f"An error occurred while executing the query: {e}"
                )
            else:
                raise BotoClientException(f"An error occurred: {e}")
