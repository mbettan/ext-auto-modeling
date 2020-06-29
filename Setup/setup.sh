# Ensure to supply the following arguments in the command
export PROJECT_NAME=$1
export FOLDER_ID=$2
export USER_EMAIL1=$3
export USER_EMAIL2=$4
export USER_EMAIL3=$5
export USER_EMAIL4=$6
export USER_EMAIL5=$7
export BILLING_ID=$8

export SUBNET=default
export ZONE=us-central1-a
export REGION=us-central1

export RAW_SB="$PROJECT_NAME"_raw_data
export PROCESSED_SB="$PROJECT_NAME"_processed_data
export MISC_SB="$PROJECT_NAME"_misc_bucket
export MODELS_SB="$PROJECT_NAME"_models_bucket
export NYC=nyc_taxi_data
export ZILLOW=zillow_data

export EDA_NOTEBOOK=data-exploration-notebook
export VM_IMAGE_PROJECT=deeplearning-platform-release
export VM_IMAGE_FAMILY=common-cpu-notebooks

export BQ_LOCATION=US
export PROCESSED_DATASET=p_dataset
export RAW_DATASET=r_dataset
export MODEL_DATASET=model_dataset
export MODEL_METRICS_DATASET=model_metrics_dataset

# Create new auto-modeling project
gcloud projects create $PROJECT_NAME \
--folder=$FOLDER_ID
gcloud beta billing projects link $PROJECT_NAME --billing-account=$BILLING_ID
gcloud config set project $PROJECT_NAME

# Assign Project Owner roles in order to enable ease of use for evaluation
gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member=user:$USER_EMAIL1 \
--role=roles/owner
gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member=user:$USER_EMAIL2 \
--role=roles/owner
gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member=user:$USER_EMAIL3 \
--role=roles/owner
gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member=user:$USER_EMAIL4 \
--role=roles/owner
gcloud projects add-iam-policy-binding $PROJECT_NAME \
--member=user:$USER_EMAIL5 \
--role=roles/owner

# Enable appropriate product APIs
gcloud services enable \
automl.googleapis.com \
bigquery.googleapis.com \
bigquerystorage.googleapis.com \
datacatalog.googleapis.com \
dataflow.googleapis.com \
ml.googleapis.com \
notebooks.googleapis.com \
storage-api.googleapis.com \
storage-component.googleapis.com \
storagetransfer.googleapis.com 

# Create Cloud Storage Bucket for data ingestion
# Ingest example code into newly created bucket and clean up Cloud Shell
gsutil mb -l us-central1 -b on -p $PROJECT_NAME gs://$RAW_SB
gsutil mb -l us-central1 -b on -p $PROJECT_NAME gs://$MISC_SB
gsutil mb -l us-central1 -b on -p $PROJECT_NAME gs://$PROCESSED_SB
gsutil mb -l us-central1 -b on -p $PROJECT_NAME gs://$MODELS_SB
gsutil versioning set on gs://$RAW_SB
gsutil versioning set on gs://$MISC_SB
gsutil versioning set on gs://$PROCESSED_SB
gsutil versioning set on gs://$MODELS_SB
wget https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip
unzip -o bank-additional.zip
gsutil cp -r bank-additional gs://$RAW_SB
gsutil cp gs://temp1231231231231/zillow-prize-1_edited_2_train_1-2020-06-21T07:03:09.520Z.csv gs://$RAW_SB
gsutil -m cp gs://temp1231231231231/nyc_taxi* gs://$RAW_SB
gsutil cp gs://temp1231231231231/flow_278626_241ba9a0-b5a7-11ea-ad68-e78d0e958e2b.zip gs://$MISC_SB
gsutil cp ./startup-script.sh gs://$MISC_SB
rm -rf bank-additional/bank-additional.zip

# Create BigQuery dataset
# Ingest public data for AutoML into project
bq --location=$BQ_LOCATION mk $PROCESSED_DATASET
bq --location=$BQ_LOCATION mk $MODEL_DATASET
bq --location=$BQ_LOCATION mk $RAW_DATASET
bq --location=$BQ_LOCATION mk $MODEL_METRICS_DATASET
bq load \
--autodetect \
--source_format=CSV \
$PROJECT_NAME:$RAW_DATASET.$NYC \
gs://$RAW_SB/nyc_taxi*
bq load \
--autodetect \
--source_format=CSV \
$PROJECT_NAME:$RAW_DATASET.$ZILLOW \
gs://$RAW_SB/zillow-prize-1_edited_2_train_1-2020-06-21T07:03:09.520Z.csv

# Create exploratory Jupyter notebook
gcloud beta notebooks instances create $EDA_NOTEBOOK \
--vm-image-project=$VM_IMAGE_PROJECT \
--vm-image-family=$VM_IMAGE_FAMILY \
--location=$ZONE \
--post-startup-script=gs://$MISC_SB/startup-script.sh \
--machine-type=n1-standard-4