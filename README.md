Redmine Buildbot plugin
========================

This plugin provides a simple integration of Buildbot jobs into Redmine. It
uses the JSONRPC interface of Buildbot to fetch the data and add it to the
database.

the source code of this project is based on XMLRPC-based buildbot plugin (original project: http://www.redmine.org/plugins/redmine_buildbot).

XMLRPC feature is removed since Buildbot 0.8.2 (I don't know what f**king buildbot guys are thinking), and naturally this plugin had been not working also. but from now, it is working, and being maintained.
