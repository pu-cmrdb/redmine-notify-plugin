require_dependency 'issue'

module IssuePatch
  def self.included(base)
    base.class_eval do
      has_many :issue_subscriptions, dependent: :destroy
      has_many :subscribers, through: :issue_subscriptions, source: :user

      def subscribed?(user)
        issue_subscriptions.exists?(user_id: user.id)
      end

      def notify_subscribers
        return unless due_date  # 沒有到期日
        return unless Setting.plugin_redmine_notify_plugin['enable_email_notifications']  # 電子郵件通知已關閉

        Rails.logger.info "Checking notifications for Issue ##{id} (due: #{due_date})"
        
        subscribers.each do |subscriber|
          begin
            mailer = NotificationMailer.notify_due_date(self, subscriber)
            mailer&.deliver_later
          rescue StandardError => e
            Rails.logger.error "Failed to queue notification for Issue ##{id} to #{subscriber.mail}: #{e.message}"
          end
        end
      end
    end
  end
end

Issue.include IssuePatch