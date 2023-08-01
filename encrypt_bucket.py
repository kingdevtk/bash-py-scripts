import boto3
import logging


client = boto3.client("s3")
s3 = boto3.resource("s3")


def encrypt_bucket(bucket_name):
    logger = logging.getLogger(__name__)

    logger.info(f"Encrypting bucket - {bucket_name}")

    client.put_bucket_encryption(
        Bucket=bucket_name,
        ServerSideEncryptionConfiguration={
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }
    )
