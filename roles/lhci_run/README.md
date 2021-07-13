# LHCI run
Step that runs LHCI against the codebase. Requires LHCI and Google Chrome to be installed on the web server or container. This can be done with ce-provision, see:

* https://github.com/codeenigma/ce-provision/tree/1.x/roles/lhci

This role is automatically present in preset ce-dev images on Docker Hub so you can just use `lhci_run` for local testing directly.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
lhci_run:
  # Create a list of URLs to test with LHCI
  test_urls:
    - "http://www.example.com"

```

<!--ENDROLEVARS-->
