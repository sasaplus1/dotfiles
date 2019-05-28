# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import (absolute_import, division, print_function)

# You can import any python module as needed.
import os

# open_file_via_vim is needed.
import sys

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command


# Any class that is a subclass of "Command" will be integrated into ranger as a
# command.  Try typing ":my_edit<ENTER>" in ranger!
class my_edit(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:my_edit <filename>

    A sample command for demonstration purposes that opens a file in an editor.
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        # self.arg(1) is the first (space-separated) argument to the function.
        # This way you can write ":my_edit somefilename<ENTER>".
        if self.arg(1):
            # self.rest(1) contains self.arg(1) and everything that follows
            target_filename = self.rest(1)
        else:
            # self.fm is a ranger.core.filemanager.FileManager object and gives
            # you access to internals of ranger.
            # self.fm.thisfile is a ranger.container.file.File object and is a
            # reference to the currently selected file.
            target_filename = self.fm.thisfile.path

        # This is a generic function to print text in ranger.
        self.fm.notify("Let's edit the file " + target_filename + "!")

        # Using bad=True in fm.notify allows you to print error messages:
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return

        # This executes a function from ranger.core.acitons, a module with a
        # variety of subroutines that can help you construct commands.
        # Check out the source, or run "pydoc ranger.core.actions" for a list.
        self.fm.edit_file(target_filename)

    # The tab method is called when you press tab, and should return a list of
    # suggestions that the user will tab through.
    # tabnum is 1 for <TAB> and -1 for <S-TAB> by default
    def tab(self, tabnum):
        # This is a generic tab-completion function that iterates through the
        # content of the current directory.
        return self._tab_directory_content()


class switch_to_another_tab(Command):
    """:switch_to_another_tab

    Open new tab if single tab, otherwise move tab.
    This command similar to vimfiler's <Tab> command.
    """

    def execute(self):
        if len(self.fm.tabs) == 1:
            self.fm.tab_new()
        else:
            self.fm.tab_move(1)


class copy_file(Command):
    """:copy_file

    Copy marked files/directories to another tab's directory.
    This command similar to vimfiler's `c` command.
    """

    def execute(self):
        if len(self.fm.tabs) > 2:
            self.fm.notify('cannot execute copy_file in multiple tabs.', bad=True)
        elif len(self.fm.tabs) == 1:
            self.fm.copy()
            # self.fm.paste()
        else:
            tabs = self.fm.tabs
            current_tab = self.fm.thistab
            another_tab = tabs[1] if tabs[1] != current_tab else tabs[2]
            current_tab.fm.copy()
            # NOTE: Why ranger say `paste() got an unexpected keyword argument 'dest'`?
            another_tab.fm.paste(append=True, dest=another_tab.path)
            current_tab.fm.mark_files(all=True, val=False)

class move_file(Command):
    """:move_file

    Move marked files/directories to another tab's directory.
    This command similar to vimfiler's `m` command.
    """

    def execute(self):
        if len(self.fm.tabs) > 2:
            self.fm.notify('cannot execute move_file in multiple tabs.', bad=True)
        elif len(self.fm.tabs) == 1:
            self.fm.cut()
            # self.fm.paste()
        else:
            tabs = self.fm.tabs
            current_tab = self.fm.thistab
            another_tab = tabs[1] if tabs[1] != current_tab else tabs[2]
            current_tab.fm.cut()
            # NOTE: Why ranger say `paste() got an unexpected keyword argument 'dest'`?
            another_tab.fm.paste(append=True, dest=another_tab.path)
            current_tab.fm.mark_files(all=True, val=False)

class open_file_via_vim(Command):
    """:open_file_via_vim

    Open selected file via Vim.
    """

    def execute(self):
        if self.fm.thisfile.is_directory:
            self.fm.move(right=1)
        else:
            target_filename = self.fm.thisfile.path

            sys.stdout.write('\033]51;["drop","{filename}"]\07'.format(filename=target_filename))
            sys.stdout.flush()

            self.fm.exit()
