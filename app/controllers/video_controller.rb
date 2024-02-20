require 'aws-sdk-s3'

class VideoController < ApplicationController
  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      transcode_and_upload_video
      redirect_to @video, notice: 'Video was successfully uploaded.'
    else
      render :new
    end
  end

	def show
		@video = Video.find(params[:id])
	end

  private

  def video_params
    params.require(:video).permit(:name, :video)
  end

  def transcode_and_upload_video
    video_path = @video.video.path
    transcoded_video_dir = "#{Rails.root}/tmp/#{SecureRandom.hex}"
    FileUtils.mkdir_p(transcoded_video_dir)

    transcoded_video = "#{transcoded_video_dir}/output.mp4"
    transcoder = FFMPEG::Movie.new(video_path)
		options = {
			custom: %w(-c:v libx264 -c:a aac),
			preserve_aspect_ratio: :width,
			resolution: '640x360'
		}
    transcoder.transcode(transcoded_video, options)

    # Upload transcoded video to S3
    s3 = Aws::S3::Resource.new(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )
    obj = s3.bucket(ENV['S3_BUCKET']).object(File.basename(transcoded_video))
    obj.upload_file(transcoded_video)
    
    # Update the video attribute with the S3 URL
    @video.update(s3_url: obj.public_url)
  end
end
