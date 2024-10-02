import json
import logging
import os
from contextlib import asynccontextmanager
import xml.etree.ElementTree as ET

import emoji
import requests
import uvicorn
from fastapi import FastAPI, Request, Response, HTTPException
from saxonche import PySaxonProcessor
from starlette import status
from starlette.middleware.cors import CORSMiddleware

from src.commons import __version__, get_name,  get_repo, supported_repos
from src.commons import settings


@asynccontextmanager
async def lifespan(application: FastAPI):
    """
    Lifespan event handler for the FastAPI application.

    This asynchronous context manager handles the startup and shutdown events
    for the FastAPI application. It can be used to perform any necessary
    initialization or cleanup tasks.

    Args:
        application (FastAPI): The FastAPI application instance.

    Yields:
        None
    """
    print('start up')
    print(emoji.emojize(':thumbs_up:'))


app = FastAPI(title=settings.FASTAPI_TITLE, description=settings.FASTAPI_DESCRIPTION,
              version=__version__)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def execute_xslt(json_string, xsl, xml_string):
    """
    Executes an XSLT transformation on the provided XML string using the given XSL file and JSON string as parameters.

    Args:
        json_string (str): The JSON string to be used as a parameter in the XSLT transformation.
        xsl (str): The path to the XSL file to be used for the transformation.
        xml_string (str): The XML string to be transformed.

    Returns:
        str: The result of the XSLT transformation as a string.
    """
    with PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xsltproc.set_cwd(os.getcwd())
        executable = xsltproc.compile_stylesheet(stylesheet_file=xsl)
        value = proc.make_string_value(json_string)
        executable.set_parameter("json", value)
        node = proc.parse_xml(xml_text=xml_string)
        result = executable.apply_templates_returning_string(xdm_value=node)
        print(result)

    return result
@app.get("/")
async def get_service_name():
    """
    Endpoint to get the service name.

    This endpoint returns the service name by capitalizing each word in the name
    obtained from the `get_name` function.

    Returns:
        dict: A dictionary containing the service name.
    """
    return {"service name": ' '.join(word.capitalize() for word in get_name().split('-'))}

@app.get("/repos")
async def get_supported_repos():
    """
    Endpoint to list all repository keys.

    This endpoint retrieves the keys from the `repos` dictionary defined in the settings
    and logs them. It then returns the list of keys.

    Returns:
        list: A list of keys from the `repositories` dictionary.
    """
    # dans_repo = settings.dans_repo
    # # for key, value in dans_repo.items():
    # #     logging.info((f"Key: {key}, Value: {value}"))
    # keys = dans_repo.keys()
    # logging.info(f"Keys: {list(keys)}")
    # return list(keys)
    return supported_repos

@app.get("/{repo}/{schema}/oai")
async def get_oai_with_specific_schema(repo: str, schema: str, request: Request):
    """
    Endpoint to retrieve and process the OAI-PMH response for a specific repository and mapping.

    This endpoint checks if the specified mapping exists and then processes the OAI-PMH response
    using the provided repository and mapping.

    Args:
        repo (str): The repository key (e.g., 'dvnl').
        mapping (str): The mapping key.
        request (Request): The FastAPI request object containing query parameters.

    Returns:
        Response: The processed XML response or an HTTPException if the mapping or repository is not found.
    """
    if repo not in supported_repos:
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Repository not found")

    schema_not_exists = "non_existent_schema"
    xslt_path = get_repo(repo).get(schema, schema_not_exists)

    if xslt_path == schema_not_exists:
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Mapping not found")

    if not os.path.exists(xslt_path):
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Mapping not found")

    return await mapper(repo, xslt_path, request)

@app.get("/{repo}/oai")
async def get_oai(repo: str, request: Request):
    """
    Endpoint to redirect OAI-PMH requests for a specific repository.

    This endpoint processes the OAI-PMH request using the provided repository key
    and query parameters from the request.

    Args:
        repo (str): The repository key.
        request (Request): The FastAPI request object containing query parameters.

    Returns:
        Response: The processed XML response or an HTTPException if the repository is not found.
    """
    if repo not in supported_repos:
        return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Repository not found")

    base_url = get_repo(repo).URL
    xslt_default = get_repo(repo).XSLT_DEFAULT
    return await mapper(base_url, xslt_default, request)


async def mapper(base_url, xslt_path, request):
    """
    Processes the OAI-PMH response for a specific repository and applies an XSLT transformation.

    This function retrieves the OAI-PMH response from the specified repository, extracts the identifier,
    fetches the corresponding dataset in JSON format, and applies an XSLT transformation to the response.

    Args:
        repo (str): The repository key.
        xslt_path (str): The path to the XSLT file to be used for the transformation.
        request (Request): The FastAPI request object containing query parameters.

    Returns:
        Response: The transformed XML response or an HTTPException if an error occurs.
    """
    # base_url_not_exists = "Not found"
    # base_url = settings.get(repo, base_url_not_exists)
    # if base_url == base_url_not_exists:
    #     return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Repository not found")
    query_params = request.query_params
    if not query_params.keys():
        return HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No query parameters provided")

    oai_response = requests.get(f'{base_url}/oai', params=query_params)
    root = ET.fromstring(oai_response.content)
    # Find the identifier element
    namespace = {'oai': 'http://www.openarchives.org/OAI/2.0/'}
    # Find the identifier element
    identifier_element = root.find('.//oai:identifier', namespace)
    if identifier_element is not None:
        # Extract and print the text content of the identifier element
        if identifier_element is not None:
            doi = identifier_element.text
            # https://dataverse.nl/api/datasets/export?exporter=dataverse_json&persistentId=doi%3A10.34894/0EBAGS
            dv_query_params = {
                "exporter": "dataverse_json",
                "persistentId": doi,
            }
            dv_response = requests.get(f'{base_url}/api/datasets/export', params=dv_query_params)
            logging.info(dv_response.json())
        else:
            doi = identifier_element.text
            return HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="doi not found")
    else:
        return HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="doi not found")
    result = execute_xslt(json.dumps(dv_response.json()), xslt_path, oai_response.text)
    return Response(content=result, media_type="application/xml")


if __name__ == "__main__":
    logging.info("Start")
    print(emoji.emojize(':thumbs_up:'))

    uvicorn.run("src.main:app", host="0.0.0.0", port=3947, reload=False)
