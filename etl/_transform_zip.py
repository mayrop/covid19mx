import re
import zipfile
import os
import sys

from exceptions import AlreadyProcessedError
from pathlib import Path
from helpers import logger, create_file_dir, interpolate_date

def transform_zip(source, destination, opts):
    destination, pattern = process_patterns(source, destination, opts['pattern'])

    try:
        copy_zip_to_final_destination(destination, source)
        transform_zip_contents(destination, pattern)

    except AlreadyProcessedError as error:
        logger.debug(error)

    except BaseException as error:
        logger.error(error)
        sys.exit(1)
    

def copy_zip_to_final_destination(destination, source):
    dest_zip_file = Path('{}'.format(destination))

    if dest_zip_file.is_file():
        raise AlreadyProcessedError('ZIP already processed: {}'.format(destination))

    logger.debug("Destination does not exist, copying {}".format(destination))
    # create dir if it doesnt' exist
    create_file_dir(dest_zip_file)

    source_file = Path('{}'.format(source))
    dest_zip_file.write_bytes(source_file.read_bytes())

    if not dest_zip_file.is_file():
        raise BaseException('ZIP file could not be copied to {}'.format(dest_zip_file))


def transform_zip_contents(destination, pattern):
    dest_zip_file = Path('{}'.format(destination))
    dest_csv_file = Path('{}'.format(destination.replace('zip', 'csv')))

    # Unzipping to extract contents
    logger.debug("Unzipping {}".format(str(dest_zip_file)))

    with zipfile.ZipFile(dest_zip_file, "r") as zip_ref:
        zip_ref.extractall(os.path.dirname(dest_zip_file))

    # We will need to rename CSV
    source_csv_path = '{}/{}'.format(os.path.dirname(dest_zip_file), pattern)
    source_csv_file = Path('{}'.format(source_csv_path))
    
    # Making sure CSV with known pattern exists 
    if not source_csv_file.is_file():
        raise BaseException('CSV file not found {}'.format(str(source_csv_file)))

    # Renaming csv files
    logger.debug("Copying to CSV file {}".format(dest_csv_file))
    os.rename(source_csv_path, str(dest_csv_file))

    # Before zipping again, we need to remove the original zip first
    logger.debug("Removing copied ZIP file: {}".format(dest_zip_file))
    os.remove(dest_zip_file)

    logger.debug("Zipping into {}".format(destination))

    with zipfile.ZipFile(destination, 'w') as zip: 
        zip.write(str(dest_csv_file), dest_csv_file.name)
        os.remove(str(dest_csv_file))

    # # Checking that source file was removed
    if dest_csv_file.is_file():
        raise BaseException('Destination CSV file was not removed')

    if not dest_zip_file.is_file():
        raise BaseException('Final ZIP file does not exist')
        

def process_patterns(source, destination, pattern):
    regex = re.compile(r'\/(\d{4})(\d{2})(\d{2})\.zip')
    matches = re.search(regex, source)

    if matches:
        destination = interpolate_date(destination, matches[1], matches[2], matches[3])
        pattern = interpolate_date(pattern, matches[1], matches[2], matches[3])

    return destination, pattern