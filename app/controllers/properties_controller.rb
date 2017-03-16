class PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :edit, :update, :destroy, :contact_owner]
  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]
  def index  
    if params[:search]
      @properties = Property.search(params[:search]).order("created_at")
    else
      @properties = Property.all.order("created_at")
    end
    if params[:popular] == "string"
      p params[:popular]
      @properties = (Property.all.sort_by {|prop| prop.shortlists.count}).reverse!
    end
  end

  def show  #To render page of select property
    #No need anything here, because before_action executed with set_property @property and auto route to /show page
  end

  def new  #To render page where you can create property
    @property = Property.new
    #RAILS AUTOMATICALLY renders view in properties/new!
  end

  def create  #To do post request to create property
    @property = Property.new(property_params)

    if params[:property][:photo_url].blank?
      @property.photo_url = "mvrusk60tp4vn9tbpmui"
    else
      uploaded_file = params[:property][:photo_url].path
      cloudinary_file = Cloudinary::Uploader.upload(uploaded_file)
      @property.photo_url = cloudinary_file['public_id']
    end
      @property.user_id = current_user.id
    respond_to do |format|
      if @property.save
      format.html {redirect_to @property, notice: 'Property was successfully listed.'}
      format.json {render :show, status: :created, location: @property}
      else
      format.html {render :new}
      format.json {render json: @property.errors, status: :unprocessable_entity}
      end
    end
  end


  def edit  #To render page where you can edit property
#No need anything here, because before_action executed with set_property @property and auto route to /edit page

  end

  def update #To do put request to edit property
    if !params[:property][:photo_url].blank?
      uploaded_file = params[:property][:photo_url].path
      cloudinary_file = Cloudinary::Uploader.upload(uploaded_file)
      @property.photo_url = cloudinary_file['public_id']
    end
    respond_to do |format|
      if @property.update(property_params)
        format.html {redirect_to @property, notice: 'Property listing was updated successfully.'}
        format.json {render :show, status: :created, location: @property}
      else
        format.html {render :edit}
        format.json {render json: @property.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy  #To delete listed property
    @property.destroy
    @listings = current_user.properties
    @properties = Property.all
    respond_to do |format|
      format.html { render :_listings, notice: 'Property was successfully de-listed.' }
      format.json { head :no_content }
    end
  end

  def listings
    @listings = current_user.properties
    @properties = Property.all
  end

  def contact_owner
    p @property.user
    # p current_user
    PropertyMailer.property_email(@property.user, params[:body], @property, current_user).deliver
    flash[:notice] = 'Message sent'
    redirect_to property_path
  end

  private

  def set_property
    @property = Property.find(params[:id])

  end

  def property_params
    params.require(:property).permit(:address, :postcode, :price, :description, :lease_durn, :property_type, :rent_area,  :user_id, amenity_ids:[])
  end

end
