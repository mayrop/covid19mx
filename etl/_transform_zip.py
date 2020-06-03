import re
import zipfile
import os

from exceptions import AlreadyProcessedError
from pathlib import Path
from helpers import create_file_dir, interpolate_date

def transform_zip(source, destination, opts):
    destination, pattern = process_patterns(source, destination, opts['pattern'])

    try:
        copy_zip_to_final_destination(destination, source)
        transform_zip_contents(destination, pattern)

    except AlreadyProcessedError as error:
        print('ZIP already processed')
        print('Error: {}'.format(error))

    except BaseException as error:
        print('Something happened while processing zip')
        print('Error: {}'.format(error))
    


def copy_zip_to_final_destination(destination, source):
    destination_zip_file = Path('{}'.format(destination))

    if not destination_zip_file.is_file():
        print("Destination does not exit, transforming", destination)
        # create dir if it doesnt' exist
        create_file_dir(destination_zip_file)

        source_file = Path('{}'.format(source))
        destination_zip_file.write_bytes(source_file.read_bytes())

        return
    
    raise AlreadyProcessedError


def transform_zip_contents(destination, pattern):
    destination_zip_file = Path('{}'.format(destination))
    destination_csv_file = Path('{}'.format(destination.replace('zip', 'csv')))

    print("Unzipping")
    with zipfile.ZipFile(destination_zip_file, "r") as zip_ref:
        zip_ref.extractall(os.path.dirname(destination_zip_file))

    source_csv_file_path = '{}/{}'.format(os.path.dirname(destination_zip_file), pattern)
    source_csv_file = Path('{}'.format(source_csv_file_path))
    
    if source_csv_file.is_file():
        print("Copying to CSV file", destination_csv_file)
        destination_csv_file.write_bytes(source_csv_file.read_bytes())

        print("Removing original CSV file: ", source_csv_file)
        os.remove(source_csv_file)

    print("Removing copied ZIP file: ", destination_zip_file)
    os.remove(destination_zip_file)

    print("Zipping")
    with zipfile.ZipFile(destination, 'w') as zip: 
        zip.write(str(destination_csv_file), destination_csv_file.name)
        os.remove(str(destination_csv_file))


def process_patterns(source, destination, pattern):
    regex = re.compile(r'\/(\d{4})(\d{2})(\d{2})\.zip')
    matches = re.search(regex, source)

    if matches:
        destination = interpolate_date(destination, matches[1], matches[2], matches[3])
        pattern = interpolate_date(pattern, matches[1], matches[2], matches[3])

    return destination, pattern