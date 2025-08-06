class IssueNotificationsController < ApplicationController
  before_action :find_project_by_project_id, only: [:index]
  before_action :authorize, only: [:index]
  before_action :find_issue, only: [:subscribe, :unsubscribe]
  before_action :authorize_global, only: [:subscribe, :unsubscribe]

  def index
    @issues = @project.issues.due_in_days(Setting.plugin_redmine_notify_plugin['notification_days_before'].to_i)
  end

  def subscribe
    subscription = IssueSubscription.new(issue: @issue, user: User.current)
    if subscription.save
      flash[:notice] = l(:notice_subscription_created)
    else
      flash[:error] = l(:error_subscription_not_created)
    end
    redirect_to issue_path(@issue)
  end

  def unsubscribe
    subscription = IssueSubscription.find_by(issue: @issue, user: User.current)
    if subscription&.destroy
      flash[:notice] = l(:notice_subscription_removed)
    else
      flash[:error] = l(:error_subscription_not_removed)
    end
    redirect_to issue_path(@issue)
  end

  private

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end 