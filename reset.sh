#!/bin/bash

rake db:migrate:plugin NAME=redmine_buildbot VERSION=0
rake db:migrate_plugins
