class EntriesController < ApplicationController
  def index
    @entries = Entry.order(:slug).limit(100)
  end
end
