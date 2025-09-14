require_dependency 'issue'

module IssuePatch
  def self.included(base)
    base.class_eval do
      has_many :issue_subscriptions, dependent: :destroy
      has_many :subscribers, through: :issue_subscriptions, source: :user

      # 類別方法：找到在指定天數內到期的議題
      scope :due_in_days, ->(days) { where('due_date <= ? AND due_date >= ?', Date.today + days.days, Date.today) }

      def subscribed?(user)
        issue_subscriptions.exists?(user_id: user.id)
      end

      def notify_subscribers
        Rails.logger.info "正在通知議題 ##{id} 的訂閱者..."

        unless due_date
          Rails.logger.info "- ❌ 議題 ##{id} 沒有到期日"
          return
        end

        unless Setting.plugin_redmine_notify_plugin['enable_email_notifications']
          Rails.logger.info "- ❌ 插件電子郵件通知已關閉"
          return 
        end

        Rails.logger.info "- 共有 #{subscribers.count} 個訂閱者:"

        subscribers.each do |subscriber|
          Rails.logger.info "  - #{subscriber.name} (#{subscriber.mail})"
        end

        Rails.logger.info "- 正在通知訂閱者..."

        subscribers.each do |subscriber|
          subscription = issue_subscriptions.find_by(user: subscriber)
          if subscription&.already_notified_for_due_date?(due_date)
            Rails.logger.warn "  - 已經為到期日 #{due_date} 發送過通知給 #{subscriber.name}，跳過"
            next
          end
          
          begin
            mailer = NotificationMailer.notify_due_date(subscriber, self)
            if mailer&.deliver_now
              subscription&.record_notification_sent!(due_date)
              Rails.logger.info "  - 通知已發送並記錄給 #{subscriber.name}"
            end
          rescue StandardError => e
            Rails.logger.error "Failed to queue notification for Issue ##{id} to #{subscriber.mail}: #{e.message}"
          end
        end
      end
    end
  end
end

Issue.include IssuePatch