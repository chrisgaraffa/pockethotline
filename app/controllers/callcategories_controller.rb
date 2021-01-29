class CallcategoriesController < ApplicationController
  before_action :set_callcategory, only: [:show, :edit, :update, :destroy]

  # GET /callcategories
  def index
    @callcategories = Callcategory.all
  end

  # GET /callcategories/1
  def show
  end

  # GET /callcategories/new
  def new
    @callcategory = Callcategory.new
  end

  # GET /callcategories/1/edit
  def edit
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