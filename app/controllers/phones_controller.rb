require 'csv'
class PhonesController < ApplicationController
  helper_method :csv_config, :order_field, :order_direction

  before_filter :authenticate_user!
  before_filter :find_or_build_resource, :except => [:index, :import]
  before_filter :require_csv!, :only => :import
  respond_to :html, :js, :json

  def index
    respond_with(@phones = collection) do |format|
      format.csv do
        headers["Content-Disposition"] = "attachment; filename=\"#{export_filename}\""
        render
      end
    end
  end

  def edit
    respond_with(@phone)
  end

  def update
    @phone.update_attributes(params[:phone])
    respond_with(@phone) do |format|
      unless @phone.errors.any?
        format.json { render :json => @phone }
      end
    end
  end

  def create
    flash[:notice] = 'Phone number added' if @phone.update_attributes(params[:phone])
    respond_with(@phone) do |format|
      format.js do
          if @phone.errors.any?
            render :partial => 'form', :locals => {:phone => @phone}, :status => :unprocessable_entity
          else
            render :partial => 'phone', :locals => {:phone => @phone}
          end
      end
    end
  end

  def destroy
    flash[:notice] = 'Phone number deleted from phonebook' if @phone.destroy
    respond_with(@phone) do |format|
      format.js { render :json => @phone }
    end
  end

  def import
    f = params[:import][:csv].read
    @deleted, @updated, @created, @ignored, @line, @errors = 0, 0, 0, 0, 0, {}
    processed_ids = []
    export_datetime = Time.parse(params[:import][:csv].original_filename.split('-').last) rescue nil

    CSV.parse(f, csv_config) do |row|
      @line += 1
      name, number = row
      phone = current_user.phones.find_by_name(name) || current_user.phones.find_by_number(number)

      begin
        if phone.nil?
          current_user.phones.create!(:name => name, :number => number)
          @created +=1
        elsif export_datetime && phone.updated_at < export_datetime
          processed_ids << phone.id
          phone.update_attributes(:name => name, :number => number)
          @updated += 1
        else
          @ignored += 1
        end
      rescue ActiveRecord::RecordInvalid => e
        @errors[@line] = e.message
      end
    end
    if export_datetime
      scope = current_user.phones.where(["updated_at < ?", export_datetime])
      scope = scope.where(["id NOT IN (?)", processed_ids]) if processed_ids.any?
      @deleted = scope.destroy_all().size
    end
  rescue CSV::MalformedCSVError => e
    redirect_to phones_path, :alert => "Invalid CSV file format"
  end

  private

  def csv_config
    {:col_sep => "\t", :force_quotes => true}
  end

  def require_csv!
    redirect_to phones_path, :alert => "Pls, upload CSV file" unless params[:import].present? &&  params[:import][:csv].present?
  end

  def export_filename
    "phonebook-#{Time.now.to_s(:number)}.csv"
  end

  def collection
    scope = current_user.phones
    unless params[:format] == :csv
      scope = scope.order("#{order_field} #{order_direction}").page params[:page]
      %W(name number).each do |field|
        scope = scope.where(["#{field} ILIKE ?", "#{params[field]}%"]) unless params[field].blank?
      end
    end
    scope
  end

  def order_field
    if Phone.column_names.include? params[:order_field]
      params[:order_field]
    else
      "name"
    end
  end

  def order_direction
    %W(asc desc).include?(params[:direction]) ? params[:direction] : "asc"
  end

  def find_or_build_resource
    if params[:id].present?
      @phone = current_user.phones.find params[:id]
    else
      @phone = current_user.phones.new
    end
  end


end
