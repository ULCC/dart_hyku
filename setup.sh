#!/bin/bash

rake db:drop
rake db:create
rake db:migrate
#rake db:migrate
rake hyrax:default_admin_set:create
rake hyrax:workflow:load