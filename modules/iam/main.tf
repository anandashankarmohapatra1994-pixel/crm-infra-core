resource "google_service_account" "jenkins_ci_sa" {
  account_id   = "jenkins-ci-deployer"
  display_name = "Jenkins CI/CD Pipeline Service Account"
}

# Granular Custom Role for CI/CD Deployment
resource "google_project_iam_custom_role" "cicd_deployer_role" {
  role_id     = "crmCIcdDeployer"
  title       = "CRM CI/CD Deployer Role"
  description = "Custom role with strict permissions for GKE deployment and Artifact Registry pushing"
  stage       = "GA"
  permissions = [
    "container.clusters.get",
    "container.clusters.getCredentials",
    "container.deployments.create",
    "container.deployments.update",
    "artifactregistry.repositories.uploadArtifacts",
    "artifactregistry.writer"
  ]
}

resource "google_project_iam_member" "bind_ci_role" {
  project = var.project_id
  role    = google_project_iam_custom_role.cicd_deployer_role.id
  member  = "serviceAccount:${google_service_account.jenkins_ci_sa.email}"
}
