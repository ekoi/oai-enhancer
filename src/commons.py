import importlib.metadata
import logging
import os
import re

import tomli
from dynaconf import Dynaconf
import requests as req
from fastapi import HTTPException
from starlette import status

settings = Dynaconf(settings_files=["conf/settings.toml", "conf/.secrets.toml"],
                    environments=True)
logging.basicConfig(filename=settings.LOG_FILE, level=settings.LOG_LEVEL,
                    format=settings.LOG_FORMAT)
data = {}

def get_version():
    with open(os.path.join(os.getenv("BASE_DIR"), 'pyproject.toml'), 'rb') as file:
        package_details = tomli.load(file)
    return package_details['tool']['poetry']['version']

__version__ = get_version()




