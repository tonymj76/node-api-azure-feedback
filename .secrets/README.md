# Accelerator Secrets

The `.secrets` folder contains credentials used between the application and its database when running locally (i.e. in a Dev Container or Codespace).

> NOTE: ideally the `.secrets` folder should not be committed to the repo and, instead, any local credentials would be generated. However, generation is currently inhibited by [vscode-remote-release#4568](https://github.com/microsoft/vscode-remote-release/issues/4568) and, until resolved, prevents such generation.
>
> Until that time, refrain from adding new secrets here (i.e. add them somewhere else that is *not* committed to the repo).
