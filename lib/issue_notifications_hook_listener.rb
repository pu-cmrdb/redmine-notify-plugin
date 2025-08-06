class IssueNotificationsHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, partial: 'issue_notifications/subscription_button'

  def controller_issues_edit_after_save(context = {})
    issue = context[:issue]
    issue.notify_subscribers if issue.due_date_changed?
  end
end 