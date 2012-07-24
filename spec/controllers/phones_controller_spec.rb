require 'spec_helper'
describe PhonesController do
  before do
    @user = FactoryGirl.create :user
    sign_in @user
    @file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.csv'), 'text/csv')
  end
  describe "#import" do
    context "with fresh file" do
      it "should update number if record found by name" do
        name, expected_phone = "Adriana Boyle", "(678)950-0479 x7566"
        FactoryGirl.create(:phone, :user => @user, :name => name, :number => "12345")
        Timecop.travel(feature) do
          @file.stub(:original_filename).and_return("csv-#{DateTime.now.to_s(:number)}.csv")
          post :import, {:import => {:csv => @file}}
        end

        Phone.find_by_name(name).number.should == expected_phone
      end

      it "should update name if record found by phone" do
        expected_name, phone = "Adriana Boyle", "(678)950-0479 x7566"
        FactoryGirl.create(:phone, :user => @user, :name => "test name", :number => phone)
        Timecop.travel(feature) do
          @file.stub(:original_filename).and_return("csv-#{DateTime.now.to_s(:number)}.csv")
          post :import, {:import => {:csv => @file}}
        end

        Phone.find_by_number(phone).name.should == expected_name
      end

      it "should create new records" do
        lambda {
          post :import, {:import => {:csv => @file}}
        }.should change(Phone, :count).by(3)
      end

      it "should delete records missed in file" do
        phone = FactoryGirl.create :phone, :user => @user
        @file.stub(:original_filename).and_return("csv-#{feature.to_s(:number)}.csv")
        post :import, {:import => {:csv => @file}}

        Phone.find_by_id(phone.id).should be_nil
      end
    end

    context "with outdated file" do
      it "should ignore records found by name with updated_at grater than export date" do
        name = "Adriana Boyle"
        @file.stub(:original_filename).and_return("csv-#{DateTime.now.to_s(:number)}.csv")
        old_phone = FactoryGirl.create(:phone, :user => @user, :name => name, :updated_at => feature)
        post :import, {:import => {:csv => @file}}

        Phone.find_by_id(old_phone.id).number.should == old_phone.number
      end

      it "should ignore records found by name with updated_at grater than export date" do
        number = "(678)950-0479 x7566"
        @file.stub(:original_filename).and_return("csv-#{DateTime.now.to_s(:number)}.csv")
        old_phone = FactoryGirl.create(:phone, :user => @user, :number => number, :updated_at => feature)
        post :import, {:import => {:csv => @file}}

        Phone.find_by_id(old_phone.id).name.should == old_phone.name
      end

      it "should create new records" do
        lambda {
          post :import, {:import => {:csv => @file}}
        }.should change(Phone, :count).by(3)
      end

      it "should not delete records missed in file" do
        phone = FactoryGirl.create :phone, :user => @user, :updated_at => feature
        @file.stub(:original_filename).and_return("csv-#{feature.to_s(:number)}.csv")
        post :import, {:import => {:csv => @file}}

        Phone.find_by_id(phone.id).should_not be_nil
      end
    end
  end

  def feature(offset = 1.minute)
    DateTime.now + offset
  end
end