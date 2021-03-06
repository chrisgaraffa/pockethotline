class CallcategoriesController < ApplicationController
  before_action :set_callcategory, only: [:show, :edit, :update, :destroy, :toggle_active]

  # GET /callcategories
  def index
    @page_title = 'Call Categories'
    @callcategories = Callcategory.all.order(:sort_order)
  end

  # GET /callcategories/1
  def show
    @page_title = @callcategory.name + " (Call Category)"
    @page_title = @callcategory.name
  end

  # GET /callcategories/new
  def new
    @page_title = "New Call Category"
    @callcategory = Callcategory.new
  end

  # GET /callcategories/1/edit
  def edit
    @page_title = @callcategory.name + " (Call Category)"
  end

  # POST /callcategories
  def create
    @callcategory = Callcategory.new(callcategory_params)

    if @callcategory.save
      redirect_to @callcategory, notice: 'Callcategory was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /callcategories/1
  def update
    if @callcategory.update(callcategory_params)
      redirect_to @callcategory, notice: 'Callcategory was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /callcategories/1
  def destroy
    @callcategory.destroy
    redirect_to callcategories_url, notice: 'Callcategory was successfully destroyed.'
  end

  # POST /callcategories/reorder
  def reorder
    params[:ids].each_with_index do |id, idx|
      cat = Callcategory.find(id)
      cat.sort_order = idx + 1
			cat.save
    end

    respond_to do |format|
      format.json { render :json => Callcategory.all.order(:sort_order).select(:id, :sort_order).to_json }
      format.html { redirect_to callcategories_url, :alert => "The categories were reordered" }
    end
  end

  # PATCH /callcategories/1/toggle_active
  def toggle_active
    if @callcategory.active
      @callcategory.active = false
    else
      @callcategory.active = true
    end
    @callcategory.save

    respond_to do |format|
      format.json { render :json => @callcategory.to_json }
      format.html { redirect_to dashboard_path, :alert => "The category was updated." }
    end

    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_callcategory
      @callcategory = Callcategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def callcategory_params
      params.require(:callcategory).permit(:name, :active, :sort_order, :description)
    end
end
