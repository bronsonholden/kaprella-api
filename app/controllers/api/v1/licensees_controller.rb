class Api::V1::LicenseesController < ApplicationController
  # GET /licensees
  def index
    render json: {}, status: :ok
  end

  # GET /licensees/:account_id
  def show
    render json: {}, status: :ok
  end

  # POST /licensees
  def create
    render json: {}, status: :created
  end

  # PATCH/PUT /licensees/:account_id
  def update
    render json: {}, status: :ok
  end

  # DELETE /licensees/:account_id
  def destroy
    render json: {}, status: :no_content
  end
end
