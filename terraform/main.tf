terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }
}

provider "harness" {
  endpoint         = "PUT_YOUR_MANAGER_ENDPOINT_HERE"
  account_id       = "PUT_YOUR_HARNESS_ACCOUNTID_HERE"
  platform_api_key = "PUT_YOUR_API_KEY_TOKEN_HERE"
}

resource "harness_platform_organization" "org" {
    name      = "OrgByTF"
    identifier = "orgbytf"
    description = "Created through Terraform"
}

resource "harness_platform_project" "project" {
    name      = "ProjByTF"
    identifier = "projbytf"
    org_id    = "orgbytf"
    description = "Created through Terraform"
    depends_on = [
        harness_platform_organization.org
    ]
}

resource "harness_platform_connector_helm" "helmconn" {
    name      = "HelmConnByTF"
    identifier = "helmconnbytf"
    description = "Created through Terraform"
    url = "https://charts.bitnami.com/bitnami"
}

resource "harness_platform_service" "service" {
  name        = "ServiceByTF"
  identifier  = "servicebytf"
  description = "Created through Terraform"
  org_id      = "orgbytf"
  project_id  = "projbytf"
  yaml        = <<-EOT
    service:
        name: ServiceByTF
        identifier: servicebytf
        serviceDefinition:
            type: NativeHelm
            spec:
                manifests:
                    - manifest:
                        identifier: wildfly
                        type: HelmChart
                        spec:
                            store:
                                type: Http
                                spec:
                                    connectorRef: account.helmconnbytf
                            chartName: wildfly
                            chartVersion: ""
                            helmVersion: V3
                            skipResourceVersioning: false
    gitOpsEnabled: false
  EOT

  depends_on = [
        harness_platform_project.project
  ]
}

resource "harness_platform_connector_kubernetes" "k8sconn" {
  name        = "K8SConnByTF"
  identifier  = "k8sconnbytf"
  description = "Created through Terraform"

  inherit_from_delegate {
    delegate_selectors = ["firstk8sdel"]
  }
}

resource "harness_platform_environment" "env" {
  name       = "EnvByTF"
  identifier = "envbytf"
  org_id     = "orgbytf"
  project_id = "projbytf"
  tags       = []
  type       = "PreProduction"
  yaml       = <<-EOT
    environment:
        name: EnvByTF
        identifier: envbytf
        description: ""
        tags: {}
        type: PreProduction
        orgIdentifier: orgbytf
        projectIdentifier: projbytf
        variables: []  
  EOT

  depends_on = [
        harness_platform_project.project
  ]
}

resource "harness_platform_infrastructure" "infra" {
  name            = "InfraByTF"
  identifier      = "infrabytf"
  org_id          = "orgbytf"
  project_id      = "projbytf"
  env_id          = "envbytf"
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
    infrastructureDefinition:
        name: InfraByTF
        identifier: infrabytf
        description: ""
        tags: {}
        orgIdentifier: orgbytf
        projectIdentifier: projbytf
        environmentRef: envbytf
        deploymentType: NativeHelm
        type: KubernetesDirect
        spec:
            connectorRef: account.k8sconnbytf
            namespace: default
            releaseName: release-<+INFRA_KEY>
        allowSimultaneousDeployments: false
  EOT

  depends_on = [
        harness_platform_environment.env
  ]
}

resource "harness_platform_pipeline" "pipeline" {
  name       = "PipelineByTF"
  identifier = "pipelinebytf"
  org_id     = "orgbytf"
  project_id = "projbytf"
  
  yaml       = <<-EOT
    pipeline:
        name: PipelineByTF
        identifier: pipelinebytf
        projectIdentifier: projbytf
        orgIdentifier: orgbytf
        tags: {}
        stages:
            - stage:
                name: Deploy Wildfly
                identifier: Deploy_Wildfly
                description: ""
                type: Deployment
                spec:
                    deploymentType: NativeHelm
                    service:
                        serviceRef: servicebytf
                    environment:
                        environmentRef: envbytf
                        deployToAll: false
                        infrastructureDefinitions:
                        - identifier: infrabytf
                    execution:
                        steps:
                            - step:
                                name: Helm Deployment
                                identifier: helmDeployment
                                type: HelmDeploy
                                timeout: 10m
                                spec:
                                    skipDryRun: false
                        rollbackSteps:
                            - step:
                                name: Helm Rollback
                                identifier: helmRollback
                                type: HelmRollback
                                timeout: 10m
                                spec: {}
                tags: {}
                failureStrategies:
                    - onFailure:
                        errors:
                            - AllErrors
                        action:
                            type: StageRollback
     
  EOT

  depends_on = [
        harness_platform_infrastructure.infra
  ]
}





