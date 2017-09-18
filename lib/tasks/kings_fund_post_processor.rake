namespace :kings_fund do
  desc "Post processing for King's Fund: add to collection, move the private 'txt' and switch the representative and thumbnail."

  MODELS = ['ConferenceItem','PublishedWork']

  METADATA_ONLY = 'b81cd60c-5726-4309-925e-b8d32f4fe79e'
  COLLECTION_WITH_IMAGES = '190de7b8-86d4-41be-ad8f-6fd7e51231e3'

  task post_process: :environment do

    count = 0
    ActiveFedora::Base.search_with_conditions('', fq: query_string, fl: 'id', rows: 2000).each do | work_id |

      work = find_work(work_id[:id])

      unless work.nil?
        members_count = work.member_ids.count
        puts "Processing #{work.id}: #{work.title[0]} (#{members_count} members)"
        update_tail(work, members_count) if members_count > 2
        update_representative_and_thumbnail(work) if members_count > 2
        add_to_collection(work.id, COLLECTION_WITH_IMAGES) if members_count > 2
        add_to_collection(work.id, METADATA_ONLY) if members_count <= 2
        work.save
        count = count +1
      end

    end
    puts "Updated #{count.to_s} items"
  end

  def query_string
    'has_model_ssim:(' + MODELS.collect { | model | "#{model}" }.join(' OR ') + ')'
  end

  def add_to_collection(id, collection)
    work = ActiveFedora::Base.find(id)
    collections = work.member_of_collections
    collections << ActiveFedora::Base.find(collection)
    work.member_of_collections = collections
    work.save
  end

  def find_work(id)
    ActiveFedora::Base.find(id)
  end

  # Move the first ordered member to the end (as this is the restricted txt)
  # Make the next after head the new head, unless there are only two filesets
  # In this case, make the tail the new head (there is no 'next' if there are only two filesets)
  def update_tail(work, members_count)
    new_tail = RDF::URI(work.list_source.head.id)

    if members_count == 2
      new_head = RDF::URI(work.list_source.tail.id)
    else
      new_head = work.list_source.ordered_self.first.next.rdf_subject
    end

    work.list_source.head = new_head
    work.list_source.tail = new_tail

    work
  end

  # find the first tif and make that the thumb and representative
  # add to specified collection
  def update_representative_and_thumbnail(work)
    res = []
    work.members.each do | fs |
      res << fs.id if fs.title[0].end_with? '01.tif'
    end
    work.representative_id = res[0]
    work.thumbnail_id = res[0]
  end

end
