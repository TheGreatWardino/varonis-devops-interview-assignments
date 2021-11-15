import logging

import azure.functions as func
from azure.keyvault import secrets


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    global name
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        check_secret()
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully. Your password is {secret.value}")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )
    

def check_secret():
    from azure.identity import DefaultAzureCredential
    from azure.keyvault.secrets import SecretClient

    credential = DefaultAzureCredential()
    client = SecretClient(
        vault_url=f"https://{name}.vault.azure.net",
        credential=credential
    )
    global secret
    secret = client.get_secret("VaronisAssignmentSecret")