# Tasks, launch and make configuration

This document describes the tasks, launch configuration and make targets used in this Accelerator.

| Type | Definition | Location |
| --- | --- | --- |
| Launch configurations | VS Code launch configurations | [`.vscode/launch.json`](../.vscode/launch.json) |
| Make targets | Targets defined in the makefile | [`makefile`](../makefile) (root folder) |
| Tasks | VS Code tasks | [`.vscode/tasks.json`](../.vscode/tasks.json) |

## Implementations

| Type | Name | Implementation |
| --- | --- | --- |
| Launch configuration | Launch WebAPI | Executes task `debug: make build and create db`, then starts [`/src/webapi/app.js`](../src/webapi/src/app.js) with the VSCode 'node' debugger attached. |
| Make target | test | `npm test` --> [`src/webapi/package.json`](../src/webapi/package.json) --> `mocha` |
| Make target | start | `npm start` --> [`src/webapi/package.json`](../src/webapi/package.json) --> `node app.js` |
| Make target | build | `npm install` |
| Make target | clean | removes `src/webapi/node_modules` |
| Task | debug: make build and create db | Runs the two tasks: `make: build` and `tool: create_db` in parallel to make the environment ready for debugging. |
| Task | tool: create_db | Seeds the Postgres database with data for debugging by executing the [`init.sh`](../scripts/init.sh) script. |
| Task | test | `make test` |
| Task | start | `make start` |
| Task | build | `make build` |
| Task | clean | `make clean` |
