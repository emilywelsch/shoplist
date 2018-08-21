require_relative "spec_helper"
require 'pry'

describe ApplicationController do
  it "responds with a welcome message" do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Welcome!")
  end
end