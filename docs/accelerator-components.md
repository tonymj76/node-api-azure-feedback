# **Accelerator Components**

The goal of using an Accelerator is to make it easy to dive straight into implementing business logic without having to spend time on setting up an engineering system for your application. Accelerators give you a starting point, while providing the option to change and extend any of the preconfigured components to suit your needs.

Accelerators make use of an opinionated pattern that Microsoft recommends to use for applications targeting the Azure Application Platform.

This document describes the components we have built into the Accelerators.

## Development Environment

The Accelerator gets you up and running quickly by providing a preconfigured development enviroment.

### Development Environment Host

To run the app inside of a local development container, this Accelerator uses the [VS Code Remote - Containers extension](https://code.visualstudio.com/docs/remote/containers) and [Docker](https://docs.docker.com/) to build a self-contained development environment on your machine. The Remote - Containers extension leverages the [`devcontainer.json`](../.devcontainer/devcontainer.json) file to create a development container with the required settings and extensions installed. This method minimizes dev machine set up, but it requires Docker to build a container and a local instance of VS Code to connect to the development container.

The development container definition includes not only the required runtimes for the application and an instance of the database, but also the tools you will need installed on your development machine (e.g. CLIs). Check out the [`.devcontainer`](../.devcontainer/) folder to see how it is implemented.

You also have the option to run the Accelerator via [GitHub Codespaces](https://code.visualstudio.com/docs/remote/codespaces). Codespaces hosts the development container defined by [`devcontainer.json`](../.devcontainer/devcontainer.json), but in Azure instead of on your local dev machine. Using a Codespace allows you to run this Accelerator entirely from a browser which means both VS Code and Docker are **not required** on your PC. You also have the option to use a local VS Code instance to connect to a Codespace.

As soon as the Accelerator is opened in a dev container (including in Codespaces), the application runs the [`init.sh`](../scripts/init.sh) file to build the app dependencies and initialize a local instance of the database. This is what makes the Accelerator instantly runnable.

### IDE

Along with a definition of the host environment, the Accelerator also includes a configuration to build and run your app in VS Code. These configurations can be found in [`.vscode/launch.json`](../.vscode/launch.json) and [`.vscode/tasks.json`](../.vscode/tasks.json).  

## The application

The application is comprised of a Web API implemented in Node.js as well as a Postgres database. It uses an Obect-Relational Mapper ([Sequelize](https://sequelize.org/master/manual/getting-started.html)) and implements a simple object, [`items`](../src/webapi/routes/item.js).

## Deployment

The Accelerators have a ready-to-run build and deployment setup to quickly get your application up and running in the cloud. This consists of:

- Infrastrucure as code implemented in [Bicep](https://github.com/Azure/bicep) which defines the required Azure resources.
- [Porter](https://porter.sh/docs/) bundle definitions to create installable packages for the whole stack.
- [GitHub workflows](https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions) to build and deploy the code.
- Environment attributes defined in the repository.

### Resource definitions - Infrastrcuture-as-code

[Bicep](https://github.com/Azure/bicep) is a domain-specific-language for authoring Azure Resource Manager (ARM) templates. Bicep files specify which Azure Resources are created for deployment.

All resources are created and enabled with diagnostics and monitoring. You can use [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) to analyze your application's performance and [Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview) to analyze logs and metrics from all resources deployed.

### Porter bundles

Accelerators use Cloud Native Application Bundles (CNABs) via [Porter](https://porter.sh/docs/). Porter is a deployment technology that packages your app code, manages secrets, and configures deployment logic to produce a [CNAB bundle](https://porter.sh/faq/). It is a self-describing package that enables anyone to run the application just by having Porter installed.

A Porter bundle makes it easy to distribute and deploy your application across multiple environments, with versioned packages for all necessary components.

## GitHub Action workflows

[GitHub workflows](https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions) enable you to run automated tasks when you commit changes to your repo. Workflows invoke GitHub Actions which are simply sequential tasks to complete within the workflow. Workflows can be trigger-based (such as committing code) or manual.

In this Accelerator, there are two workflows:
| workflow | desription |
| --- | --- |
| `build.yaml` | The build workflow produces a Porter bundle (Cloud Native Application Bundle), which can be deployed to one or more environments. Porter bundles are versioned and contain the installation routine of the application as well as the full payload needed to stand up an instance. |
| `deploy.yaml` | The deploy workflow creates or updates environment attributes as defined in the [`environments/environments.yaml`](../environments/environments.yaml) file. |

### The build workflow

The build workflow is responsible for:

- Building and testing the application code as binaries or containers.
- Validating the Bicep files and compiling them to ARM templates.
- Building the Porter bundle which includes the compiled application (or reference to containers), the ARM templates, and the installation scripts.

First, the application code is built and tested. Then, the compiled output is uploaded as an artifact to either the repository or a container registry, depending on the implementation.

The Bicep files are transpiled to ARM and are uploaded as artifacts.

Finally, the Porter bundles are built and uploaded to the GitHub Container Registry with three different tags: `latest`, `v0.0.1-latest` and `v0.0.1-{commitID}`. This enables you to reference either of these tags for the environments you want running in Azure. These tags are explained in [Application and Bundle versions](#application-and-bundle-versions) below.

The build workflow is initated on any change to files in the `./src` folder, or changes to the build workflow itself. This means that all commits to the repository, which will change the output of the application bundle, will produce a new bundle. Hence, the `latest` tag of the bundle will always contain the latest commit in the `main` branch.

#### The deploy workflow and environments

The deployment workflow is responsible for:

- Evaluating the [`environments/environments.yaml`](../environments/environments.yaml) file and identifying what to update or create.
- Initiating a `porter install` action for each environment that needs to be created or updated.

> **Note:** Accelerators are not using the GitHub environments feature at this point in time. Environments in the Accelerator context refers to the `environments/environments.yaml` file and workflows.

The deployment workflow will trigger when:

- The build workflow completes.
- Any change is made to [`environments/environments.yaml`](../environments/environments.yaml).
- Any change is made to the deployment workflow itself.

The deployment workflow is using the [`environments/environments.yaml`](../environments/environments.yaml) file to define the configuration of one or more environments in Azure. The `environments.yaml` file contains three pieces:

1. The name of the environment:

    ``` yaml
    - name: test
    ```

1. The deployment policy:

    ``` yaml
    deploys:
      version: "latest"
    ```

1. The configuration for that environment:

    ``` yaml
    config:
      AZURE_LOCATION: "northeurope"
      AZURE_NAME_PREFIX: "test"
      WEBAPI_NODE_ENV: "development"
    ```

Each of these combined environment definitions are deployed as individual resource groups in Azure. For each environment defined, the deployment workflow will initialize parallel deployments.

> **Note:** Currently, the deployment workflow does not have a way to delete environments. You will have to manually delete the resource group representing an environment.

To ensure only modified environments are updated, the workflow evaluates any changes to:

1. The `config` section defined in [`environments/environments.yaml`](../environments/environments.yaml).
1. The version of the application currently running. This is determined by the digest of the deployed Porter bundle and the environment definition.

This workflow is implemented by tagging the digest of the bundle on the Resource Group and by generating a hash of the `config` section also. If either of these tags are manually updated or removed, the deploy workflow will try to restore the resource group to the state defined in [`environments/environments.yaml`](../environments/environments.yaml).

#### Application and Bundle versions

In the `environments.yaml` file, there are three options for the version policy:

- latest
- v0.0.1-latest
- v0.0.1-{commitId}

| Version | Content | How content is updated | Impact on environments |
| --- | ---- | ------ | --- |
| latest | Contains the output of the latest build | A commit modifies the [`.src folder`](../src/) or the build workflow itself | An environment with this policy will always be updated when a new version is available. This is a recommended practice to continuously deploy changes to a test environment without any manual interventions. |
| v0.0.1-latest | Contains the output of the latest build | If the [semversion](https://semver.org) produced on build matches the policy. | All environments with a matching semversion will be updated. This is a good use case for a staging environment, especially if you want more control over pushing breaking versions. You can also have multiple staging environments for different semversions to support parallel validation of current and future versions. |
| v0.0.1-{commitId} | Contains the build output of a specific commit ID | This tag is guaranteed to never change | Only when the version in the environment file is changed will there be an impact on the environments using this policy. This is a good use case for production environments. You can specify the exact version you want to run. To deploy to production, commit a pull-request with an updated version specified in the environment file, and upon merge, the deployment to production will begin. |
