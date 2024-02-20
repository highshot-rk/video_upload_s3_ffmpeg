class Video < ApplicationRecord
	mount_uploader :video, VideoUploader
end
