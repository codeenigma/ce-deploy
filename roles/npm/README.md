# NPM

Performs npm or yarn tasks on a freshly deployed codebase.

<!--ROLEVARS-->
## Default variables
```yaml
---
npm:
  # npm/yarn
  executor: npm
  working_dir: "{{ deploy_path }}"
  # A list of commands to execute.
  commands: []
  # eg:
  # - install
  # - build-prod

```

<!--ENDROLEVARS-->
