import logging

import azure.functions as func
from azure.keyvault import secrets

#main function to be executed when a HTTP request is initialized
def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    #defining variable to be used for supplied parameter
    global name
    name = req.params.get('name')

    #if name not found, execute these 
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    #if name found, execute the check_secret function; displays some text on the web page that will provide us the values we need
    if name:
        check_secret()
        return func.HttpResponse(f"Hello! This HTTP triggered function executed successfully. \n Key Vault name: {name} \n Key Vault secret name: {secret.name} \n Secret creation date: {secret.properties.created_on} \n Key vault secret value: {secret.value}")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )
    
# this function this will search Azure Key Vault for the requested name
def check_secret():
    from azure.identity import DefaultAzureCredential
    from azure.keyvault.secrets import SecretClient

    #sets our credentials set
    credential = DefaultAzureCredential()
    #instantiates a client session to retrieve our secrets
    client = SecretClient(
        vault_url=f"https://{name}.vault.azure.net",
        credential=credential
    )
    #sets the variable to global, so it can be used by main()
    global secret
    secret = client.get_secret("VaronisAssignmentSecret")