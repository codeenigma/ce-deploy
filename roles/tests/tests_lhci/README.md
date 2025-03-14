# LHCI tests
Step that runs LHCI against the codebase. Requires LHCI and Google Chrome to be installed on the web server or container. This can be done with ce-provision, see:

* https://github.com/codeenigma/ce-provision/tree/1.x/roles/lhci

This role is automatically present in preset ce-dev images on Docker Hub so you can just use `tests/tests_lhci` for local testing directly.

For more information on LHCI, see https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
<!--ENDROLEVARS-->

The role installs `Xvfb` for 'headful' running of Google Chrome. This is preconfigured to run in the background with a display ID of 99, so you should run this command before running any `lhci` tests to ensure Chrome has an X session to run in:

```
export DISPLAY=:99
```

To view the `Xvfb` display, from inside the web container run `x11vnc -display :99 &`

You can then connect from your host machine using a VNC client, such as https://tigervnc.org. You'll need to specify the internal IP of the web container, which you can find in your hosts file.
