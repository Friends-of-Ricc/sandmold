## GCLI Friction Log

### Manifest Digest Mismatch Error (2025-07-22 15:33:00 UTC)

**Context:**
Attempting to create a SaaS Runtime Release (`sample-vm-v1-0-2-global`) for a blueprint (`terraform-vm-blueprint`) after rebuilding and pushing the blueprint image with a new tag (`sample-vm-1753198207`). The `04-create-release.sh` script was modified to use the `IMAGE_URI` directly, and then to use the explicit digest of the image.

**Error Message:**
```
ERROR: (gcloud.beta.saas-runtime.releases.create) INVALID_ARGUMENT: invalid argument unable to read annotations from OCI image, error: manifest digest: "sha256:78c97cab2e3285d74d8e65b72a7a275a70b73ee1b4f7c6be231bd04d5ba482f8" does not match requested digest: "sha256:311ee8f807ab3afdf611a873c16b47cf497140253ac3f273ff0734a84bc43ada" for "global-docker.pkg.dev/check-docs-in-go-slash-sredemo/sandmold-saas-registry/terraform-vm-blueprint@sha256:311ee8f807ab3afdf611a873c16b47cf497140253ac3f273ff0734a84bc43ada"
```

**Analysis:**
This error is highly persistent and suggests a fundamental issue with how the SaaS Runtime service is resolving or caching blueprint image references from Artifact Registry. Despite ensuring the blueprint is pushed with the correct tags and attempting to reference it by direct URI and explicit digest, the service consistently reports a digest mismatch. This is preventing the creation of the `1-0-2` release.
