# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module UFeeling
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :caching
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets', css: 'style.css'
    plugin :common_logger, $stderr

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public
      # [GET]   /                             Home
      # [POST]  /videos?url=                  Analyze a new video
      # [GET]   /videos/:video_id             Gets the analysis of a video
      # [GET]   /videos/:video_id/comments    Gets the analysis of a video including the list of top comments

      # [GET] /
      routing.root do
        # Get cookie viewer's previously seen videos
        session[:watching] ||= []
        category_selected = routing.params['category']
        category_selected = nil if category_selected.nil? || category_selected.empty?
        result = Services::HomePage.new.call(video_ids: session[:watching], category_selected:)

        if result.failure?
          flash[:error] = result.failure
          videos = []
        else
          videos = result.value![:videos].videos
          categories = result.value![:categories].categories
          videos_by_category = result.value![:videos_by_category].videos
          # flash.now[:notice] = 'Add a Youtube video to get started' if videos.none?

          session[:watching] = videos.map(&:origin_id)
        end

        home_info = Views::HomeInfo.new(videos,
                                        categories,
                                        videos_by_category,
                                        category_selected)

        view 'home', locals: { info: home_info }
      end

      # [...] /videos/
      routing.on 'videos' do
        routing.is do
          # [POST]  /videos?url=
          routing.post do
            url_request = Forms::NewVideo.new.call(routing.params)
            new_video = Services::AddVideo.new.call(url_request)

            if new_video.failure?
              flash[:error] = new_video.failure
              routing.redirect '/'
            end

            video = new_video.value!
            session[:watching].insert(0, video.origin_id).uniq!
            flash[:notice] = 'Video under analysis'
            routing.redirect "videos/#{video.origin_id}"
          end
        end

        # [...]  /videos/:video_origin_id
        routing.on String do |video_origin_id|
          # [GET]  /videos/:video_origin_id
          routing.is do
            routing.get do
              sentiment_selected = routing.params['sentiment']&.to_i
              sentiment_selected = nil if sentiment_selected.nil? || sentiment_selected.zero?
              view = routing.params['view']
              view = 'comments' if view.nil? || view.empty?

              # Get Video from API
              video_result = Services::GetVideo.new.call(
                watched_list: session[:watching] || [],
                video_id: video_origin_id,
                sentiment_selected:
              )

              if video_result.failure?
                flash[:error] = video_result.failure
                routing.redirect '/'
              end

              analize = OpenStruct.new(video_result.value!) # rubocop:disable Style/OpenStructUse

              if analize.processing?
                flash.now[:notice] = 'The video is under analisis'
              else
                video_info = Views::VideoInfo.new(video_result.value![:video],
                                                  video_result.value![:comments]&.comments || [],
                                                  video_result.value![:sentiments]&.sentiments || [],
                                                  sentiment_selected,
                                                  view)
              end

              processing = Views::VideoProcessing.new(
                App.config, analize.processing, video_origin_id
              )

              # Show viewer the video
              view 'video', locals: { video_info:, processing: }
            end
          end

          # [...]  /videos/:video_origin_id/update
          routing.on 'update' do
            # [GET]  /videos/:video_origin_id/update
            routing.get do
              update_video = Services::UpdateVideo.new.call(video_id: video_origin_id)

              if update_video.failure?
                flash[:error] = update_video.failure
              else
                flash[:notice] = 'Video under analysis'
              end

              routing.redirect "/videos/#{video_origin_id}"
            end
          end
        end
      end
    end
  end
end
