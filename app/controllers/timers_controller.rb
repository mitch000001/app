class TimersController < ApplicationController
  before_filter :set_active_nav

  def index
    authorize! :index, Timer
    @date = date
    projects = current_user.projects
    if week.projects.present?
      projects = projects.where("projects.id not in (?)", week.projects.map(&:id))
    end
    @projects = projects.all

    @dates = []
    (date.beginning_of_week..date.end_of_week).each do |d|
      @dates << {shortDate: I18n.l(d, format: :short), day: I18n.l(d, format: :day), date: I18n.l(d, format: :db)}
    end
    @tasks = current_user.tasks.includes(:timers).where('timers.date' => [date.beginning_of_week..date.end_of_week]).all
  end

  def new_import
    authorize! :new_import, Timer
  end

  def csv_import
    authorize! :csv_import, Timer
    Timer.import(params[:timer][:file], params[:timer][:project_id])
    redirect_to timers_path, notice: "Import"
  end

  private def set_active_nav
    @active_nav = 'timers'
  end

  private def date
    @date ||= (params[:date].present? ? Date.parse(params.fetch(:date, nil)) : Date.today)
  end
end
