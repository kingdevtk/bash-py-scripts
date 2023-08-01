import boto3
from botocore.exceptions import ClientError
import logging

from write import write_to_file

client = boto3.client("s3")
s3 = boto3.resource("s3")


SDLC_KEYWORDS = {
    "devops": ["ops"],
    "staging": ["qa", "dev", "staging"],
    "demo": ["demo"],
    "prod": ["prod"]
}


def sort_buckets():
    logger = logging.getLogger(__name__)

    logger.info("Sorting buckets")
    response = client.list_buckets()

    for bucket in response["Buckets"]:
        bucket_name = bucket["Name"]

        try:
            client.get_bucket_encryption(Bucket=bucket_name)
        except ClientError:
            sdlc_found = None

            for sdlc_name, list_of_substrings in SDLC_KEYWORDS.items():
                if any(prefix in bucket_name for prefix in list_of_substrings):
                    sdlc_found = sdlc_name
                    break

            write_to_file.write_bucket_name_to_file(bucket_name, sdlc_found)
