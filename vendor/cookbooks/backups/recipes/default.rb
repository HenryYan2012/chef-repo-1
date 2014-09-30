#
# Cookbook Name:: backups
# Recipe:: default
#
# Copyright 2014, Firmhouse
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "sudo"

backup_node = node[:backups]

if backup_node
  deploy_user = "deploy"
  package "ruby-dev"
  gem_package "backup"
  backup_node.each do |app, backup_info|
    %w[ /home/deploy/Backup /home/deploy/Backup/models].each do |path|
      directory path do
        owner "deploy"
        group "deploy"
        mode "0755"
      end
    end

    execute "backup generate:model --trigger #{app}"

    storage = {
      type: backup_info.fetch(:storage_type, "unknown").to_sym,
      dropbox_api_key: backup_info[:dropbox_api_key],
      dropbox_api_secret: backup_info[:dropbox_api_secret],
      dropbox_access_token: backup_info[:dropbox_access_token],
      s3_access_key: backup_info[:s3_access_key],
      s3_secret_access_key: backup_info[:s3_secret_access_key],
      s3_bucket: backup_info[:s3_bucket],
      s3_region: backup_info.fetch(:s3_region, "eu-west-1")
    }

    database = {
      type: backup_info.fetch(:database_type, "unknown").to_sym,
      username: backup_info[:database_username],
      password: backup_info[:database_password],
      host: backup_info[:database_host]
    }

    template "/home/deploy/Backup/models/#{app}.rb" do
      source "backup_template.rb.erb"
      mode 0600
      owner deploy_user
      group deploy_user
      variables(app: app, storage: storage, database: database)
    end

    if backup_info[:enabled]
      cron "backup_#{app}" do
        minute "0"
        hour "0"
        user "deploy"
        command "cd /home/deploy/Backup && backup perform --trigger #{app}"
      end
    else
      cron "backup_#{app}" do
        user "deploy"
        action :delete
      end
    end
  end
end
