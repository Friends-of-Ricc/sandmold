## Our first app: Foobar
So now I want to implement my first app, foobar.
It should have 3 scripts: `start.sh`, `stop.sh` and `status.sh`.
These scripts should ensure that N ENV vars are set, as per spec.variables stanza (3).
Probably the will include some common script to check for these 3 (GOOGLE_CLOUD_PROJECT, ...) .
Finally each one of them will log to Cloud Logging a Json Payload with framework: "sandmold/v1.0" , appname: metadata.name, appverb:
"start/stop/status", and a message line as you wish "Starting to deploy the app..." and somethign like this. NOte this app is a vanilla app which
does NOTHING, but will be used by other apps in cut paste so we need to do it and document it well.
