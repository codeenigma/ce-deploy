# LHCI run
Step that runs LHCI against the codebase. Requires LHCI and Google Chrome to be installed on the web server or container. This can be done with ce-provision, see:

* https://github.com/codeenigma/ce-provision/tree/1.x/roles/lhci

This role is automatically present in preset ce-dev images on Docker Hub so you can just use `lhci_run` for local testing directly.

For more information on LHCI, see https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md

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
    - "--disable-dev-shm-usage"
  # Optional lists of audits to explicitly skip or run.
  skip_audits: []
  only_audits: []

```

<!--ENDROLEVARS-->

The role installs `Xvfb` for 'headful' running of Google Chrome. This is preconfigured to run in the background with a display ID of 99, so you should run this command before running any `lhci` tests to ensure Chrome has an X session to run in:

```
export DISPLAY=:99
```

To view the `Xvfb` display, from inside the web container run `x11vnc -display :99 &`

You can then connect from your host machine using a VNC client, such as https://tigervnc.org. You'll need to specify the internal IP of the web container, which you can find in your hosts file.
