# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/python:4-python3.11-appservice
FROM mcr.microsoft.com/azure-functions/python:4-python3.11

ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV AzureFunctionsJobHost__Logging__Console__IsEnabled=true
# Added environment variables for Streaming FastAPI to function and test
# locally in container in docker outside of Azure Function for faster testing
ENV PYTHON_ENABLE_INIT_INDEXING=1
ENV PYTHON_ISOLATE_WORKER_DEPENDENCIES=1

COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY . /home/site/wwwroot