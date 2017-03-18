class EntriesController < ApplicationController
  def index
    if params[:search].present?
      @entries = Entry.solr_search { fulltext params[:search] }
      @entries = @entries.results
    else
      @entries = Entry.none
    end
  end
end
