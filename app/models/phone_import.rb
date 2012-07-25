class PhoneImport
  attr_reader :user, :csv
  attr_reader :updated, :created, :errors, :deleted, :lines, :ignored

  def self.csv_config
    {:col_sep => "\t", :force_quotes => true}
  end

  def initialize(csv, user)
    @user, @csv = user, csv
    reset_counters
  end

  def self.perform(csv, user)
    new(csv, user).tap { |i| i.perform }
  end

  def perform
    reset_counters
    f_io = csv.read

    CSV.parse(f_io, self.class.csv_config) do |row|
      @lines += 1
      # skip header
      next if @lines == 1
      begin
        process_row(row)
      rescue ActiveRecord::RecordInvalid => e
        @errors[@lines] = e.message
      end
    end

  end

  def process_row(csv_row)
    name, number, timestamp, should_be_deleted = csv_row
    phone = user.phones.find_by_name(name) || user.phones.find_by_number(number)
    if phone.nil?
      user.phones.create!(:name => name, :number => number)
      @created += 1
    elsif should_be_deleted.present?
      phone.destroy
      @deleted += 1
    elsif phone.updated_at < (DateTime.parse(timestamp) rescue 0)
      phone.update_attributes!(:name => name, :number => number)
      @updated += 1
    else
      @ignored += 1
    end
  end

  private

  def reset_counters
    @updated = 0
    @created = 0
    @deleted = 0
    @lines = 0
    @ignored = 0
    @errors = {}
  end

end