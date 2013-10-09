module RDFHelpers
  def uri(string)
    RDF::URI(string)
  end

  def a
    RDF.type
  end
end