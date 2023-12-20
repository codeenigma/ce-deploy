import sys

from ansible import constants as C
from ansible.plugins.callback import CallbackBase

DOCUMENTATION = '''
name: fail_on_no_hosts
callback_type: aggregate
requirements:
    - enable in configuration
short_description: Exits with code 1 if no play hosts are matched
version_added: "2.0"
description:
    - This callback overrides the default 'v2_playbook_on_no_hosts_matched' method with one that exits instead of just notifying.
'''

class CallbackModule(CallbackBase):
    """
    This callback module exists non-zero if no hosts match
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'aggregate'
    CALLBACK_NAME = 'fail_on_no_hosts'
    CALLBACK_NEEDS_WHITELIST = False

    def __init__(self):
        super(CallbackModule, self).__init__()

    def v2_playbook_on_no_hosts_matched(self):
        self._display.display("failed: no hosts matched", color=C.COLOR_ERROR)
        sys.exit(1)
