class MockLabeller
  def initialize(labels)
    @labels = labels
  end

  def label_for(uri)
    @labels.fetch(uri, "<label not found>")
  end
end