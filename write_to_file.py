import os


def write_bucket_name_to_file(bucket_name, sdlc=None):
    sdlc = sdlc or "no_sdlc"
    file_name = f"buckets/{sdlc}_unencrypted.txt"

    if not os.path.exists("buckets"):
        os.makedirs("buckets")

    with open(file_name, "a") as file:
        file.write(f"{bucket_name}\n")
