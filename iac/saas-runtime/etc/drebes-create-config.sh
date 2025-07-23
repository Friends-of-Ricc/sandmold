$ gcloud storage buckets create gs://saas-$(uuidgen)
Creating gs://saas-6db40927-bc57-4746-9bc2-77d33b20bce4/...

#zip contents into terraform-files.zip, then upload to storage:
$ gcloud storage cp ../saas-quickstart/terraform-vm/terraform-files.zip gs://saas-6db40927-bc57-4746-9bc2-77d33b20bce4/
Copying file://../saas-quickstart/terraform-vm/terraform-files.zip to gs://saas-6db40927-bc57-4746-9bc2-77d33b20bce4/terraform-files.zip
  Completed files 1/1 | 1.4kiB/1.4kiB

# call cloud build to build the docker image and push to AR
gcloud builds submit gs://saas-6db40927-bc57-4746-9bc2-77d33b20bce4/terraform-files.zip --config=config.yaml --project=$PROJECT_ID --billing-project=$PROJECT_ID

# next we need to create release, which includes the input variables
