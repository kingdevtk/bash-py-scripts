import logging

from encrypt import encrypt_bucket


def encrypt_buckets_from_file(bucket_name_file):
    logger = logging.getLogger(__name__)

    logger.info(f"Reading file {bucket_name_file}")

    try:
        with open(bucket_name_file, "r") as file:
            for bucket in file:
                bucket = bucket.strip()
                encrypt_bucket.encrypt_bucket(bucket)
    except IOError:
        logger.error(f"The file does not exist - {bucket_name_file}")
        raise
