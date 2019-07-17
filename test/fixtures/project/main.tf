/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  version = "~> 2.10.0"
}

provider "google-beta" {
  version = "~> 2.10.0"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.1"
}

terraform {
  backend "gcs" {}
}

module "project_factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 3.0"

  billing_account = var.billing_account
  name            = "forseti-test"
  org_id          = var.org_id

  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
  ]

  apis_authority              = false
  disable_dependent_services  = true
  disable_services_on_destroy = true
  folder_id                   = var.folder_id
  random_project_id           = true
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 1.0"

  network_name = "forseti-test"
  project_id   = module.project_factory.project_id

  secondary_ranges = {
    forseti-test = []
  }

  subnets = [
    {
      subnet_name   = "forseti-test"
      subnet_ip     = "10.128.0.0/20"
      subnet_region = "us-central1"
    },
  ]
}

data "google_compute_zones" "main" {
  project = module.project_factory.project_id
  region  = module.network.subnets_regions[0]
  status  = "UP"
}

locals {
  service_account_member = "serviceAccount:${module.project_factory.service_account_email}"
}

resource "google_organization_iam_member" "organization_admin" {
  member = local.service_account_member
  org_id = var.org_id
  role   = "roles/resourcemanager.organizationAdmin"
}

resource "google_organization_iam_member" "organization_role_admin" {
  member = local.service_account_member
  org_id = var.org_id
  role   = "roles/iam.organizationRoleAdmin"
}

resource "google_organization_iam_member" "config_writer" {
  member = local.service_account_member
  org_id = var.org_id
  role   = "roles/logging.configWriter"
}

resource "google_project_iam_member" "instance_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/compute.instanceAdmin"
}

resource "google_project_iam_member" "network_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/compute.networkAdmin"
}

resource "google_project_iam_member" "security_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/compute.securityAdmin"
}

resource "google_project_iam_member" "service_account_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/iam.serviceAccountAdmin"
}

resource "google_project_iam_member" "service_account_user" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/iam.serviceAccountUser"
}

resource "google_project_iam_member" "service_usage_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
}

resource "google_project_iam_member" "storage_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/storage.admin"
}

resource "google_project_iam_member" "cloudsql_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/cloudsql.admin"
}

resource "google_project_iam_member" "pubsub_admin" {
  member  = local.service_account_member
  project = module.project_factory.project_id
  role    = "roles/pubsub.admin"
}

resource "google_service_account_key" "forseti" {
  service_account_id = "projects/${module.project_factory.project_id}/serviceAccounts/${module.project_factory.service_account_unique_id}"
}
