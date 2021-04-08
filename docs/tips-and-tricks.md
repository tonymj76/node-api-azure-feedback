# **Tips and Tricks**

As you get more familiar with the code base, we want you to feel empowered to customize and run the Accelerator however you wish. This section provides some tips to modify the build and deployment process.

## Run your app in a VS Code development container

If you do not have access to Codespaces or would like to try using an Accelerator in a VS Code dev container, follow these steps:

1. Install [VS Code](https://code.visualstudio.com/download).
1. Install the [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) to take advantage of the [`devcontainer.json`](../.devcontainer/devcontainer.json) file.
1. Install [Docker Desktop or Docker Engine](https://www.docker.com/get-started) to ensure a dev container can be built locally.
1. Open a terminal on your PC and use Git to clone the repository you just created.
1. Change the directory to the new folder (``cd <git-clone-folder-name>``)
1. Enter `code .` to launch VS Code from this folder.
1. When prompted, click **Reopen in Container** in the lower right. This command leverages the [`devcontainer.json`](../.devcontainer/devcontainer.json) file to run VS Code inside of a development environment with all required installations and extensions.
1. Return to the [Run the app](../README.md#run-the-app) section to continue the Quick Start.

## Run the app without debugging

Options to run the app without debugging include:

- From your Codespace, open the Command Palette (`Ctrl + Shift + P` or `CMD + Shift + P`), select the command **Tasks: Run Task**, then select **make: start**.
- Enter `npm start` from the integrated terminal (`` Ctrl + ` ``).

## Web API modifications

This is a standard Node.js Express.js app. The source code is in the [`src/webapi folder`](../src/webapi/). To add new routes to the application, modify [`src/webapi/routes/index.js`](../src/webapi/routes/index.js).

## Database modifications

The local MSSQL database configuration is found in [`src/webapi/db/db.js`](../src/webapi/db/db.js). This Accelerator implements [Sequelize](https://sequelize.org/master/manual/getting-started.html) to model the data.

This Accelerator uses Docker Compose to instantiate the PostgreSQL database container. This service's declaration is found in [`.devcontainer/docker-compose.yml`](../.devcontainer/docker-compose.yml). As an example, this is where you could modify the database password or set memory limits.

**Important:** Modifying **any file** in the [`.devcontainer folder`](../.devcontainer/) requires you to open the Command Palette (`Ctrl + Shift + P`  or `CMD + Shift + P`) and run **Remote-Containers: Rebuild and Reopen in Container**.

## GitHub Workflow modifications

A GitHub Workflow is comprised of multiple GitHub Actions to automate tasks in the development outer loop. The build workflow is found in [`.github/workflows/build.yaml`](../.github/workflows/build.yaml) and the deploy workflow is found in [`.github/workflows/deploy.yaml`](../.github/workflows/deploy.yaml). Learn more about [creating a new workflow](https://docs.github.com/en/actions/quickstart).

## Porter deployment modifications

Porter executes a series of tasks in order to bundle your code for deployment. The Porter bundle is defined in [`src/bundle/porter.yaml`](../src/bundle/porter.yaml). Learn more about [authoring Porter bundles](https://porter.sh/author-bundles/).

**Note:** When changes to `porter.yaml` are pushed to the repo, this will automatically trigger the [`build.yaml`](../.github/workflows/build.yaml) workflow.

## Bicep deployment modifications

The [`src/arm folder`](../src/arm/) contains multiple `.bicep` files. Each file declares Azure resources required by the application (Web API, Azure PostgreSQL, Application Insights). The [`main.bicep`](../src/arm/main.bicep) file joins the declarations of each component. This file overwrites the default parameters in either the Resource Provider in Azure, or as defined in the individual module files. Learn more about [authoring Bicep files](https://github.com/Azure/bicep/tree/main/docs/tutorial).

## Environments YAML file

The [`environments/environments.yaml`](../environments/environments.yaml) file manages the configuration of the Azure deployment.

**Note:** When changes to `environments.yaml` are pushed to the repo, this will automatically trigger the [`deploy.yaml`](../.github/workflows/deploy.yaml) workflow.

## Modifying the deployment resource group name

The `AZURE_NAME_PREFIX` attribute prefixes the selected value to both the resource group and each resource deployed by the application. Modify this attribute in [`environments/environments.yaml`](../environments/environments.yaml).

```yml
...
config:
    AZURE_LOCATION: "northeurope"
    AZURE_NAME_PREFIX: "test"
```

## Clean and Rebuild your dev environment

The [`.devcontainer folder`](../.devcontainer/) contains all of the development environment configuration to run the application in Codespaces or a dev container. When changes are made to **any file** in this folder, you must open the Command Palette (`Ctrl + Shift + P`  or `CMD + Shift + P`) and run **Remote-Containers: Rebuild and Reopen in Container**.
