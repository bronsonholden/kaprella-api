class PaginationMetaService
  attr_accessor :page_offset, :page_limit, :item_count, :total_pages

  def initialize(page_offset, page_limit, item_count)
    @page_offset = page_offset
    @page_limit = page_limit
    @item_count = item_count
    @total_pages = (item_count.to_f / page_limit).ceil
  end

  def generate
    {
      'pageOffset' => @page_offset,
      'pageLimit' => @page_limit,
      'itemCount' => @item_count,
      'totalPages' => @total_pages
    }
  end
end
