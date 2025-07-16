As per https://cloud.google.com/resource-manager/docs/limits

* You can nest folders up to 10 levels deep [easy]
* A parent folder cannot contain more than 300 folders. [easy]

## Projects

The number of projects any user or service account can create is limited. If you create a project outside an organization, the quota on your account is used. If you are creating a project within an organization, the quota on both your account and organization are checked, and if either one has quota remaining, the project can be created.

* **Write operations**:	Includes updating projects, tags, and other resources, with the exception of moving or creating folders. The CreateProject operation costs 10 requests per second.
  * Up to 10 requests per minute (1 project per second)
  * Up to 600 requests per minute (60 projects per minute)

## Example for sample org: "sredemo.dev"

[This page](https://console.cloud.google.com/iam-admin/quotas?inv=1&invt=Ab25Mg&organizationId=791852209422): shows quota for projects for sredemo.dev.

* Current usage: 87 -- which is 58% of limit of **150**.
* Service: "Cloud Resource Manager API"
* Name: "Projects Count"
* Dimension/locations: none
