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

from src.commons import __version__
from src.commons import settings


@asynccontextmanager
async def lifespan(application: FastAPI):
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
    with PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xsltproc.set_cwd(os.getcwd())
        executable = xsltproc.compile_stylesheet(stylesheet_file=xsl)
        value = proc.make_string_value(json_string)
        executable.set_parameter("json", value)
        node = proc.parse_xml(xml_text=xml_string)
        result = executable.apply_templates_returning_string(
            xdm_value=node)
        print(result)

    return result


@app.get("/oai")
async def redirect_oai(request: Request):
    dv_response = {}
    base_url = "https://ssh.datastations.nl"
    query_params = request.query_params
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
            #https://dataverse.nl/api/datasets/export?exporter=dataverse_json&persistentId=doi%3A10.34894/0EBAGS
            dv_query_params = {
                "exporter": "dataverse_json",
                "persistentId": doi,
            }
            dv_response = requests.get(f'{base_url}/api/datasets/export', params=dv_query_params)
            print(dv_response.json())
        else:
            doi = identifier_element.text
            return HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="doi not found")
    else:
        return HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="doi not found")

    result = execute_xslt(json.dumps(dv_response.json()), settings.xslt_path, oai_response.text)
    return Response(content=result, media_type="application/xml")

if __name__ == "__main__":
    logging.info("Start")
    print(emoji.emojize(':thumbs_up:'))

    uvicorn.run("src.main:app", host="0.0.0.0", port=3947, reload=False)
