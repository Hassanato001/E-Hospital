"""Cloudflare R2 helper (Phase 1). R2 is S3-compatible; only keys live in Postgres."""
import os

import boto3

BUCKET = os.environ.get("R2_BUCKET", "vita-dev")


def client():
    return boto3.client(
        "s3",
        endpoint_url=os.environ["R2_ENDPOINT"],
        aws_access_key_id=os.environ["R2_ACCESS_KEY"],
        aws_secret_access_key=os.environ["R2_SECRET_KEY"],
    )


def upload_file(path, key):
    client().upload_file(path, BUCKET, key)
    return key


def presigned_url(key, expires=3600):
    return client().generate_presigned_url(
        "get_object", Params={"Bucket": BUCKET, "Key": key}, ExpiresIn=expires
    )
