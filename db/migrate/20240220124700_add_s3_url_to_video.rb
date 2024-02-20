class AddS3UrlToVideo < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :s3_url, :string
  end
end
