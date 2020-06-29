## Project Setup Commands
The gcloud commands found within setup.sh will enable the product APIs, assign broad IAM controls, as well as setup the initial resources. This script requires gcloud, BQ, and gsutil CLI tools to be installed, or the utilization of Cloud Shell.

Prior to running the script, ensure you have updated the argument file as well as the startup-script.sh. Best practice for the demo would be to run the script in an existing project's Cloud Shell (most up to date SDK, CLI, and API tools).
```
./setup.sh $(cat arguments.txt)
```
Once the script has run, the only outstanding action is to enable Dataprep through the console, accept appropriate authorization request, and complete the following instructions.
```
Assign Dataprep output storage bucket as Misc_Bucket
Import flow from Misc bucket
Import datasets from Raw bucket
Update inputs on recipe
Update outputs to GCS and BigQuery
```