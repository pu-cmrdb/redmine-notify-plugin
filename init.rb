require 'redmine'

Redmine::Plugin.register :redmine_notify_plugin do
  name '議題到期通知'
  author '行雲者研發基地'
  description '檢查議題到期並傳送通知'
  version '0.0.1'
  url 'https://gitlab.cmrdb.cs.pu.edu.tw/redmine-notify-plugin'
  author_url 'https://gitlab.cmrdb.cs.pu.edu.tw/redmine-notify-plugin'

  # 權限
  project_module :issue_notifications do
    permission :view_issue_notifications, { issue_notifications: [:index, :show] }
    permission :manage_issue_notifications, { issue_notifications: [:create, :update, :destroy, :subscribe, :unsubscribe] }
  end

  # 設定
  settings default: {
    'notification_days_before' => '7',
    'discord_webhook_url' => '',
    'enable_discord_notifications' => '0',
    'enable_email_notifications' => '1'
  }, partial: 'settings/notify_settings'

  # 選單
  menu :project_menu, :issue_notifications, 
       { controller: 'issue_notifications', action: 'index' },
       caption: :label_issue_notifications,
       param: :project_id,
       after: :issues
end

# 載入
Rails.configuration.to_prepare do
  require_dependency 'issue_notifications_hook_listener'
  require_dependency 'issue_patch'
  require_dependency 'notification_mailer'

  # 自動啟用管理員權限
  User.where(admin: true).find_each do |admin|
    admin.roles.each do |role|
      role.add_permission!(:view_issue_notifications)
      role.add_permission!(:manage_issue_notifications)
      role.save
    end
  end

  # 預設啟用所有專案的議題通知模組
  Project.all.each do |project|
    project.enable_module!(:issue_notifications) unless project.module_enabled?(:issue_notifications)
  end
end

# 註冊排程任務
Rails.application.config.after_initialize do
  # 註冊 rake 任務，可以透過 cron 來執行
  # 建議在 crontab 中加入:
  # 0 1 * * * cd /usr/src/redmine && bundle exec rake redmine:plugins:notify_due_dates RAILS_ENV=production
  require 'rake'
  
  namespace :redmine do
    namespace :plugins do
      desc '傳送即將到期的議題通知'
      task :notify_due_dates => :environment do
        days_before = Setting.plugin_redmine_notify_plugin['notification_days_before'].to_i
        due_issues = Issue.due_in_days(days_before)
        
        due_issues.each do |issue|
          issue.notify_subscribers if Setting.plugin_redmine_notify_plugin['enable_email_notifications'] == '1'
        end
      end
    end
  end
end 