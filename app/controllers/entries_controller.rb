class EntriesController < ApplicationController
  def index
    if params[:buka].present?
      @entries = Entry.solr_search { fulltext params[:buka] }
      @entries = @entries.results
    else
      @entries = Entry.none
    end
  end
end
