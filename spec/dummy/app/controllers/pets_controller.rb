class PetsController < ApplicationController
  before_action :set_pet, only: [:show, :edit, :update, :destroy]
  self.doc_default_response_types = [:json]

  doc :index, <<~DOC
  returns a list of all pets
  that are stored in the database
  DOC
  doc_response :index, 200, doc_array_of(doc_model_response_body), "json array of pets"
  doc_query_param :index, :page, "Page number for pagination"
  # GET /pets
  def index
    @pets = Pet.all
  end

  doc_response :show, :ok, doc_model_response_body, "json object representing the pet"
  # GET /pets/1
  def show
  end

  doc_response :new, :locked, {
      data: doc_model_response_body,
      other_stuff: {
          page: "current_page",
          some_more: "explain yourself"
      }
  }, "json object containing pet and pagination data"
  # GET /pets/new
  def new
    @pet = Pet.new
  end

  # GET /pets/1/edit
  def edit
  end

  doc_request :create, {pet: doc_model_response_body}
  # POST /pets
  def create
    @pet = Pet.new(pet_params)

    if @pet.save
      redirect_to @pet, notice: 'Pet was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /pets/1
  def update
    if @pet.update(pet_params)
      redirect_to @pet, notice: 'Pet was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /pets/1
  def destroy
    @pet.destroy
    redirect_to pets_url, notice: 'Pet was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pet
      @pet = Pet.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pet_params
      params.require(:pet).permit(:name, :age)
    end
end
