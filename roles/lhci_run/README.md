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
  # Number of times LHCI should run on each page
  test_runs: 3
  # Location to save reports
  output_directory: "./reports/{{ ansible_date_time.iso8601 }}"
  # Type of report storage (for now only local filesystem is supported)
  upload_target_type: "filesystem"
  # Flags to pass to Google Chrome
  chrome_flags:
    - "--no-sandbox"
    - "--ignore-certificate-errors"

```

<!--ENDROLEVARS-->
