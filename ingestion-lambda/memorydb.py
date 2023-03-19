import redis

from exceptions import IngestionException

WEEK_MILLISECONDS = 604800000


class MemoryDB:
    def __init__(self, memorydb_host: str) -> None:
        self.redis = redis.cluster.RedisCluster(host=memorydb_host, port=6379, ssl=True)

    def ingest_data(self, record: dict[str, int]) -> None:
        """This function ingests time series data to an Amazon MemoryDB Redis cluster.

        Args:
            record (dict[str, int]): the Kinesis record to ingest.

        Raises:
            IngestionException: raised when a redis error occurs during ingestion.
        """
        device_id = record["device_id"]
        timestamp = record["timestamp"]
        value = record["value"]

        try:
            self.redis.execute_command("ZADD", device_id, "0", f"{timestamp}:{value}")
        except redis.exceptions.RedisError as e:
            raise IngestionException(f"An error occured during ingestion: {e}")
