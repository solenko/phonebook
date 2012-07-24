require 'csv'
class PhonesController < ApplicationController
  helper_method :csv_config

  before_filter :authenticate_user!
  before_filter :find_collection, :only => :index
  before_filter :find_or_build_resource, :except => [:index, :import]
  before_filter :require_csv!, :only => :import
  respond_to :html, :js

  def index
    respond_with(@phones) do |format|
      format.html
      format.js
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
    flash[:notice] = 'Phone number @updated' if @phone.update_attributes(params[:phone])
    respond_with(@phone, :location => phones_path)
  end

  def create
    flash[:notice] = 'Phone number added' if @phone.update_attributes(params[:phone])
    respond_with(@phone, :location => phones_path)
  end

  def destroy
    flash[:notice] = 'Phone number deleted from phonebook' if @phone.destroy
    respond_with(@phone)
  end

  def import
    f = params[:import][:csv].read
    @deleted, @updated, @created, @ignored, @line, @errors = 0, 0, 0, 0, 0, {}
    export_datetime = begin
          Time.parse(params[:import][:csv].original_filename.split('-').last)
        rescue ArgumentError => e
          nil
    end

    CSV.parse(f, csv_config) do |row|
      @line += 1
      name, number = row
      phone = current_user.phones.find_by_name(name) || current_user.phones.find_by_number(number)

      begin
        if phone.nil?
          current_user.phones.create!(:name => name, :number => number)
          @created +=1
        elsif export_datetime && phone.updated_at < export_datetime
          phone.update_attributes(:name => name, :number => number)
          @updated += 1
        else
          @ignored += 1
        end
      rescue ActiveRecord::RecordInvalid => e
        @errors[@line] = e.message
      end
    end
    @deleted = current_user.phones.where(["updated_at < ?", export_datetime]).destroy_all().size if export_datetime
  rescue CSV::MalformedCSVError => e
    redirect_to phones_path, :alert => "Invalid CSV file format"
  end



  private

  def csv_config
    {:col_sep => "\t", :force_quotes => true}
  end

  def require_csv!
    redirect_to phones_path, :alert => "Pls, upload CSV file" unless params[:import][:csv].present?
  end

  def export_filename
    "phonebook-#{Time.now.to_s(:number)}.csv"
  end

  def find_collection
    @phones = current_user.phones
    unless params[:format] == :csv
      @phones = @phones.order("#{order_field} #{order_direction}").page params[:page]
      %W(name number).each do |field|
        @phones = scope.where(["#{field} ILIKE ?", "#{params[field]}%"]) unless params[field].blank?
      end
    end
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
