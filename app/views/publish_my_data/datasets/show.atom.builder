atom_feed(language: 'en') do |feed|
  feed.title @resource.title
  feed.updated @resource.modified
  feed.rights "Licence terms and conditions apply"
  feed.author do |author|
    author.name PublishMyData::Resource.find(@resource.publisher).label rescue 'unknown'
    author.uri @resource.publisher
    author.email @resource.contact_email.to_s.gsub('mailto:', '')
  end

  feed.entry(@resource) do |entry|
    entry.title @resource.title
    entry.summary 'Complete dump of all triples in this dataset (zipped n-triples file)'
    entry.updated @resource.modified
    entry.link(rel: 'alternate', href: dataset_dump_url(@resource))
  end
end