import importlib.metadata
import logging
import os
import re

import tomli
from dynaconf import Dynaconf
import requests as req
from fastapi import HTTPException
from starlette import status
from starlette.config import environ

os.environ["BASE_DIR"] = os.getenv("BASE_DIR", os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

settings = Dynaconf(
    settings_files=['conf/*settings.toml', 'conf/.secrets.toml', 'conf/*settings.json'],
    root_path=os.getenv("BASE_DIR"), environments=True
)
logging.basicConfig(filename=settings.LOG_FILE, level=settings.LOG_LEVEL,
                    format=settings.LOG_FORMAT)
data = {}

repos = settings.get("repos", [])
supported_repos = []
for repo in repos:
    for k, v in repo.items():
        supported_repos.append(k)

def get_version():
    with open(os.path.join(os.getenv("BASE_DIR"), 'pyproject.toml'), 'rb') as file:
        package_details = tomli.load(file)
    return package_details['tool']['poetry']['version']

def get_name():
    with open(os.path.join(os.getenv("BASE_DIR"), 'pyproject.toml'), 'rb') as file:
        package_details = tomli.load(file)
    return package_details['tool']['poetry']['name']

__version__ = get_version()


#
def get_repo(key):
    return repos[0].get(key)


